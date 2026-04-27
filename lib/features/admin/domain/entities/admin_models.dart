import '../../../auth/domain/entities/user_role.dart';

enum AdminAccountStatus { active, inactive, blocked }

extension AdminAccountStatusX on AdminAccountStatus {
  static AdminAccountStatus fromValue(String? value) {
    return switch (value) {
      'blocked' => AdminAccountStatus.blocked,
      'inactive' => AdminAccountStatus.inactive,
      _ => AdminAccountStatus.active,
    };
  }

  String get value {
    return switch (this) {
      AdminAccountStatus.active => 'active',
      AdminAccountStatus.inactive => 'inactive',
      AdminAccountStatus.blocked => 'blocked',
    };
  }

  String get label {
    return switch (this) {
      AdminAccountStatus.active => 'Activa',
      AdminAccountStatus.inactive => 'Inactiva',
      AdminAccountStatus.blocked => 'Bloqueada',
    };
  }
}

enum AdminContentStatus { draft, active, inactive }

extension AdminContentStatusX on AdminContentStatus {
  static AdminContentStatus fromValue(String? value) {
    return switch (value) {
      'draft' => AdminContentStatus.draft,
      'inactive' => AdminContentStatus.inactive,
      _ => AdminContentStatus.active,
    };
  }

  String get value {
    return switch (this) {
      AdminContentStatus.draft => 'draft',
      AdminContentStatus.active => 'active',
      AdminContentStatus.inactive => 'inactive',
    };
  }

  String get label {
    return switch (this) {
      AdminContentStatus.draft => 'Borrador',
      AdminContentStatus.active => 'Activo',
      AdminContentStatus.inactive => 'Inactivo',
    };
  }
}

enum AdminContentType { routine, message }

extension AdminContentTypeX on AdminContentType {
  static AdminContentType fromValue(String? value) {
    return value == 'message'
        ? AdminContentType.message
        : AdminContentType.routine;
  }

  String get value => this == AdminContentType.message ? 'message' : 'routine';

  String get label => this == AdminContentType.message ? 'Mensaje' : 'Rutina';
}

enum AdminSection {
  dashboard,
  users,
  roles,
  content,
  media,
  settings,
  legal,
  metrics,
}

extension AdminSectionX on AdminSection {
  String get label {
    return switch (this) {
      AdminSection.dashboard => 'Dashboard',
      AdminSection.users => 'Usuarios',
      AdminSection.roles => 'Roles',
      AdminSection.content => 'Contenidos',
      AdminSection.media => 'Multimedia',
      AdminSection.settings => 'Configuracion',
      AdminSection.legal => 'Consentimiento',
      AdminSection.metrics => 'Metricas',
    };
  }
}

class AdminDashboardSummary {
  const AdminDashboardSummary({
    this.totalUsers = 0,
    this.patients = 0,
    this.professionals = 0,
    this.admins = 0,
    this.activeAccounts = 0,
    this.inactiveAccounts = 0,
    this.blockedAccounts = 0,
    this.routinesTotal = 0,
    this.routinesActive = 0,
    this.messagesActive = 0,
    this.assetsTotal = 0,
    this.sessionsTotal = 0,
    this.sessionsCompleted = 0,
    this.activeDays30 = 0,
    this.usersByRole = const {},
    this.activityByPeriod = const [],
  });

  final int totalUsers;
  final int patients;
  final int professionals;
  final int admins;
  final int activeAccounts;
  final int inactiveAccounts;
  final int blockedAccounts;
  final int routinesTotal;
  final int routinesActive;
  final int messagesActive;
  final int assetsTotal;
  final int sessionsTotal;
  final int sessionsCompleted;
  final int activeDays30;
  final Map<String, int> usersByRole;
  final List<AdminActivityMetric> activityByPeriod;

  int get contentAvailable => routinesActive + messagesActive;

