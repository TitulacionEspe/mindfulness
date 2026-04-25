import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mindfulness_app/moduloCitas/viewmodels/appointments_viewmodel.dart';
import 'package:mindfulness_app/moduloPsiquiatra/viewmodels_ps/favorites_viewmodel.dart';
import 'package:mindfulness_app/moduloPsiquiatra/viewmodels_ps/freesound_viewmodel.dart';
import 'package:mindfulness_app/services/notification_service.dart';
import 'package:mindfulness_app/viewmodels/reminders_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/home/presentation/home_switcher.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/psicologa_nav_viewmodel.dart';
import 'viewmodels/routines_viewmodel.dart';
import 'viewmodels/sleep_habits_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es', null);

  try {
    await dotenv.load(fileName: '.env');
    debugPrint('Environment loaded successfully');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }

  try {
    if (SupabaseConfig.isConfigured) {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
    }
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  try {
    await NotificationService().init();
    debugPrint('Notifications initialized successfully');
  } catch (e) {
    debugPrint('Notification initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => PsicologaNavViewModel()),
        ChangeNotifierProvider(create: (_) => FreesoundViewModel()),
        ChangeNotifierProvider(create: (_) => AppointmentsViewModel()),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => SleepHabitsViewModel()),
        ChangeNotifierProvider(create: (_) => RoutinesViewModel()),
        ChangeNotifierProvider(create: (_) => RemindersViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          AppColors.useThemeMode(themeViewModel.themeMode);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Mindfulness - Gestion del Sueno',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeViewModel.themeMode,
            home: Consumer<AuthViewModel>(
              builder: (context, authViewModel, _) {
                if (!SupabaseConfig.isConfigured) {
                  return Scaffold(
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Configuracion faltante en el archivo .env\n\n'
                          'Por favor, asegurate de tener SUPABASE_URL y '
                          'SUPABASE_ANON_KEY configurados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                if (authViewModel.isAuthenticated) {
                  return const HomeSwitcher();
                }
                return const LoginScreen();
              },
            ),
            routes: {
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/home': (_) => const HomeSwitcher(),
            },
          );
        },
      ),
    );
  }
}
