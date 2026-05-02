import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../moduloTareas/viewmodels/tasks_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'componet/tarea_card_widget.dart';
import 'routine_detail_view.dart';

class TareasMainHub extends StatefulWidget {
  const TareasMainHub({super.key});

  @override
  State<TareasMainHub> createState() => _TareasMainHubState();
}

class _TareasMainHubState extends State<TareasMainHub> {
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      _lastUserId = context.read<AuthViewModel>().currentUser?.id;
      context.read<TasksViewModel>().loadTasks();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authViewModel = context.watch<AuthViewModel>();
    final currentUserId = authViewModel.currentUser?.id;

    if (currentUserId != null && currentUserId != _lastUserId) {
      _lastUserId = currentUserId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<TasksViewModel>().loadTasks();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            "Mis Actividades",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: false,
          bottom: TabBar(
            indicatorColor: AppColors.mint,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppColors.mint,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            tabs: const [
              Tab(text: "Pendientes"),
              Tab(text: "Completadas"),
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
    final vm = context.watch<TasksViewModel>();
    final list = isPending ? vm.pendingTasks : vm.completedTasks;

    if (vm.isLoading && list.isEmpty) {
      return Center(child: CircularProgressIndicator(color: AppColors.mint));
    }

    if (vm.error != null && list.isEmpty) {
      return _buildErrorState(vm);
    }

    if (list.isEmpty) {
      return _buildEmptyState(context, vm);
    }

    return RefreshIndicator(
      color: AppColors.mint,
      onRefresh: () => vm.loadTasks(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
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

  Widget _buildErrorState(TasksViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              vm.error ?? "No se pudieron cargar las tareas",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => vm.loadTasks(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
              ),
              child: const Text("Reintentar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, TasksViewModel vm) {
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
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPending
                        ? Icons.auto_awesome_rounded
                        : Icons.task_alt_rounded,
                    size: 64,
                    color: AppColors.mint.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isPending ? "¡Todo al día!" : "Aún no hay tareas completadas",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    isPending
                        ? "No tienes tareas pendientes asignadas por tu psicóloga."
                        : "Tus actividades terminadas aparecerán aquí.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