  factory AdminDashboardSummary.fromMap(Map<String, dynamic> map) {
    return AdminDashboardSummary(
      totalUsers: _toInt(map['total_users']),
      patients: _toInt(map['patients']),
      professionals: _toInt(map['professionals']),
      admins: _toInt(map['admins']),
      activeAccounts: _toInt(map['active_accounts']),
      inactiveAccounts: _toInt(map['inactive_accounts']),
      blockedAccounts: _toInt(map['blocked_accounts']),
      routinesTotal: _toInt(map['routines_total']),
      routinesActive: _toInt(map['routines_active']),
      messagesActive: _toInt(map['messages_active']),
      assetsTotal: _toInt(map['assets_total']),
      sessionsTotal: _toInt(map['sessions_total']),
      sessionsCompleted: _toInt(map['sessions_completed']),
      activeDays30: _toInt(map['active_days_30']),
      usersByRole: _parseRoleMap(map['users_by_role']),
      activityByPeriod: _parseActivity(map['activity_by_period']),
    );
  }
}

class AdminActivityMetric {
  const AdminActivityMetric({required this.dateLabel, required this.sessions});

  final String dateLabel;
  final int sessions;

  factory AdminActivityMetric.fromMap(Map<String, dynamic> map) {
    return AdminActivityMetric(
      dateLabel: map['date']?.toString() ?? '',
      sessions: _toInt(map['sessions']),
    );
  }
}

