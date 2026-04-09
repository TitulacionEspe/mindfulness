import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quita la banda roja de "Debug"
      title: 'Tesis Mindfulness',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), // Color más zen para mindfulness
        useMaterial3: true,
      ),
      // Llamamos a nuestra función/clase principal
      home: const MainScreen(), 
    );
  }
}

// --- SECCIÓN DE COMPONENTES ORDENADOS ---

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // Llamada a función
      body: _buildBody(),      // Llamada a función
    );
  }

  // FUNCIÓN: Construye la barra superior
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Mindfulness App'),
      backgroundColor: Colors.teal.shade100,
      centerTitle: true,
    );
  }

  // FUNCIÓN: Construye el cuerpo de la app
  Widget _buildBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeaderSection(), // Otra función interna para más orden
            const SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return const Column(
      children: [
        Icon(Icons.self_improvement, size: 80, color: Colors.teal),
        SizedBox(height: 10),
        Text(
          'Bienvenido a tu sesión',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return ElevatedButton.icon(
      onPressed: () => print("Iniciando meditación..."),
      icon: const Icon(Icons.play_arrow),
      label: const Text('Comenzar Meditación'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
    );
  }
}