import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/models/thought_entry_model.dart';
import 'package:mindfulness_app/services/thought_entries_repository.dart';
import 'package:mindfulness_app/viewmodels/thought_entries_viewmodel.dart';

class FakeThoughtEntriesRepository implements ThoughtEntriesRepository {
  FakeThoughtEntriesRepository({List<ThoughtEntryModel>? seed})
    : _items = List<ThoughtEntryModel>.from(seed ?? const []);

  final List<ThoughtEntryModel> _items;
  bool shouldThrowOnList = false;
  bool shouldThrowOnCreate = false;
  bool shouldThrowOnUpdate = false;
  bool shouldThrowOnDelete = false;

  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;

  @override
  Future<List<ThoughtEntryModel>> listByPatient() async {
    if (shouldThrowOnList) throw Exception('list error');
    return List<ThoughtEntryModel>.from(_items);
  }

  @override
  Future<ThoughtEntryModel> create({required String content}) async {
    if (shouldThrowOnCreate) throw Exception('create error');
    createCalls += 1;
    final entry = ThoughtEntryModel(
      id: 'new-$createCalls',
      patientId: 'patient-1',
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _items.add(entry);
    return entry;
  }

  @override
  Future<ThoughtEntryModel> update({
    required String id,
    required String content,
  }) async {
    if (shouldThrowOnUpdate) throw Exception('update error');
    updateCalls += 1;
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) throw Exception('not found');
    final updated = _items[index].copyWith(
      content: content,
      updatedAt: DateTime.now(),
    );
    _items[index] = updated;
    return updated;
  }

  @override
  Future<void> delete({required String id}) async {
    if (shouldThrowOnDelete) throw Exception('delete error');
    deleteCalls += 1;
    _items.removeWhere((item) => item.id == id);
  }
}

ThoughtEntryModel _entry({required String id, required DateTime createdAt}) {
  return ThoughtEntryModel(
    id: id,
    patientId: 'patient-1',
    content: 'contenido $id',
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

void main() {
  group('ThoughtEntriesViewModel', () {
    test('loads history in newest-first order', () async {
      final older = _entry(id: '1', createdAt: DateTime(2026, 1, 1, 18, 0));
      final newer = _entry(id: '2', createdAt: DateTime(2026, 1, 2, 18, 0));
      final repository = FakeThoughtEntriesRepository(seed: [older, newer]);
      final viewModel = ThoughtEntriesViewModel(repository: repository);

      await viewModel.loadEntries();

      expect(viewModel.entries.first.id, '2');
      expect(viewModel.entries.last.id, '1');
      expect(viewModel.errorMessage, isNull);
    });

    test('creates a new entry', () async {
      final repository = FakeThoughtEntriesRepository();
      final viewModel = ThoughtEntriesViewModel(repository: repository);

      final success = await viewModel.saveEntry(content: 'hola mente');

      expect(success, isTrue);
      expect(repository.createCalls, 1);
      expect(viewModel.entries.length, 1);
      expect(viewModel.successMessage, 'Pensamiento guardado.');
    });

    test('prevents editing entries older than 24 hours', () async {
      final oldEntry = _entry(
        id: '1',
        createdAt: DateTime.now().subtract(const Duration(hours: 25)),
      );
      final repository = FakeThoughtEntriesRepository(seed: [oldEntry]);
      final viewModel = ThoughtEntriesViewModel(repository: repository);

      final success = await viewModel.saveEntry(
        content: 'texto nuevo',
        existingEntry: oldEntry,
      );

      expect(success, isFalse);
      expect(repository.updateCalls, 0);
      expect(
        viewModel.errorMessage,
        'Solo puedes editar entradas dentro de las primeras 24 horas.',
      );
    });

    test('updates entries within 24 hours', () async {
      final recentEntry = _entry(
        id: '1',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      final repository = FakeThoughtEntriesRepository(seed: [recentEntry]);
      final viewModel = ThoughtEntriesViewModel(repository: repository);
      await viewModel.loadEntries();

      final success = await viewModel.saveEntry(
        content: 'texto editado',
        existingEntry: recentEntry,
      );

      expect(success, isTrue);
      expect(repository.updateCalls, 1);
      expect(viewModel.entries.first.content, 'texto editado');
    });

    test('prevents deleting entries older than 24 hours', () async {
      final oldEntry = _entry(
        id: '1',
        createdAt: DateTime.now().subtract(const Duration(hours: 26)),
      );
      final repository = FakeThoughtEntriesRepository(seed: [oldEntry]);
      final viewModel = ThoughtEntriesViewModel(repository: repository);

      final success = await viewModel.deleteEntry(oldEntry);

      expect(success, isFalse);
      expect(repository.deleteCalls, 0);
      expect(viewModel.entries.length, 0);
      expect(
        viewModel.errorMessage,
        'Solo puedes eliminar entradas dentro de las primeras 24 horas.',
      );
    });

    test('sets error when loading fails', () async {
      final repository = FakeThoughtEntriesRepository()
        ..shouldThrowOnList = true;
      final viewModel = ThoughtEntriesViewModel(repository: repository);

      await viewModel.loadEntries();

      expect(
        viewModel.errorMessage,
        'No se pudo cargar tu historial de pensamientos. Intenta nuevamente.',
      );
    });
  });
}
