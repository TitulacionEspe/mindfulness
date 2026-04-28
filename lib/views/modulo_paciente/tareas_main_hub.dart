import 'package:flutter/material.dart';
import 'package:mindfulness_app/views/modulo_paciente/routine_detail_view.dart';
import 'package:provider/provider.dart';

import '../../moduloTareas/viewmodels/tasks_viewmodel.dart';
import 'componet/tarea_card_widget.dart';

class TareasMainHub extends StatefulWidget {
  const TareasMainHub({super.key});

  @override
  State<TareasMainHub> createState() => _TareasMainHubState();
}

class _TareasMainHubState extends State<TareasMainHub> {
  @override
  void initState() {
    super.initState();
    // Cargar tareas al entrar
    Future.microtask(() {
      if (!mounted) return;
      context.read<TasksViewModel>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mis Actividades Asignadas"),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.cyanAccent,
            tabs: [
              Tab(text: "Pendientes", icon: Icon(Icons.pending_actions)),
              Tab(text: "Completadas", icon: Icon(Icons.task_alt)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TaskListView(isPending: true),
            _TaskListView(isPending: false),
          ],
        ),
      ),
    );
  }
}

class _TaskListView extends StatelessWidget {
  final bool isPending;
  const _TaskListView({required this.isPending});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el ViewModel completo para cualquier cambio
    final vm = context.watch<TasksViewModel>();
    final list = isPending ? vm.pendingTasks : vm.completedTasks;

    if (vm.isLoading && list.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null && list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                vm.error ?? "Ocurrió un error inesperado",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => vm.loadTasks(),
                child: const Text("Reintentar"),
              ),
            ],
          ),
        ),
      );
    }

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => vm.loadTasks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPending ? Icons.auto_awesome : Icons.history_edu,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPending
                        ? "¡No tienes tareas pendientes!\nBuen trabajo."
                        : "Aún no has completado actividades.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.loadTasks(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final task = list[index];
          return TareaCardWidget(
            key: ValueKey(task.id),
            tarea: task,
            isPending: isPending,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoutineDetailView(
                    routine: task.toRoutineModel(),
                    assignmentId: task.id,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
