import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// En lugar de usar 'package:tesis_mindfulness/...'
import 'viewmodels/psicologa_nav_view_model.dart';

// Importaciones de tus archivos (Ajusta las rutas según tu carpetas)
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/home/presentation/home_switcher.dart';
import 'viewmodels/auth_viewmodel.dart';

/// App Entry Point.
Future<void> main() async {
  // Ensure Flutter bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("Environment loaded successfully");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }

  // 2. Initialize Supabase
  // We use a try-catch here to prevent the app from crashing if keys are invalid
  try {
    if (SupabaseConfig.isConfigured) {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
    }
  } catch (e) {
    debugPrint("Supabase initialization failed: $e");
  }

  // 2. Ejecución de la App envuelta en MultiProvider
  runApp(
    MultiProvider(
      providers: [
        // Aquí "invocas" el cerebro de tu navegación
        ChangeNotifierProvider(create: (_) => PsicologaNavViewModel()),
        // Aquí podrías agregar más ViewModels en el futuro
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // The ViewModel will handle its own initialization safely
        ChangeNotifierProvider(create: (_) => AuthViewModel()..initialize()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mindfulness - Gestión del Sueño',
        theme: AppTheme.lightTheme,
        home: Consumer<AuthViewModel>(
          builder: (context, authViewModel, _) {
            // If Supabase is not configured, show a helpful error screen
            if (!SupabaseConfig.isConfigured) {
              return const Scaffold(
                body: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Configuración faltante en el archivo .env\n\nPor favor, asegúrate de tener SUPABASE_URL y SUPABASE_ANON_KEY configurados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                ),
              );
            }

            // Normal authentication flow
            if (authViewModel.isAuthenticated) {
              return const HomeSwitcher();
            } else {
              return const LoginScreen();
            }
          },
        ),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeSwitcher(),
        },
      ),
    );
  }
}
