import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importaciones de tus archivos (Ajusta las rutas según tu carpetas)
import 'core/config/supabase_config.dart';
import 'core/theme/app_colors.dart';
import 'viewmodels/psicologa_nav_viewmodel.dart';
import 'views/modulo_psicologa/psicologa_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicialización de Supabase (Motor de datos)
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tesis Mindfulness',
      // Aplicamos tus colores personalizados
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // Invocamos directamente tu módulo de Psicóloga
      home: const PsicologaWrapper(), 
    );
  }
}
