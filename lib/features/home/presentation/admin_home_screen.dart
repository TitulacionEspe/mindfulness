import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../admin/domain/entities/admin_models.dart';
import '../../admin/presentation/viewmodels/admin_panel_viewmodel.dart';
import '../../auth/domain/entities/user_role.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    if (!authViewModel.isAdmin) {
      return _AdminAccessDenied(onSignOut: authViewModel.signOut);
    }

    return ChangeNotifierProvider(
      create: (_) => AdminPanelViewModel()..initialize(),
      child: const _AdminPanelShell(),
    );
  }
}

class _AdminAccessDenied extends StatelessWidget {
  const _AdminAccessDenied({required this.onSignOut});

  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Acceso restringido',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu cuenta no tiene permisos de Administrador.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onSignOut,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Salir'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminPanelShell extends StatelessWidget {
  const _AdminPanelShell();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminPanelViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(viewModel.selectedSection.label),
        actions: [
          Tooltip(
            message: 'Actualizar',
            child: IconButton(
              onPressed: viewModel.isInitializing
                  ? null
                  : () => viewModel.initialize(),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
          Tooltip(
            message: 'Cerrar sesion',
            child: IconButton(
              onPressed: authViewModel.signOut,
              icon: const Icon(Icons.logout_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = _AdminSectionContent(viewModel: viewModel);
            if (constraints.maxWidth >= 760) {
              return Row(
                children: [
                  _AdminNavigationRail(viewModel: viewModel),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AppColors.outlineVariant,
                  ),
                  Expanded(child: content),
                ],
              );
            }

            return Column(
              children: [
                _AdminSectionTabs(viewModel: viewModel),
                Expanded(child: content),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AdminNavigationRail extends StatelessWidget {
  const _AdminNavigationRail({required this.viewModel});

  final AdminPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: AppColors.background,
      selectedIndex: AdminSection.values.indexOf(viewModel.selectedSection),
      onDestinationSelected: (index) =>
          viewModel.selectSection(AdminSection.values[index]),
      labelType: NavigationRailLabelType.all,
      selectedIconTheme: IconThemeData(color: AppColors.mint),
      selectedLabelTextStyle: TextStyle(
        color: AppColors.mint,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      unselectedIconTheme: IconThemeData(color: AppColors.textSecondary),
      unselectedLabelTextStyle: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      destinations: AdminSection.values
          .map(
            (section) => NavigationRailDestination(
              icon: Icon(_sectionIcon(section)),
              selectedIcon: Icon(_sectionSelectedIcon(section)),
              label: Text(section.label),
            ),
          )
          .toList(),
    );
  }
}

class _AdminSectionTabs extends StatelessWidget {
  const _AdminSectionTabs({required this.viewModel});

  final AdminPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final section = AdminSection.values[index];
          final selected = section == viewModel.selectedSection;
          return FilterChip(
            selected: selected,
            showCheckmark: false,
            avatar: Icon(
              _sectionIcon(section),
              size: 18,
              color: selected ? AppColors.buttonPrimaryText : AppColors.mint,
            ),
            label: Text(section.label),
            onSelected: (_) => viewModel.selectSection(section),
            selectedColor: AppColors.buttonPrimary,
            backgroundColor: AppColors.surface,
            labelStyle: TextStyle(
              color: selected
                  ? AppColors.buttonPrimaryText
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: AdminSection.values.length,
      ),
    );
  }
}

class _AdminSectionContent extends StatelessWidget {
  const _AdminSectionContent({required this.viewModel});

  final AdminPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final child = switch (viewModel.selectedSection) {
      AdminSection.dashboard => _AdminDashboardView(viewModel: viewModel),
      AdminSection.users => _AdminUsersView(viewModel: viewModel),
      AdminSection.roles => _AdminRolesView(viewModel: viewModel),
      AdminSection.content => _AdminContentView(viewModel: viewModel),
      AdminSection.media => _AdminMediaView(viewModel: viewModel),
      AdminSection.settings => _AdminSettingsView(viewModel: viewModel),
      AdminSection.legal => _AdminLegalView(viewModel: viewModel),
      AdminSection.metrics => _AdminMetricsView(viewModel: viewModel),
    };

    return Column(
      children: [
        if (viewModel.errorMessage != null)
          _FeedbackBanner(
            message: viewModel.errorMessage!,
            isError: true,
            onDismiss: viewModel.clearFeedback,
          ),
        if (viewModel.successMessage != null)
          _FeedbackBanner(
            message: viewModel.successMessage!,
            isError: false,
            onDismiss: viewModel.clearFeedback,
          ),
        Expanded(child: child),
      ],
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? AppColors.tertiaryBg : AppColors.successBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isError ? AppColors.error : AppColors.mint),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: isError ? AppColors.error : AppColors.mint,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Cerrar',
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView({required this.viewModel});

  final AdminPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final summary = viewModel.summary;
    return _AdminScrollPage(
      children: [
        _SectionHeader(
          title: 'Panel administrativo',
          subtitle:
              'Control operativo del sistema sin exponer informacion sensible.',
          trailing: _RefreshButton(
            isLoading: viewModel.isLoadingDashboard,
            onPressed: viewModel.loadDashboard,
          ),
        ),
        if (viewModel.isLoadingDashboard)
          const _LoadingBlock(label: 'Cargando resumen del sistema')
        else ...[
          _MetricGrid(
            cards: [
              _MetricCardData(
                title: 'Usuarios',
                value: '${summary.totalUsers}',
                icon: Icons.groups_2_outlined,
                color: AppColors.mint,
              ),
              _MetricCardData(
                title: 'Pacientes',
                value: '${summary.patients}',
                icon: Icons.person_outline_rounded,
                color: AppColors.lavender,
              ),
              _MetricCardData(
                title: 'Profesionales',
                value: '${summary.professionals}',
                icon: Icons.badge_outlined,
                color: AppColors.tertiary,
              ),
              _MetricCardData(
                title: 'Administradores',
                value: '${summary.admins}',
                icon: Icons.admin_panel_settings_outlined,
                color: AppColors.mint,
              ),
              _MetricCardData(
                title: 'Activas',
                value: '${summary.activeAccounts}',
                icon: Icons.verified_user_outlined,
                color: AppColors.mint,
              ),
              _MetricCardData(
                title: 'Inactivas',
                value: '${summary.inactiveAccounts + summary.blockedAccounts}',
                icon: Icons.no_accounts_outlined,
                color: AppColors.error,
              ),
              _MetricCardData(
                title: 'Rutinas',
                value: '${summary.routinesActive}/${summary.routinesTotal}',
                icon: Icons.self_improvement_outlined,
                color: AppColors.lavender,
              ),
              _MetricCardData(
                title: 'Recursos',
                value: '${summary.assetsTotal}',
                icon: Icons.library_music_outlined,
                color: AppColors.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AdminCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accesos rapidos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _QuickActionGrid(
                  actions: [
                    _QuickActionData(
                      title: 'Gestionar usuarios',
                      icon: Icons.manage_accounts_outlined,
                      onTap: () => viewModel.selectSection(AdminSection.users),
                    ),
                    _QuickActionData(
                      title: 'Roles y permisos',
                      icon: Icons.security_outlined,
                      onTap: () => viewModel.selectSection(AdminSection.roles),
                    ),
                    _QuickActionData(
                      title: 'Contenidos base',
                      icon: Icons.widgets_outlined,
                      onTap: () =>
                          viewModel.selectSection(AdminSection.content),
                    ),
                    _QuickActionData(
                      title: 'Configuracion',
                      icon: Icons.tune_rounded,
                      onTap: () =>
                          viewModel.selectSection(AdminSection.settings),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AdminUsersView extends StatelessWidget {
  const _AdminUsersView({required this.viewModel});

  final AdminPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return _AdminScrollPage(
      children: [
        _SectionHeader(
          title: 'Gestion de usuarios',
          subtitle: 'Datos administrativos: rol, estado y fecha de creacion.',
          trailing: _RefreshButton(
            isLoading: viewModel.isLoadingUsers,
            onPressed: viewModel.loadUsers,
          ),
        ),
        _UserFilters(viewModel: viewModel),
        const SizedBox(height: 12),
        if (viewModel.isLoadingUsers)
          const _LoadingBlock(label: 'Cargando usuarios')
        else if (viewModel.filteredUsers.isEmpty)
          const _EmptyBlock(
            icon: Icons.manage_search_rounded,
            title: 'Sin usuarios para mostrar',
            subtitle: 'Ajusta la busqueda o limpia los filtros.',
          )
        else
          ...viewModel.filteredUsers.map(
            (user) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _UserTile(
                user: user,
                onDetails: () => _showUserDetailSheet(
                  context,
                  viewModel: viewModel,
                  user: user,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AdminRolesView extends StatelessWidget {
  const _AdminRolesView({required this.viewModel});

  final AdminPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return _AdminScrollPage(
      children: [
        _SectionHeader(
          title: 'Roles y permisos',
          subtitle:
              'Cambios controlados con prevencion de configuraciones inseguras.',
          trailing: _RefreshButton(
            isLoading: viewModel.isLoadingUsers,
            onPressed: viewModel.loadUsers,
          ),
        ),
        _AdminCard(
          child: Row(
            children: [
              Icon(Icons.verified_user_outlined, color: AppColors.mint),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Administradores activos: ${viewModel.activeAdminCount}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (viewModel.isLoadingUsers)
          const _LoadingBlock(label: 'Cargando permisos')
        else
          ...viewModel.users.map(
            (user) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RoleManagementTile(user: user, viewModel: viewModel),
            ),
          ),
      ],
    );
  }
}

class _AdminContentView extends StatelessWidget {
  const _AdminContentView({required this.viewModel});

  final AdminPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return _AdminScrollPage(
      children: [
        _SectionHeader(
          title: 'Contenidos base',
          subtitle: 'Rutinas, ejercicios y mensajes visibles para Pacientes.',
          trailing: ElevatedButton.icon(
            onPressed: viewModel.isSaving
                ? null
                : () => _showContentDialog(context, viewModel: viewModel),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear'),
          ),
        ),
        _ContentFilters(viewModel: viewModel),
        const SizedBox(height: 12),
        if (viewModel.isLoadingContent)
          const _LoadingBlock(label: 'Cargando contenidos')
        else if (viewModel.filteredContentItems.isEmpty)
          const _EmptyBlock(
            icon: Icons.widgets_outlined,
            title: 'Sin contenidos',
            subtitle: 'Crea una rutina o mensaje de orientacion.',
          )
        else
          ...viewModel.filteredContentItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ContentTile(item: item, viewModel: viewModel),
            ),
          ),
      ],
    );
  }
}

class _AdminMediaView extends StatelessWidget {
  const _AdminMediaView({required this.viewModel});

  final AdminPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final routines = viewModel.contentItems
        .where((item) => item.type == AdminContentType.routine)
        .toList();

    return _AdminScrollPage(
      children: [
        _SectionHeader(
          title: 'Recursos multimedia',
          subtitle: 'Asociacion controlada de audios a rutinas.',
          trailing: ElevatedButton.icon(
            onPressed: viewModel.isSaving || routines.isEmpty
                ? null
                : () => _showMediaAssetDialog(
                    context,
                    viewModel: viewModel,
                    routines: routines,
                  ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Asociar'),
          ),
        ),
        if (routines.isEmpty)
          const _EmptyBlock(
            icon: Icons.self_improvement_outlined,
            title: 'Crea una rutina primero',
            subtitle: 'Los audios se asocian a rutinas existentes.',
          )
        else if (viewModel.isLoadingMedia)
          const _LoadingBlock(label: 'Cargando recursos')
        else if (viewModel.mediaAssets.isEmpty)
          const _EmptyBlock(
            icon: Icons.library_music_outlined,
            title: 'Sin recursos multimedia',
            subtitle: 'Asocia archivos existentes de Supabase Storage.',
          )
        else
          ...viewModel.mediaAssets.map(
            (asset) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MediaTile(
                asset: asset,
                onEdit: () => _showMediaAssetDialog(
                  context,
                  viewModel: viewModel,
                  routines: routines,
                  asset: asset,
                ),
                onToggle: () => _confirmAndRun(
                  context,
                  title: asset.isActive
                      ? 'Desactivar recurso'
                      : 'Activar recurso',
                  message:
                      'El cambio afectara la disponibilidad del audio asociado.',
                  onConfirm: () => viewModel.updateMediaAssetStatus(
                    assetId: asset.id,
                    isActive: !asset.isActive,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AdminSettingsView extends StatefulWidget {
  const _AdminSettingsView({required this.viewModel});

  final AdminPanelViewModel viewModel;

  @override
  State<_AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<_AdminSettingsView> {
  late TextEditingController _noticeController;
  late TextEditingController _orientationController;
  late TextEditingController _consentVersionController;
  late int _duration;
  late String _defaultTheme;
  late bool _darkModeEnabled;
  late bool _professionalModuleEnabled;
  late bool _assignmentEnabled;
  late bool _contentValidationEnabled;

  @override
  void initState() {
    super.initState();
    _syncFromSettings();
  }

  @override
  void didUpdateWidget(covariant _AdminSettingsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.settings != widget.viewModel.settings) {
      _disposeControllers();
      _syncFromSettings();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _noticeController.dispose();
    _orientationController.dispose();
    _consentVersionController.dispose();
  }

  void _syncFromSettings() {
    final settings = widget.viewModel.settings;
    _noticeController = TextEditingController(
      text: settings.responsibleUseNotice,
    );
    _orientationController = TextEditingController(
      text: settings.generalOrientationMessage,
    );
    _consentVersionController = TextEditingController(
      text: settings.activeConsentVersion,
    );
    _duration = settings.recommendedSessionDurationMinutes;
    _defaultTheme = settings.defaultTheme;
    _darkModeEnabled = settings.darkModeEnabled;
    _professionalModuleEnabled = settings.professionalModuleEnabled;
    _assignmentEnabled = settings.patientProfessionalAssignmentEnabled;
    _contentValidationEnabled = settings.contentValidationEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return _AdminScrollPage(
      children: [
        _SectionHeader(
          title: 'Configuracion general',
          subtitle: 'Parametros globales controlados solo por Administradores.',
          trailing: _RefreshButton(
            isLoading: viewModel.isLoadingSettings,
            onPressed: viewModel.loadSystemSettings,
          ),
        ),
        if (viewModel.isLoadingSettings)
          const _LoadingBlock(label: 'Cargando configuracion')
        else
          _AdminCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Experiencia',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _defaultTheme,
                  decoration: const InputDecoration(
                    labelText: 'Tema predeterminado',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'light', child: Text('Claro')),
                    DropdownMenuItem(value: 'dark', child: Text('Oscuro')),
                  ],
                  onChanged: (value) =>
                      setState(() => _defaultTheme = value ?? 'light'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _darkModeEnabled,
                  onChanged: (value) =>
                      setState(() => _darkModeEnabled = value),
                  title: const Text('Modo oscuro disponible'),
                  subtitle: const Text('Preferencia configurable por usuario.'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Duracion recomendada: $_duration min',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Slider(
                  value: _duration.toDouble(),
                  min: 1,
                  max: 45,
                  divisions: 44,
                  label: '$_duration min',
                  activeColor: AppColors.mint,
                  inactiveColor: AppColors.surfaceHighest,
                  onChanged: (value) =>
                      setState(() => _duration = value.round().clamp(1, 45)),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _noticeController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Aviso de uso responsable',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _orientationController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje general de orientacion',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _consentVersionController,
                  decoration: const InputDecoration(
                    labelText: 'Version activa del consentimiento',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Preparacion modulo Profesional',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SwitchListTile(
                  value: _professionalModuleEnabled,
                  onChanged: (value) =>
                      setState(() => _professionalModuleEnabled = value),
                  title: const Text('Modulo Profesional habilitado'),
                ),
                SwitchListTile(
                  value: _assignmentEnabled,
                  onChanged: (value) =>
                      setState(() => _assignmentEnabled = value),
                  title: const Text('Asignacion Paciente-Profesional'),
                ),
                SwitchListTile(
                  value: _contentValidationEnabled,
                  onChanged: (value) =>
                      setState(() => _contentValidationEnabled = value),
                  title: const Text('Validacion profesional de contenidos'),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: viewModel.isSaving
                      ? null
                      : () => viewModel.saveSystemSettings(
                          viewModel.settings.copyWith(
                            defaultTheme: _defaultTheme,
                            darkModeEnabled: _darkModeEnabled,
                            responsibleUseNotice: _noticeController.text.trim(),
                            generalOrientationMessage: _orientationController
                                .text
                                .trim(),
                            recommendedSessionDurationMinutes: _duration,
                            professionalModuleEnabled:
                                _professionalModuleEnabled,
                            patientProfessionalAssignmentEnabled:
                                _assignmentEnabled,
                            contentValidationEnabled: _contentValidationEnabled,
                            activeConsentVersion: _consentVersionController.text
                                .trim(),
                          ),
                        ),
                  icon: viewModel.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Guardar configuracion'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AdminLegalView extends StatelessWidget {
  const _AdminLegalView({required this.viewModel});

  final AdminPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return _AdminScrollPage(
      children: [
        _SectionHeader(
          title: 'Consentimiento y avisos',
          subtitle:
              'Versiones institucionales sobre confidencialidad y limites de uso.',
          trailing: ElevatedButton.icon(
            onPressed: viewModel.isSaving
                ? null
                : () => _showLegalDocumentDialog(context, viewModel: viewModel),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear'),
          ),
        ),
        if (viewModel.isLoadingSettings)
          const _LoadingBlock(label: 'Cargando documentos')
        else if (viewModel.legalDocuments.isEmpty)
          const _EmptyBlock(
            icon: Icons.policy_outlined,
            title: 'Sin documentos',
            subtitle: 'Crea consentimiento o aviso de uso responsable.',
          )
        else
          ...viewModel.legalDocuments.map(
            (document) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LegalDocumentTile(
                document: document,
                onEdit: () => _showLegalDocumentDialog(
                  context,
                  viewModel: viewModel,
                  document: document,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AdminMetricsView extends StatelessWidget {
  const _AdminMetricsView({required this.viewModel});

  final AdminPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final summary = viewModel.summary;
    return _AdminScrollPage(
      children: [
        _SectionHeader(
          title: 'Metricas globales',
          subtitle:
              'Indicadores agregados. No se muestran pensamientos ni emociones individuales.',
          trailing: _RefreshButton(
            isLoading: viewModel.isLoadingDashboard,
            onPressed: viewModel.loadDashboard,
          ),
        ),
        if (viewModel.isLoadingDashboard)
          const _LoadingBlock(label: 'Cargando metricas')
        else ...[
          _MetricGrid(
            cards: [
              _MetricCardData(
                title: 'Usuarios activos',
                value: '${summary.activeAccounts}',
                icon: Icons.verified_outlined,
                color: AppColors.mint,
              ),
              _MetricCardData(
                title: 'Sesiones registradas',
                value: '${summary.sessionsTotal}',
                icon: Icons.timeline_outlined,
                color: AppColors.lavender,
              ),
              _MetricCardData(
                title: 'Sesiones completadas',
                value: '${summary.sessionsCompleted}',
                icon: Icons.task_alt_outlined,
                color: AppColors.mint,
              ),
              _MetricCardData(
                title: 'Dias activos 30d',
                value: '${summary.activeDays30}',
                icon: Icons.calendar_month_outlined,
                color: AppColors.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AdminCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actividad reciente',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (summary.activityByPeriod.isEmpty)
                  Text(
                    'Sin actividad agregada en los ultimos 7 dias.',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else
                  ...summary.activityByPeriod.map(
                    (item) => _ActivityBar(metric: item),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _AdminCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usuarios por rol',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _RoleDistributionRow(
                  label: 'Pacientes',
                  value: summary.patients,
                  total: summary.totalUsers,
                ),
                _RoleDistributionRow(
                  label: 'Profesionales',
                  value: summary.professionals,
                  total: summary.totalUsers,
                ),
                _RoleDistributionRow(
                  label: 'Administradores',
                  value: summary.admins,
                  total: summary.totalUsers,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AdminScrollPage extends StatelessWidget {
  const _AdminScrollPage({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: children,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );

    if (trailing == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: titleBlock,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 680;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleBlock,
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 48,
                      maxWidth: 240,
                    ),
                    child: trailing!,
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleBlock),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48, maxWidth: 240),
                child: trailing!,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: child,
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: AppColors.mint),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Column(
        children: [
          Icon(icon, size: 38, color: AppColors.lavender),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Actualizar',
      child: IconButton.filledTonal(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.refresh_rounded),
      ),
    );
  }
}

class _MetricCardData {
  const _MetricCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.cards});

  final List<_MetricCardData> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 820
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        final childAspectRatio = switch (crossAxisCount) {
          4 => 2.1,
          2 => 2.2,
          _ => 3.0,
        };
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) => _MetricCard(data: cards[index]),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricCardData data;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Icon(data.icon, color: data.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  data.title,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({required this.actions});

  final List<_QuickActionData> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.4,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: action.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(action.icon, color: AppColors.mint),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        action.title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _UserFilters extends StatelessWidget {
  const _UserFilters({required this.viewModel});

  final AdminPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Column(
        children: [
          TextField(
            onChanged: viewModel.setUserSearchQuery,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              labelText: 'Buscar por nombre, correo o rol',
            ),
          ),
          const SizedBox(height: 12),
          _ResponsiveDropdownPair(
            first: DropdownButtonFormField<UserRole?>(
              initialValue: viewModel.roleFilter,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Rol'),
              items: [
                const DropdownMenuItem<UserRole?>(
                  value: null,
                  child: Text('Todos'),
                ),
                ...UserRole.values.map(
                  (role) => DropdownMenuItem<UserRole?>(
                    value: role,
                    child: Text(_roleLabel(role)),
                  ),
                ),
              ],
              onChanged: viewModel.setRoleFilter,
            ),
            second: DropdownButtonFormField<AdminAccountStatus?>(
              initialValue: viewModel.accountStatusFilter,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: [
                const DropdownMenuItem<AdminAccountStatus?>(
                  value: null,
                  child: Text('Todos'),
                ),
                ...AdminAccountStatus.values.map(
                  (status) => DropdownMenuItem<AdminAccountStatus?>(
                    value: status,
                    child: Text(status.label),
                  ),
                ),
              ],
              onChanged: viewModel.setAccountStatusFilter,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveDropdownPair extends StatelessWidget {
  const _ResponsiveDropdownPair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;

        if (compact) {
          return Column(children: [first, const SizedBox(height: 10), second]);
        }

        return Row(
          children: [
            Expanded(child: first),
            const SizedBox(width: 10),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.onDetails});

  final AdminUserAccount user;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceHigh,
            child: Icon(Icons.person_outline, color: AppColors.mint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email.isEmpty ? 'Correo no sincronizado' : user.email,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _StatusChip(
                      label: _roleLabel(user.role),
                      tone: _roleTone(user.role),
                    ),
                    _StatusChip(
                      label: user.status.label,
                      tone: _statusTone(user.status),
                    ),
                    _StatusChip(
                      label: _dateLabel(user.createdAt),
                      tone: _ChipTone.neutral,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Detalle administrativo',
            onPressed: onDetails,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _RoleManagementTile extends StatelessWidget {
  const _RoleManagementTile({required this.user, required this.viewModel});

  final AdminUserAccount user;
  final AdminPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.fullName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            user.email.isEmpty ? user.id : user.email,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          _ResponsiveDropdownPair(
            first: DropdownButtonFormField<UserRole>(
              initialValue: user.role,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Rol'),
              items: UserRole.values
                  .map(
                    (role) => DropdownMenuItem(
                      value: role,
                      child: Text(_roleLabel(role)),
                    ),
                  )
                  .toList(),
              onChanged: viewModel.isSaving
                  ? null
                  : (role) {
                      if (role == null || role == user.role) return;
                      _confirmAndRun(
                        context,
                        title: 'Cambiar rol',
                        message:
                            'El usuario tendra acceso a las vistas del rol ${_roleLabel(role)}.',
                        onConfirm: () => viewModel.changeUserRole(user, role),
                      );
                    },
            ),
            second: DropdownButtonFormField<AdminAccountStatus>(
              initialValue: user.status,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: AdminAccountStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              onChanged: viewModel.isSaving
                  ? null
                  : (status) {
                      if (status == null || status == user.status) return;
                      _confirmAndRun(
                        context,
                        title: 'Cambiar estado',
                        message:
                            'El acceso protegido se actualizara segun el nuevo estado.',
                        onConfirm: () =>
                            viewModel.changeUserStatus(user, status),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentFilters extends StatelessWidget {
  const _ContentFilters({required this.viewModel});

  final AdminPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: _ResponsiveDropdownPair(
        first: DropdownButtonFormField<AdminContentType?>(
          initialValue: viewModel.contentTypeFilter,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Tipo'),
          items: [
            const DropdownMenuItem<AdminContentType?>(
              value: null,
              child: Text('Todos'),
            ),
            ...AdminContentType.values.map(
              (type) => DropdownMenuItem<AdminContentType?>(
                value: type,
                child: Text(type.label),
              ),
            ),
          ],
          onChanged: viewModel.setContentTypeFilter,
        ),
        second: DropdownButtonFormField<AdminContentStatus?>(
          initialValue: viewModel.contentStatusFilter,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Estado'),
          items: [
            const DropdownMenuItem<AdminContentStatus?>(
              value: null,
              child: Text('Todos'),
            ),
            ...AdminContentStatus.values.map(
              (status) => DropdownMenuItem<AdminContentStatus?>(
                value: status,
                child: Text(status.label),
              ),
            ),
          ],
          onChanged: viewModel.setContentStatusFilter,
        ),
      ),
    );
  }
}

class _ContentTile extends StatelessWidget {
  const _ContentTile({required this.item, required this.viewModel});

  final AdminContentItem item;
  final AdminPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                item.type == AdminContentType.message
                    ? Icons.message_outlined
                    : Icons.self_improvement_outlined,
                color: AppColors.mint,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Editar',
                onPressed: viewModel.isSaving
                    ? null
                    : () => _showContentDialog(
                        context,
                        viewModel: viewModel,
                        item: item,
                      ),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _StatusChip(label: item.type.label, tone: _ChipTone.neutral),
              _StatusChip(
                label: item.status.label,
                tone: _contentTone(item.status),
              ),
              _StatusChip(
                label: item.isVisibleToPatients
                    ? 'Visible a Pacientes'
                    : 'No visible',
                tone: item.isVisibleToPatients
                    ? _ChipTone.success
                    : _ChipTone.warning,
              ),
              if (item.type == AdminContentType.routine)
                _StatusChip(
                  label: '${item.durationLabel} | Audios ${item.assetCount}',
                  tone: _ChipTone.neutral,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: viewModel.isSaving
                      ? null
                      : () => _confirmAndRun(
                          context,
                          title: item.status == AdminContentStatus.active
                              ? 'Desactivar contenido'
                              : 'Publicar contenido',
                          message:
                              'El cambio afectara la visibilidad para Pacientes.',
                          onConfirm: () => viewModel.updateContentStatus(
                            item: item,
                            status: item.status == AdminContentStatus.active
                                ? AdminContentStatus.inactive
                                : AdminContentStatus.active,
                            isVisibleToPatients:
                                item.status != AdminContentStatus.active,
                          ),
                        ),
                  icon: Icon(
                    item.status == AdminContentStatus.active
                        ? Icons.visibility_off_outlined
                        : Icons.publish_outlined,
                  ),
                  label: Text(
                    item.status == AdminContentStatus.active
                        ? 'Desactivar'
                        : 'Publicar',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.asset,
    required this.onEdit,
    required this.onToggle,
  });

  final AdminMediaAsset asset;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.library_music_outlined, color: AppColors.lavender),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  asset.routineTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Editar recurso',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            '${asset.storageBucket}/${asset.storagePath}',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _StatusChip(
                label: asset.isActive ? 'Activo' : 'Inactivo',
                tone: asset.isActive ? _ChipTone.success : _ChipTone.warning,
              ),
              _StatusChip(label: asset.fileType, tone: _ChipTone.neutral),
              _StatusChip(label: asset.fileSizeLabel, tone: _ChipTone.neutral),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onToggle,
            icon: Icon(
              asset.isActive
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
            ),
            label: Text(asset.isActive ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }
}

class _LegalDocumentTile extends StatelessWidget {
  const _LegalDocumentTile({required this.document, required this.onEdit});

  final AdminLegalDocument document;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.policy_outlined, color: AppColors.mint),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  document.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Editar documento',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            document.body,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _StatusChip(label: document.typeLabel, tone: _ChipTone.neutral),
              _StatusChip(
                label: 'v${document.version}',
                tone: _ChipTone.neutral,
              ),
              _StatusChip(
                label: document.status.label,
                tone: _contentTone(document.status),
              ),
              if (document.isCurrent)
                const _StatusChip(label: 'Vigente', tone: _ChipTone.success),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityBar extends StatelessWidget {
  const _ActivityBar({required this.metric});

  final AdminActivityMetric metric;

  @override
  Widget build(BuildContext context) {
    final normalized = (metric.sessions / 10).clamp(0.08, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.dateLabel,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Text(
                '${metric.sessions}',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: normalized,
              color: AppColors.mint,
              backgroundColor: AppColors.surfaceHigh,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleDistributionRow extends StatelessWidget {
  const _RoleDistributionRow({
    required this.label,
    required this.value,
    required this.total,
  });

  final String label;
  final int value;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0.0 : value / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Text(
                '$value',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            minHeight: 8,
            value: percentage,
            color: AppColors.lavender,
            backgroundColor: AppColors.surfaceHigh,
          ),
        ],
      ),
    );
  }
}

enum _ChipTone { success, warning, alert, neutral }

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.tone});

  final String label;
  final _ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final background = switch (tone) {
      _ChipTone.success => AppColors.successBg,
      _ChipTone.warning => AppColors.warningBg,
      _ChipTone.alert => AppColors.tertiaryBg,
      _ChipTone.neutral => AppColors.surfaceHigh,
    };
    final foreground = switch (tone) {
      _ChipTone.success => AppColors.mint,
      _ChipTone.warning => AppColors.lavender,
      _ChipTone.alert => AppColors.tertiary,
      _ChipTone.neutral => AppColors.textSecondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Future<void> _showUserDetailSheet(
  BuildContext context, {
  required AdminPanelViewModel viewModel,
  required AdminUserAccount user,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalle administrativo',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 16),
              _DetailRow(label: 'Nombre', value: user.fullName),
              _DetailRow(
                label: 'Correo',
                value: user.email.isEmpty ? 'No sincronizado' : user.email,
              ),
              _DetailRow(label: 'Rol', value: _roleLabel(user.role)),
              _DetailRow(label: 'Estado', value: user.status.label),
              _DetailRow(label: 'Segmento', value: user.segment),
              _DetailRow(label: 'Tema', value: user.themeMode),
              _DetailRow(label: 'Creacion', value: _dateLabel(user.createdAt)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Cerrar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        viewModel.selectSection(AdminSection.roles);
                      },
                      icon: const Icon(Icons.security_outlined),
                      label: const Text('Editar rol'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showContentDialog(
  BuildContext context, {
  required AdminPanelViewModel viewModel,
  AdminContentItem? item,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ContentFormDialog(viewModel: viewModel, item: item),
  );
}

class _ContentFormDialog extends StatefulWidget {
  const _ContentFormDialog({required this.viewModel, this.item});

  final AdminPanelViewModel viewModel;
  final AdminContentItem? item;

  @override
  State<_ContentFormDialog> createState() => _ContentFormDialogState();
}

class _ContentFormDialogState extends State<_ContentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _durationController;
  late AdminContentType _type;
  late AdminContentStatus _status;
  late bool _visible;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _type = item?.type ?? AdminContentType.routine;
    _status = item?.status ?? AdminContentStatus.draft;
    _visible = item?.isVisibleToPatients ?? false;
    _titleController = TextEditingController(text: item?.title ?? '');
    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    _categoryController = TextEditingController(
      text: item?.category ?? 'relaxation',
    );
    _durationController = TextEditingController(
      text: (item?.durationSeconds ?? 180).toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Crear contenido' : 'Editar contenido'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<AdminContentType>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: AdminContentType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ),
                      )
                      .toList(),
                  onChanged: widget.item == null
                      ? (value) => setState(
                          () => _type = value ?? AdminContentType.routine,
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Titulo'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingresa un titulo'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: _type == AdminContentType.message
                        ? 'Mensaje'
                        : 'Descripcion',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingresa el contenido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: _type == AdminContentType.message
                        ? 'Categoria'
                        : 'Categoria de rutina',
                    helperText:
                        'Rutinas: relaxation, breathing, sleep_induction, soundscape',
                  ),
                ),
                if (_type == AdminContentType.routine) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duracion en segundos',
                    ),
                    validator: (value) {
                      final parsed = int.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0 || parsed > 2700) {
                        return 'Usa un valor entre 1 y 2700';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<AdminContentStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: AdminContentStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => _status = value ?? AdminContentStatus.draft,
                  ),
                ),
                SwitchListTile(
                  value: _visible,
                  onChanged: (value) => setState(() => _visible = value),
                  title: const Text('Visible para Pacientes'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: widget.viewModel.isSaving ? null : _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final saved = await widget.viewModel.saveContentItem(
      id: widget.item?.id,
      type: _type,
      title: _titleController.text,
      description: _descriptionController.text,
      category: _categoryController.text.trim().isEmpty
          ? 'general'
          : _categoryController.text.trim(),
      status: _status,
      isVisibleToPatients: _visible,
      durationSeconds: int.tryParse(_durationController.text),
      existingItem: widget.item,
    );
    if (saved && mounted) Navigator.of(context).pop();
  }
}

Future<void> _showMediaAssetDialog(
  BuildContext context, {
  required AdminPanelViewModel viewModel,
  required List<AdminContentItem> routines,
  AdminMediaAsset? asset,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _MediaAssetFormDialog(
      viewModel: viewModel,
      routines: routines,
      asset: asset,
    ),
  );
}

class _MediaAssetFormDialog extends StatefulWidget {
  const _MediaAssetFormDialog({
    required this.viewModel,
    required this.routines,
    this.asset,
  });

  final AdminPanelViewModel viewModel;
  final List<AdminContentItem> routines;
  final AdminMediaAsset? asset;

  @override
  State<_MediaAssetFormDialog> createState() => _MediaAssetFormDialogState();
}

class _MediaAssetFormDialogState extends State<_MediaAssetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _routineId;
  late TextEditingController _bucketController;
  late TextEditingController _pathController;
  late TextEditingController _typeController;
  late TextEditingController _sizeController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _routineId = widget.asset?.routineId ?? widget.routines.first.id;
    _bucketController = TextEditingController(
      text: widget.asset?.storageBucket ?? 'routines',
    );
    _pathController = TextEditingController(text: widget.asset?.storagePath);
    _typeController = TextEditingController(
      text: widget.asset?.fileType ?? 'audio/mpeg',
    );
    _sizeController = TextEditingController(
      text: (widget.asset?.fileSizeBytes ?? 0).toString(),
    );
    _isActive = widget.asset?.isActive ?? true;
  }

  @override
  void dispose() {
    _bucketController.dispose();
    _pathController.dispose();
    _typeController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.asset == null ? 'Asociar audio' : 'Editar audio'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _routineId,
                  decoration: const InputDecoration(labelText: 'Rutina'),
                  items: widget.routines
                      .map(
                        (routine) => DropdownMenuItem(
                          value: routine.id,
                          child: Text(routine.title),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => _routineId = value ?? widget.routines.first.id,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bucketController,
                  decoration: const InputDecoration(labelText: 'Bucket'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pathController,
                  decoration: const InputDecoration(
                    labelText: 'Ruta del archivo',
                    helperText: 'Ej. audios/respiracion-4-6.mp3',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingresa la ruta del recurso'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _typeController,
                  decoration: const InputDecoration(labelText: 'Tipo MIME'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tamano en bytes',
                  ),
                ),
                SwitchListTile(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  title: const Text('Recurso activo'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: widget.viewModel.isSaving ? null : _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final saved = await widget.viewModel.saveMediaAsset(
      id: widget.asset?.id,
      routineId: _routineId,
      storageBucket: _bucketController.text,
      storagePath: _pathController.text,
      fileType: _typeController.text,
      fileSizeBytes: int.tryParse(_sizeController.text) ?? 0,
      isActive: _isActive,
    );
    if (saved && mounted) Navigator.of(context).pop();
  }
}

Future<void> _showLegalDocumentDialog(
  BuildContext context, {
  required AdminPanelViewModel viewModel,
  AdminLegalDocument? document,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) =>
        _LegalDocumentFormDialog(viewModel: viewModel, document: document),
  );
}

class _LegalDocumentFormDialog extends StatefulWidget {
  const _LegalDocumentFormDialog({required this.viewModel, this.document});

  final AdminPanelViewModel viewModel;
  final AdminLegalDocument? document;

  @override
  State<_LegalDocumentFormDialog> createState() =>
      _LegalDocumentFormDialogState();
}

class _LegalDocumentFormDialogState extends State<_LegalDocumentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _documentType;
  late AdminContentStatus _status;
  late bool _isCurrent;
  late TextEditingController _versionController;
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    final document = widget.document;
    _documentType = document?.documentType ?? 'consent';
    _status = document?.status ?? AdminContentStatus.draft;
    _isCurrent = document?.isCurrent ?? false;
    _versionController = TextEditingController(text: document?.version);
    _titleController = TextEditingController(text: document?.title);
    _bodyController = TextEditingController(text: document?.body);
  }

  @override
  void dispose() {
    _versionController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.document == null ? 'Crear documento' : 'Editar texto'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _documentType,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: const [
                    DropdownMenuItem(
                      value: 'consent',
                      child: Text('Consentimiento'),
                    ),
                    DropdownMenuItem(
                      value: 'responsible_use',
                      child: Text('Uso responsable'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _documentType = value ?? 'consent'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _versionController,
                  decoration: const InputDecoration(labelText: 'Version'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingresa version'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Titulo'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingresa titulo'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bodyController,
                  minLines: 5,
                  maxLines: 8,
                  decoration: const InputDecoration(labelText: 'Texto'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingresa texto'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AdminContentStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: AdminContentStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => _status = value ?? AdminContentStatus.draft,
                  ),
                ),
                SwitchListTile(
                  value: _isCurrent,
                  onChanged: (value) => setState(() => _isCurrent = value),
                  title: const Text('Version vigente'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: widget.viewModel.isSaving ? null : _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final saved = await widget.viewModel.saveLegalDocument(
      id: widget.document?.id,
      documentType: _documentType,
      version: _versionController.text,
      title: _titleController.text,
      body: _bodyController.text,
      status: _status,
      isCurrent: _isCurrent,
    );
    if (saved && mounted) Navigator.of(context).pop();
  }
}

Future<void> _confirmAndRun(
  BuildContext context, {
  required String title,
  required String message,
  required Future<bool> Function() onConfirm,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await onConfirm();
  }
}

IconData _sectionIcon(AdminSection section) {
  return switch (section) {
    AdminSection.dashboard => Icons.dashboard_outlined,
    AdminSection.users => Icons.people_alt_outlined,
    AdminSection.roles => Icons.security_outlined,
    AdminSection.content => Icons.widgets_outlined,
    AdminSection.media => Icons.library_music_outlined,
    AdminSection.settings => Icons.tune_outlined,
    AdminSection.legal => Icons.policy_outlined,
    AdminSection.metrics => Icons.insights_outlined,
  };
}

IconData _sectionSelectedIcon(AdminSection section) {
  return switch (section) {
    AdminSection.dashboard => Icons.dashboard_rounded,
    AdminSection.users => Icons.people_alt_rounded,
    AdminSection.roles => Icons.security_rounded,
    AdminSection.content => Icons.widgets_rounded,
    AdminSection.media => Icons.library_music_rounded,
    AdminSection.settings => Icons.tune_rounded,
    AdminSection.legal => Icons.policy_rounded,
    AdminSection.metrics => Icons.insights_rounded,
  };
}

String _roleLabel(UserRole role) {
  return switch (role) {
    UserRole.patient => 'Paciente',
    UserRole.professional => 'Profesional',
    UserRole.admin => 'Administrador',
  };
}

_ChipTone _roleTone(UserRole role) {
  return switch (role) {
    UserRole.patient => _ChipTone.neutral,
    UserRole.professional => _ChipTone.warning,
    UserRole.admin => _ChipTone.success,
  };
}

_ChipTone _statusTone(AdminAccountStatus status) {
  return switch (status) {
    AdminAccountStatus.active => _ChipTone.success,
    AdminAccountStatus.inactive => _ChipTone.warning,
    AdminAccountStatus.blocked => _ChipTone.alert,
  };
}

_ChipTone _contentTone(AdminContentStatus status) {
  return switch (status) {
    AdminContentStatus.active => _ChipTone.success,
    AdminContentStatus.draft => _ChipTone.warning,
    AdminContentStatus.inactive => _ChipTone.alert,
  };
}

String _dateLabel(DateTime date) {
  final value = date.toLocal();
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}
