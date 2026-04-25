import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/services/theme_preferences_repository.dart';
import 'package:mindfulness_app/viewmodels/theme_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeThemePreferencesRepository extends ThemePreferencesRepository {
  FakeThemePreferencesRepository({this.loadedMode = ThemeMode.light});

  ThemeMode loadedMode;
  ThemeMode? savedMode;

  @override
  Future<ThemeMode> loadThemeMode() async => loadedMode;

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    savedMode = mode;
  }
}

void main() {
  group('ThemePreferencesRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('uses light mode when no preference is stored', () async {
      final repository = ThemePreferencesRepository();

      expect(await repository.loadThemeMode(), ThemeMode.light);
    });

    test('persists and reads dark mode locally', () async {
      final repository = ThemePreferencesRepository();

      await repository.saveLocalThemeMode(ThemeMode.dark);

      expect(await repository.loadLocalThemeMode(), ThemeMode.dark);
    });

    test('parses invalid remote values as null', () {
      expect(ThemePreferencesRepository.parseThemeMode('system'), isNull);
      expect(ThemePreferencesRepository.parseThemeMode(null), isNull);
    });
  });

  group('ThemeViewModel', () {
    test('starts in light mode by default', () {
      final viewModel = ThemeViewModel(
        repository: FakeThemePreferencesRepository(),
      );

      expect(viewModel.themeMode, ThemeMode.light);
      expect(viewModel.isDarkMode, isFalse);
    });

    test('initializes from the repository', () async {
      final repository = FakeThemePreferencesRepository(
        loadedMode: ThemeMode.dark,
      );
      final viewModel = ThemeViewModel(repository: repository);

      await viewModel.initialize();

      expect(viewModel.themeMode, ThemeMode.dark);
      expect(viewModel.isDarkMode, isTrue);
    });

    test('saves theme changes immediately', () async {
      final repository = FakeThemePreferencesRepository();
      final viewModel = ThemeViewModel(repository: repository);

      await viewModel.setThemeMode(ThemeMode.dark);

      expect(viewModel.themeMode, ThemeMode.dark);
      expect(repository.savedMode, ThemeMode.dark);
    });
  });
}