class AdminUserAccount {
  const AdminUserAccount({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.segment,
    required this.status,
    required this.isActive,
    required this.themeMode,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String segment;
  final AdminAccountStatus status;
  final bool isActive;
  final String themeMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActiveAdmin =>
      role == UserRole.admin && isActive && status == AdminAccountStatus.active;

  factory AdminUserAccount.fromMap(Map<String, dynamic> map) {
    return AdminUserAccount(
      id: map['id'] as String? ?? '',
      fullName: (map['full_name'] as String?)?.trim().isNotEmpty == true
          ? (map['full_name'] as String).trim()
          : 'Usuario sin nombre',
      email: (map['email'] as String?)?.trim() ?? '',
      role: UserRole.fromString(map['role'] as String?),
      segment: map['segment']?.toString() ?? 'student',
      status: AdminAccountStatusX.fromValue(map['account_status'] as String?),
      isActive: map['is_active'] as bool? ?? true,
      themeMode: map['theme_mode']?.toString() ?? 'light',
      createdAt: _toDate(map['created_at']),
      updatedAt: _toDate(map['updated_at']),
    );
  }

  AdminUserAccount copyWith({
    UserRole? role,
    AdminAccountStatus? status,
    bool? isActive,
  }) {
    return AdminUserAccount(
      id: id,
      fullName: fullName,
      email: email,
      role: role ?? this.role,
      segment: segment,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      themeMode: themeMode,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class AdminContentItem {
  const AdminContentItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.isVisibleToPatients,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.durationSeconds,
    this.assetCount = 0,
  });

  final String id;
  final AdminContentType type;
  final String title;
  final String description;
  final String category;
  final AdminContentStatus status;
  final bool isVisibleToPatients;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? durationSeconds;
  final int assetCount;

  bool get canPublish {
    final hasBaseFields =
        title.trim().isNotEmpty && description.trim().isNotEmpty;
    if (type == AdminContentType.message) return hasBaseFields;
    return hasBaseFields && (durationSeconds ?? 0) > 0;
  }

  String get durationLabel {
    final seconds = durationSeconds;
    if (seconds == null) return 'Sin duracion';
    final minutes = (seconds / 60).ceil();
    return '$minutes min';
  }

  factory AdminContentItem.fromRoutineMap(
    Map<String, dynamic> map, {
    int assetCount = 0,
  }) {
    return AdminContentItem(
      id: map['id'] as String? ?? '',
      type: AdminContentType.routine,
      title: map['title'] as String? ?? 'Rutina sin titulo',
      description: map['description'] as String? ?? '',
      category: map['category']?.toString() ?? 'relaxation',
      status: AdminContentStatusX.fromValue(map['content_status'] as String?),
      isVisibleToPatients: map['is_visible_to_patients'] as bool? ?? true,
      isActive: map['is_active'] as bool? ?? true,
      durationSeconds: _toInt(map['duration_seconds'], fallback: 180),
      assetCount: assetCount,
      createdAt: _toDate(map['created_at']),
      updatedAt: _toDate(map['updated_at']),
    );
  }

  factory AdminContentItem.fromMessageMap(Map<String, dynamic> map) {
    return AdminContentItem(
      id: map['id'] as String? ?? '',
      type: AdminContentType.message,
      title: map['title'] as String? ?? 'Mensaje de orientacion',
      description: map['message_body'] as String? ?? '',
      category: map['category']?.toString() ?? 'general',
      status: AdminContentStatusX.fromValue(map['content_status'] as String?),
      isVisibleToPatients: map['is_visible_to_patients'] as bool? ?? true,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: _toDate(map['created_at']),
      updatedAt: _toDate(map['updated_at']),
    );
  }
}

class AdminMediaAsset {
  const AdminMediaAsset({
    required this.id,
    required this.routineId,
    required this.routineTitle,
    required this.storageBucket,
    required this.storagePath,
    required this.fileType,
    required this.fileSizeBytes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String routineId;
  final String routineTitle;
  final String storageBucket;
  final String storagePath;
  final String fileType;
  final int fileSizeBytes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get fileSizeLabel {
    if (fileSizeBytes <= 0) return 'Sin tamano';
    final mb = fileSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  factory AdminMediaAsset.fromMap(
    Map<String, dynamic> map, {
    required String routineTitle,
  }) {
    return AdminMediaAsset(
      id: map['id'] as String? ?? '',
      routineId: map['routine_id'] as String? ?? '',
      routineTitle: routineTitle,
      storageBucket: map['storage_bucket'] as String? ?? 'routines',
      storagePath: map['storage_path'] as String? ?? '',
      fileType: map['file_type'] as String? ?? 'audio',
      fileSizeBytes: _toInt(map['file_size_bytes']),
      isActive: map['is_active'] as bool? ?? true,
      createdAt: _toDate(map['created_at']),
      updatedAt: _toDate(map['updated_at']),
    );
  }
}

class AdminSystemSettings {
  const AdminSystemSettings({
    required this.id,
    required this.defaultTheme,
    required this.darkModeEnabled,
    required this.responsibleUseNotice,
    required this.generalOrientationMessage,
    required this.recommendedSessionDurationMinutes,
    required this.professionalModuleEnabled,
    required this.patientProfessionalAssignmentEnabled,
    required this.contentValidationEnabled,
    required this.activeConsentVersion,
    required this.updatedAt,
  });

  final String id;
  final String defaultTheme;
  final bool darkModeEnabled;
  final String responsibleUseNotice;
  final String generalOrientationMessage;
  final int recommendedSessionDurationMinutes;
  final bool professionalModuleEnabled;
  final bool patientProfessionalAssignmentEnabled;
  final bool contentValidationEnabled;
  final String activeConsentVersion;
  final DateTime updatedAt;

  factory AdminSystemSettings.empty() {
    return AdminSystemSettings(
      id: '',
      defaultTheme: 'light',
      darkModeEnabled: true,
      responsibleUseNotice:
          'Esta aplicacion promueve bienestar y no reemplaza atencion profesional.',
      generalOrientationMessage:
          'Usa las rutinas como apoyo de autocuidado y busca ayuda profesional si lo necesitas.',
      recommendedSessionDurationMinutes: 10,
      professionalModuleEnabled: false,
      patientProfessionalAssignmentEnabled: false,
      contentValidationEnabled: false,
      activeConsentVersion: '1.0.0',
      updatedAt: DateTime.now(),
    );
  }

  factory AdminSystemSettings.fromMap(Map<String, dynamic> map) {
    return AdminSystemSettings(
      id: map['id'] as String? ?? '',
      defaultTheme: map['default_theme']?.toString() ?? 'light',
      darkModeEnabled: map['dark_mode_enabled'] as bool? ?? true,
      responsibleUseNotice:
          map['responsible_use_notice']?.toString() ??
          'Esta aplicacion promueve bienestar y no reemplaza atencion profesional.',
      generalOrientationMessage:
          map['general_orientation_message']?.toString() ??
          'Usa las rutinas como apoyo de autocuidado y busca ayuda profesional si lo necesitas.',
      recommendedSessionDurationMinutes: _toInt(
        map['recommended_session_duration_minutes'],
        fallback: 10,
      ),
      professionalModuleEnabled:
          map['professional_module_enabled'] as bool? ?? false,
      patientProfessionalAssignmentEnabled:
          map['patient_professional_assignment_enabled'] as bool? ?? false,
      contentValidationEnabled:
          map['content_validation_enabled'] as bool? ?? false,
      activeConsentVersion:
          map['active_consent_version']?.toString() ?? '1.0.0',
      updatedAt: _toDate(map['updated_at']),
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'default_theme': defaultTheme,
      'dark_mode_enabled': darkModeEnabled,
      'responsible_use_notice': responsibleUseNotice,
      'general_orientation_message': generalOrientationMessage,
      'recommended_session_duration_minutes': recommendedSessionDurationMinutes,
      'professional_module_enabled': professionalModuleEnabled,
      'patient_professional_assignment_enabled':
          patientProfessionalAssignmentEnabled,
      'content_validation_enabled': contentValidationEnabled,
      'active_consent_version': activeConsentVersion,
    };
  }

  AdminSystemSettings copyWith({
    String? defaultTheme,
    bool? darkModeEnabled,
    String? responsibleUseNotice,
    String? generalOrientationMessage,
    int? recommendedSessionDurationMinutes,
    bool? professionalModuleEnabled,
    bool? patientProfessionalAssignmentEnabled,
    bool? contentValidationEnabled,
    String? activeConsentVersion,
  }) {
    return AdminSystemSettings(
      id: id,
      defaultTheme: defaultTheme ?? this.defaultTheme,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      responsibleUseNotice: responsibleUseNotice ?? this.responsibleUseNotice,
      generalOrientationMessage:
          generalOrientationMessage ?? this.generalOrientationMessage,
      recommendedSessionDurationMinutes:
          recommendedSessionDurationMinutes ??
          this.recommendedSessionDurationMinutes,
      professionalModuleEnabled:
          professionalModuleEnabled ?? this.professionalModuleEnabled,
      patientProfessionalAssignmentEnabled:
          patientProfessionalAssignmentEnabled ??
          this.patientProfessionalAssignmentEnabled,
      contentValidationEnabled:
          contentValidationEnabled ?? this.contentValidationEnabled,
      activeConsentVersion: activeConsentVersion ?? this.activeConsentVersion,
      updatedAt: updatedAt,
    );
  }
}

class AdminLegalDocument {
  const AdminLegalDocument({
    required this.id,
    required this.documentType,
    required this.version,
    required this.title,
    required this.body,
    required this.status,
    required this.isCurrent,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String documentType;
  final String version;
  final String title;
  final String body;
  final AdminContentStatus status;
  final bool isCurrent;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get typeLabel =>
      documentType == 'consent' ? 'Consentimiento' : 'Uso responsable';

  factory AdminLegalDocument.fromMap(Map<String, dynamic> map) {
    return AdminLegalDocument(
      id: map['id'] as String? ?? '',
      documentType: map['document_type'] as String? ?? 'consent',
      version: map['version'] as String? ?? '1.0.0',
      title: map['title'] as String? ?? 'Documento institucional',
      body: map['body'] as String? ?? '',
      status: AdminContentStatusX.fromValue(map['content_status'] as String?),
      isCurrent: map['is_current'] as bool? ?? false,
      createdAt: _toDate(map['created_at']),
      updatedAt: _toDate(map['updated_at']),
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime _toDate(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}

Map<String, int> _parseRoleMap(dynamic value) {
  if (value is! Map) return const {};
  return value.map((key, item) => MapEntry(key.toString(), _toInt(item)));
}

List<AdminActivityMetric> _parseActivity(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map(
        (item) => AdminActivityMetric.fromMap(Map<String, dynamic>.from(item)),
      )
      .toList();
}
