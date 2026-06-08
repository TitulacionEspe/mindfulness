import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:mindfulness_app/core/theme/app_theme.dart';
import 'package:mindfulness_app/services/theme_preferences_repository.dart';
import 'package:mindfulness_app/viewmodels/auth_viewmodel.dart';
import 'package:mindfulness_app/viewmodels/sleep_habits_viewmodel.dart';
import 'package:mindfulness_app/viewmodels/theme_viewmodel.dart';
import 'package:mindfulness_app/views/modulo_paciente/sleep_habits_view.dart';
import 'package:provider/provider.dart';

class FakeThemePreferencesRepository extends ThemePreferencesRepository {
  ThemeMode? savedMode;

  @override
  Future<ThemeMode> loadThemeMode() async => ThemeMode.light;

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    savedMode = mode;
  }
}

class FakeSleepHabitsViewModel extends SleepHabitsViewModel {
  final bool _isLoadingFake = false;
  
  @override
  bool get isLoading => _isLoadingFake;

  @override
  Future<void> loadSettings({bool force = false}) async {
    // Evitar acceso a Supabase no inicializado en pruebas
  }

  @override
  bool get hasCompletedOnboarding => true;
}

void main() {
  testWidgets('theme selector changes to dark mode in real time', (
    WidgetTester tester,
  ) async {
    // Ajustar el tamaño del viewport físico y el ratio de píxeles para tener suficiente espacio lógico (3000px)
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = FakeThemePreferencesRepository();
    final themeViewModel = ThemeViewModel(repository: repository);
    final sleepHabitsViewModel = FakeSleepHabitsViewModel();
    AppColors.useLight();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider<SleepHabitsViewModel>.value(value: sleepHabitsViewModel),
          ChangeNotifierProvider.value(value: themeViewModel),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeViewModel.themeMode,
          home: const SleepHabitsView(),
        ),
      ),
    );

    await tester.pump(); // Render first frame
    await tester.pump(); // Post frame callback

    // Imprimir los textos encontrados en pantalla
    final textWidgets = find.byType(Text).evaluate().map((el) => (el.widget as Text).data).toList();
    print('Textos en pantalla: $textWidgets');

    expect(find.text('Tema preferencial / Descanso visual'), findsOneWidget);
    expect(find.text('Claro'), findsOneWidget);
    expect(find.text('Oscuro'), findsOneWidget);

    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();

    expect(themeViewModel.themeMode, ThemeMode.dark);
    expect(repository.savedMode, ThemeMode.dark);
  });
}
