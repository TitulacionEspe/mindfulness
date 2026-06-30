import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/accessibility/accessibility_preferences.dart';
import 'package:mindfulness_app/services/accessibility_preferences_repository.dart';
import 'package:mindfulness_app/viewmodels/accessibility_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAccessibilityPreferencesRepository
    extends AccessibilityPreferencesRepository {
  FakeAccessibilityPreferencesRepository({AccessibilityPreferences? loaded})
    : loaded = loaded ?? const AccessibilityPreferences();

  AccessibilityPreferences loaded;
  double? savedFontScale;
  ColorVisionMode? savedColorVisionMode;

  @override
  Future<AccessibilityPreferences> loadPreferences() async => loaded;

  @override
  Future<void> saveFontScale(double fontScale) async {
    savedFontScale = fontScale;
  }

  @override
  Future<void> saveColorVisionMode(ColorVisionMode mode) async {
    savedColorVisionMode = mode;
  }
}

void main() {
  group('AccessibilityPreferencesRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loads safe defaults when no preference exists', () async {
      final repository = AccessibilityPreferencesRepository();

      final preferences = await repository.loadPreferences();

      expect(preferences.fontScale, 1.0);
      expect(preferences.colorVisionMode, ColorVisionMode.normal);
    });

    test('persists and loads font scale and color vision mode', () async {
      final repository = AccessibilityPreferencesRepository();

      await repository.savePreferences(
        const AccessibilityPreferences(
          fontScale: 1.2,
          colorVisionMode: ColorVisionMode.redGreenSupport,
        ),
      );

      final preferences = await repository.loadPreferences();

      expect(preferences.fontScale, 1.2);
      expect(preferences.colorVisionMode, ColorVisionMode.redGreenSupport);
    });

    test('normalizes invalid stored values to safe defaults', () async {
      SharedPreferences.setMockInitialValues({
        AccessibilityPreferencesRepository.fontScaleKey: 1.17,
        AccessibilityPreferencesRepository.colorVisionModeKey: 'unknown',
      });
      final repository = AccessibilityPreferencesRepository();

      final preferences = await repository.loadPreferences();

      expect(preferences.fontScale, 1.0);
      expect(preferences.colorVisionMode, ColorVisionMode.normal);
    });
  });

  group('AccessibilityViewModel', () {
    test('initializes from repository', () async {
      final repository = FakeAccessibilityPreferencesRepository(
        loaded: const AccessibilityPreferences(
          fontScale: 1.3,
          colorVisionMode: ColorVisionMode.redGreenSupport,
        ),
      );
      final viewModel = AccessibilityViewModel(repository: repository);

      await viewModel.initialize();

      expect(viewModel.fontScale, 1.3);
      expect(viewModel.isColorBlindModeEnabled, isTrue);
    });

    test('snaps font scale and saves it', () async {
      final repository = FakeAccessibilityPreferencesRepository();
      final viewModel = AccessibilityViewModel(repository: repository);

      await viewModel.setFontScale(1.26);

      expect(viewModel.fontScale, 1.3);
      expect(repository.savedFontScale, 1.3);
    });

    test('toggles red-green support mode', () async {
      final repository = FakeAccessibilityPreferencesRepository();
      final viewModel = AccessibilityViewModel(repository: repository);

      await viewModel.toggleColorBlindMode(true);

      expect(viewModel.colorVisionMode, ColorVisionMode.redGreenSupport);
      expect(repository.savedColorVisionMode, ColorVisionMode.redGreenSupport);
    });

    test('combines system and user text scale with safe clamp', () {
      final viewModel = AccessibilityViewModel(
        repository: FakeAccessibilityPreferencesRepository(
          loaded: const AccessibilityPreferences(fontScale: 1.3),
        ),
      );

      expect(viewModel.effectiveTextScale(2), 1.3);
      expect(viewModel.effectiveTextScale(0.5), 0.9);
    });
  });
}
