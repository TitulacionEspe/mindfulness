import 'package:flutter/material.dart';

import '../../../auth/domain/entities/user_role.dart';
import '../../data/repositories/admin_repository.dart';
import '../../domain/entities/admin_models.dart';

class AdminPanelViewModel extends ChangeNotifier {
  AdminPanelViewModel({AdminRepository? repository})
    : _repository = repository ?? SupabaseAdminRepository();

  final AdminRepository _repository;

  AdminSection _selectedSection = AdminSection.dashboard;
  AdminSection get selectedSection => _selectedSection;

  bool _isInitializing = false;
  bool get isInitializing => _isInitializing;

  bool _isLoadingDashboard = false;
  bool get isLoadingDashboard => _isLoadingDashboard;

  bool _isLoadingUsers = false;
  bool get isLoadingUsers => _isLoadingUsers;

  bool _isLoadingContent = false;
  bool get isLoadingContent => _isLoadingContent;

  bool _isLoadingMedia = false;
  bool get isLoadingMedia => _isLoadingMedia;

  bool _isLoadingSettings = false;
  bool get isLoadingSettings => _isLoadingSettings;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  AdminDashboardSummary _summary = const AdminDashboardSummary();
  AdminDashboardSummary get summary => _summary;

  List<AdminUserAccount> _users = const [];
  List<AdminUserAccount> get users => _users;

  List<AdminContentItem> _contentItems = const [];
  List<AdminContentItem> get contentItems => _contentItems;

  List<AdminMediaAsset> _mediaAssets = const [];
  List<AdminMediaAsset> get mediaAssets => _mediaAssets;

  AdminSystemSettings _settings = AdminSystemSettings.empty();
  AdminSystemSettings get settings => _settings;

  List<AdminLegalDocument> _legalDocuments = const [];
  List<AdminLegalDocument> get legalDocuments => _legalDocuments;

  String _userSearchQuery = '';
  String get userSearchQuery => _userSearchQuery;

  UserRole? _roleFilter;
  UserRole? get roleFilter => _roleFilter;

  AdminAccountStatus? _accountStatusFilter;
  AdminAccountStatus? get accountStatusFilter => _accountStatusFilter;

  AdminContentStatus? _contentStatusFilter;
  AdminContentStatus? get contentStatusFilter => _contentStatusFilter;

  AdminContentType? _contentTypeFilter;
  AdminContentType? get contentTypeFilter => _contentTypeFilter;

  List<AdminUserAccount> get filteredUsers {
    final query = _userSearchQuery.trim().toLowerCase();
    return _users.where((user) {
      final matchesQuery =
          query.isEmpty ||
          user.fullName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toShortString().contains(query);
      final matchesRole = _roleFilter == null || user.role == _roleFilter;
      final matchesStatus =
          _accountStatusFilter == null || user.status == _accountStatusFilter;
      return matchesQuery && matchesRole && matchesStatus;
    }).toList();
  }

  List<AdminContentItem> get filteredContentItems {
    return _contentItems.where((item) {
      final matchesStatus =
          _contentStatusFilter == null || item.status == _contentStatusFilter;
      final matchesType =
          _contentTypeFilter == null || item.type == _contentTypeFilter;
      return matchesStatus && matchesType;
    }).toList();
  }

  int get activeAdminCount => _users.where((user) => user.isActiveAdmin).length;

  void selectSection(AdminSection section) {
    _selectedSection = section;
    notifyListeners();
    _ensureSectionData(section);
  }

  void setUserSearchQuery(String value) {
    _userSearchQuery = value;
    notifyListeners();
  }

  void setRoleFilter(UserRole? role) {
    _roleFilter = role;
    notifyListeners();
  }

  void setAccountStatusFilter(AdminAccountStatus? status) {
    _accountStatusFilter = status;
    notifyListeners();
  }

  void setContentStatusFilter(AdminContentStatus? status) {
    _contentStatusFilter = status;
    notifyListeners();
  }

