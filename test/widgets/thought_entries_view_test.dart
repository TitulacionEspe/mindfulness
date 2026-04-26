import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/theme/app_theme.dart';
import 'package:mindfulness_app/models/thought_entry_model.dart';
import 'package:mindfulness_app/services/thought_entries_repository.dart';
import 'package:mindfulness_app/viewmodels/thought_entries_viewmodel.dart';
import 'package:mindfulness_app/views/modulo_paciente/thought_entries_view.dart';
import 'package:provider/provider.dart';

class FakeThoughtEntriesRepository implements ThoughtEntriesRepository {
  FakeThoughtEntriesRepository({List<ThoughtEntryModel>? seed})
    : _items = List<ThoughtEntryModel>.from(seed ?? const []);

  final List<ThoughtEntryModel> _items;

  @override
  Future<List<ThoughtEntryModel>> listByPatient() async {
    return List<ThoughtEntryModel>.from(_items);
  }

  @override
  Future<ThoughtEntryModel> create({required String content}) async {
    final entry = ThoughtEntryModel(
      id: 'created-1',
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
    final index = _items.indexWhere((item) => item.id == id);
    final updated = _items[index].copyWith(
      content: content,
      updatedAt: DateTime.now(),
    );
    _items[index] = updated;
    return updated;
  }

  @override
  Future<void> delete({required String id}) async {
    _items.removeWhere((item) => item.id == id);
  }
}

ThoughtEntryModel _entry({
  required String id,
  required String content,
  required DateTime createdAt,
}) {
  return ThoughtEntryModel(
    id: id,
    patientId: 'patient-1',
    content: content,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

Widget _buildApp(ThoughtEntriesRepository repository) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => ThoughtEntriesViewModel(repository: repository),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const ThoughtEntriesView(),
    ),
  );
}

void main() {
  testWidgets('renders composer and history', (tester) async {
    final repository = FakeThoughtEntriesRepository(
      seed: [
        _entry(
          id: '1',
          content: 'entrada reciente',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    );

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Descarga emocional'), findsOneWidget);
    expect(find.text('Guardar pensamiento'), findsOneWidget);
    expect(find.text('Historial privado'), findsOneWidget);
    expect(find.text('entrada reciente'), findsOneWidget);
  });

  testWidgets('shows edit/delete only for recent entries', (tester) async {
    final repository = FakeThoughtEntriesRepository(
      seed: [
        _entry(
          id: 'recent',
          content: 'puede editarse',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        _entry(
          id: 'old',
          content: 'entrada antigua',
          createdAt: DateTime.now().subtract(const Duration(hours: 30)),
        ),
      ],
    );

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Editar entrada'), findsOneWidget);
    expect(find.byTooltip('Eliminar entrada'), findsOneWidget);
  });

  testWidgets('deletes entry after confirmation dialog', (tester) async {
    final repository = FakeThoughtEntriesRepository(
      seed: [
        _entry(
          id: 'recent',
          content: 'se elimina',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
    );

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('se elimina'), findsOneWidget);
    await tester.tap(find.byTooltip('Eliminar entrada'));
    await tester.pumpAndSettle();

    expect(find.text('Eliminar entrada'), findsOneWidget);
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('se elimina'), findsNothing);
  });
}
