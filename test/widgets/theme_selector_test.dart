import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:mindfulness_app/core/theme/app_theme.dart';
import 'package:mindfulness_app/services/theme_preferences_repository.dart';
import 'package:mindfulness_app/viewmodels/auth_viewmodel.dart';
import 'package:mindfulness_app/viewmodels/theme_viewmodel.dart';
import 'package:mindfulness_app/views/modulo_paciente/profile_view.dart';
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

void main() {
  testWidgets('theme selector changes to dark mode in real time', (
    WidgetTester tester,
  ) async {
    final repository = FakeThemePreferencesRepository();
    final themeViewModel = ThemeViewModel(repository: repository);
    AppColors.useLight();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider.value(value: themeViewModel),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeViewModel.themeMode,
          home: const ProfileView(),
        ),
      ),
    );

    expect(find.text('Tema visual'), findsOneWidget);
    expect(find.text('Claro'), findsOneWidget);
    expect(find.text('Oscuro'), findsOneWidget);

    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();

    expect(themeViewModel.themeMode, ThemeMode.dark);
    expect(repository.savedMode, ThemeMode.dark);
  });
}