  void setContentTypeFilter(AdminContentType? type) {
    _contentTypeFilter = type;
    notifyListeners();
  }

  void clearFeedback() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_isInitializing) return;
    _isInitializing = true;
    _errorMessage = null;
    notifyListeners();

    await Future.wait([loadDashboard(), loadUsers()]);
    await _ensureSectionData(_selectedSection);

    _isInitializing = false;
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    _isLoadingDashboard = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _repository.fetchDashboardSummary();
    } catch (error) {
      _errorMessage = _friendlyLoadError(
        error,
        fallback:
            'No se pudo cargar el resumen administrativo. Verifica la conexion y permisos.',
      );
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  Future<void> loadUsers() async {
    _isLoadingUsers = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _repository.fetchUsers();
    } catch (error) {
      _users = const [];
      _errorMessage = _friendlyLoadError(
        error,
        fallback:
            'No se pudo cargar usuarios. Revisa permisos, conexion y migraciones.',
      );
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  Future<void> loadContentItems() async {
    _isLoadingContent = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _contentItems = await _repository.fetchContentItems();
    } catch (error) {
      _contentItems = const [];
      _errorMessage = _friendlyLoadError(
        error,
        fallback:
            'No se pudo cargar contenidos base. Revisa permisos y migraciones.',
      );
    } finally {
      _isLoadingContent = false;
      notifyListeners();
    }
  }

  Future<void> loadMediaAssets() async {
    _isLoadingMedia = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mediaAssets = await _repository.fetchMediaAssets();
    } catch (error) {
      _mediaAssets = const [];
      _errorMessage = _friendlyLoadError(
        error,
        fallback:
            'No se pudo cargar recursos multimedia. Revisa permisos y migraciones.',
      );
    } finally {
      _isLoadingMedia = false;
      notifyListeners();
    }
  }

  Future<void> loadSystemSettings() async {
    _isLoadingSettings = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _repository.fetchSystemSettings();
    } catch (error) {
      _settings = AdminSystemSettings.empty();
      _errorMessage = _friendlyLoadError(
        error,
        fallback: 'No se pudo cargar la configuracion general del sistema.',
      );
    } finally {
      _isLoadingSettings = false;
      notifyListeners();
    }
  }

  Future<void> loadLegalDocuments() async {
    _isLoadingSettings = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _legalDocuments = await _repository.fetchLegalDocuments();
    } catch (error) {
      _legalDocuments = const [];
      _errorMessage = _friendlyLoadError(
        error,
        fallback: 'No se pudo cargar consentimiento y avisos institucionales.',
      );
    } finally {
      _isLoadingSettings = false;
      notifyListeners();
    }
  }

  bool canChangeUserRole(AdminUserAccount user, UserRole nextRole) {
    if (user.role == nextRole) return true;
    if (!user.isActiveAdmin) return true;
    return nextRole == UserRole.admin || activeAdminCount > 1;
  }

  bool canChangeUserStatus(
    AdminUserAccount user,
    AdminAccountStatus nextStatus,
  ) {
    if (user.status == nextStatus) return true;
    if (!user.isActiveAdmin) return true;
    return nextStatus == AdminAccountStatus.active || activeAdminCount > 1;
  }

  Future<bool> changeUserRole(AdminUserAccount user, UserRole role) async {
    if (!canChangeUserRole(user, role)) {
      _setError('Debe existir al menos un administrador activo.');
      return false;
    }

    return _runSavingOperation(
      () => _repository.updateUserRole(userId: user.id, role: role),
      successMessage: 'Rol actualizado correctamente.',
      afterSuccess: () async {
        await loadUsers();
        await loadDashboard();
      },
    );
  }

  Future<bool> changeUserStatus(
    AdminUserAccount user,
    AdminAccountStatus status,
  ) async {
    if (!canChangeUserStatus(user, status)) {
      _setError('Debe existir al menos un administrador activo.');
      return false;
    }

    return _runSavingOperation(
      () => _repository.updateUserStatus(userId: user.id, status: status),
      successMessage: 'Estado de cuenta actualizado.',
      afterSuccess: () async {
        await loadUsers();
        await loadDashboard();
      },
    );
  }

  Future<bool> saveContentItem({
    String? id,
    required AdminContentType type,
    required String title,
    required String description,
    required String category,
    required AdminContentStatus status,
    required bool isVisibleToPatients,
    int? durationSeconds,
    AdminContentItem? existingItem,
  }) async {
    final validation = _validateContentForSave(
      title: title,
      description: description,
      category: category,
      status: status,
      type: type,
      durationSeconds: durationSeconds,
      existingItem: existingItem,
    );
    if (validation != null) {
      _setError(validation);
      return false;
    }

    return _runSavingOperation(
      () => _repository.saveContentItem(
        id: id,
        type: type,
        title: title,
        description: description,
        category: category,
        status: status,
        isVisibleToPatients: isVisibleToPatients,
        durationSeconds: durationSeconds,
      ),
      successMessage: 'Contenido guardado correctamente.',
      afterSuccess: () async {
        await loadContentItems();
        await loadDashboard();
      },
    );
  }

  Future<bool> updateContentStatus({
    required AdminContentItem item,
    required AdminContentStatus status,
    required bool isVisibleToPatients,
  }) async {
    final validation = _validateContentForSave(
      title: item.title,
      description: item.description,
      category: item.category,
      status: status,
      type: item.type,
      durationSeconds: item.durationSeconds,
      existingItem: item,
    );
    if (validation != null) {
      _setError(validation);
      return false;
    }

    return _runSavingOperation(
      () => _repository.updateContentStatus(
        item: item,
        status: status,
        isVisibleToPatients: isVisibleToPatients,
      ),
      successMessage: 'Estado del contenido actualizado.',
      afterSuccess: () async {
        await loadContentItems();
        await loadDashboard();
      },
    );
  }

  Future<bool> saveMediaAsset({
    String? id,
    required String routineId,
    required String storageBucket,
    required String storagePath,
    required String fileType,
    required int fileSizeBytes,
    required bool isActive,
  }) async {
    if (routineId.trim().isEmpty) {
      _setError('Selecciona una rutina para asociar el recurso.');
      return false;
    }
    if (storagePath.trim().isEmpty) {
      _setError('Ingresa la ruta del archivo en Storage.');
      return false;
    }

    return _runSavingOperation(
      () => _repository.saveMediaAsset(
        id: id,
        routineId: routineId,
        storageBucket: storageBucket,
        storagePath: storagePath,
        fileType: fileType,
        fileSizeBytes: fileSizeBytes,
        isActive: isActive,
      ),
      successMessage: 'Recurso multimedia guardado.',
      afterSuccess: () async {
        await loadMediaAssets();
        await loadContentItems();
      },
    );
  }

  Future<bool> updateMediaAssetStatus({
    required String assetId,
    required bool isActive,
  }) {
    return _runSavingOperation(
      () => _repository.updateMediaAssetStatus(
        assetId: assetId,
        isActive: isActive,
      ),
      successMessage: 'Estado del recurso actualizado.',
      afterSuccess: () async {
        await loadMediaAssets();
        await loadContentItems();
      },
    );
  }

  Future<bool> saveSystemSettings(AdminSystemSettings settings) {
    return _runSavingOperation(
      () => _repository.saveSystemSettings(settings),
      successMessage: 'Configuracion general guardada.',
      afterSuccess: loadSystemSettings,
    );
  }

  Future<bool> saveLegalDocument({
    String? id,
    required String documentType,
    required String version,
    required String title,
    required String body,
    required AdminContentStatus status,
    required bool isCurrent,
  }) async {
    if (version.trim().isEmpty || title.trim().isEmpty || body.trim().isEmpty) {
      _setError('Completa version, titulo y texto antes de guardar.');
      return false;
    }

    return _runSavingOperation(
      () => _repository.saveLegalDocument(
        id: id,
        documentType: documentType,
        version: version,
        title: title,
        body: body,
        status: status,
        isCurrent: isCurrent,
      ),
      successMessage: 'Documento institucional guardado.',
      afterSuccess: loadLegalDocuments,
    );
  }

  String? _validateContentForSave({
    required String title,
    required String description,
    required String category,
    required AdminContentStatus status,
    required AdminContentType type,
    required int? durationSeconds,
    required AdminContentItem? existingItem,
  }) {
    if (title.trim().isEmpty || description.trim().isEmpty) {
      return 'Completa titulo y descripcion antes de guardar.';
    }
    if (type == AdminContentType.routine && (durationSeconds ?? 0) <= 0) {
      return 'La duracion de la rutina debe ser mayor a cero.';
    }
    if (status != AdminContentStatus.active) return null;
    if (type == AdminContentType.message) return null;
    if (!_categoryRequiresAudio(category)) return null;
    if ((existingItem?.assetCount ?? 0) > 0) return null;
    return 'Asocia un audio activo antes de publicar esta rutina.';
  }

  bool _categoryRequiresAudio(String category) {
    return category == 'sleep_induction' || category == 'soundscape';
  }

  Future<bool> _runSavingOperation(
    Future<void> Function() operation, {
    required String successMessage,
    Future<void> Function()? afterSuccess,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await operation();
      if (afterSuccess != null) await afterSuccess();
      _successMessage = successMessage;
      return true;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  String _friendlyError(Object error) {
    final raw = error.toString();
    if (raw.contains('administrador activo')) {
      return 'Debe existir al menos un administrador activo.';
    }
    if (raw.contains('permission') ||
        raw.contains('row-level') ||
        raw.contains('Acceso')) {
      return 'No tienes permisos administrativos para completar esta accion.';
    }
    return 'No se pudo completar la accion. Revisa la conexion e intenta nuevamente.';
  }

  String _friendlyLoadError(Object error, {required String fallback}) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('permission') ||
        raw.contains('row-level') ||
        raw.contains('acceso')) {
      return 'No tienes permisos administrativos para cargar esta seccion.';
    }
    if (raw.contains('does not exist') ||
        raw.contains('column') ||
        raw.contains('relation') ||
        raw.contains('function')) {
      return '$fallback Verifica que las migraciones administrativas esten aplicadas en Supabase.';
    }
    if (raw.contains('network') ||
        raw.contains('socket') ||
        raw.contains('connection')) {
      return 'No se pudo conectar con Supabase. Verifica tu internet e intenta nuevamente.';
    }
    return fallback;
  }

  Future<void> _ensureSectionData(AdminSection section) async {
    switch (section) {
      case AdminSection.dashboard:
      case AdminSection.metrics:
        if (!_isLoadingDashboard && _summary.totalUsers == 0) {
          await loadDashboard();
        }
        break;
      case AdminSection.users:
      case AdminSection.roles:
        if (!_isLoadingUsers && _users.isEmpty) {
          await loadUsers();
        }
        break;
      case AdminSection.content:
        if (!_isLoadingContent && _contentItems.isEmpty) {
          await loadContentItems();
        }
        break;
      case AdminSection.media:
        if (!_isLoadingContent && _contentItems.isEmpty) {
          await loadContentItems();
        }
        if (!_isLoadingMedia && _mediaAssets.isEmpty) {
          await loadMediaAssets();
        }
        break;
      case AdminSection.settings:
        if (!_isLoadingSettings && _settings.id.isEmpty) {
          await loadSystemSettings();
        }
        break;
      case AdminSection.legal:
        if (!_isLoadingSettings && _legalDocuments.isEmpty) {
          await loadLegalDocuments();
        }
        break;
    }
  }
}
