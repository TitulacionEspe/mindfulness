import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'viewmodels/auth_viewmodel.dart';

/// Punto de entrada de la aplicación.
/// Carga el archivo .env e inicializa Supabase antes de ejecutar la app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga el archivo .env (lee SUPABASE_URL y SUPABASE_ANON_KEY)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env no encontrado — SupabaseConfig.isConfigured lo detectará
  }

  // Inicializa Supabase con los valores del .env
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Proporciona AuthViewModel globalmente para toda la app.
        ChangeNotifierProvider(create: (_) => AuthViewModel()..initialize()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mindfulness - Gestión del Sueño',
        theme: AppTheme.lightTheme,
        // Decide pantalla inicial según el estado de autenticación.
        home: Consumer<AuthViewModel>(
          builder: (context, authViewModel, _) {
            if (authViewModel.isAuthenticated) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
        // Rutas nombradas para navegación.
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }
}
