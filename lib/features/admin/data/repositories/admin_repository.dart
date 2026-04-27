import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/domain/entities/user_role.dart';
import '../../domain/entities/admin_models.dart';

abstract class AdminRepository {
  Future<AdminDashboardSummary> fetchDashboardSummary();
  Future<List<AdminUserAccount>> fetchUsers();
  Future<void> updateUserRole({required String userId, required UserRole role});
  Future<void> updateUserStatus({
    required String userId,
    required AdminAccountStatus status,
  });
  Future<List<AdminContentItem>> fetchContentItems();
  Future<void> saveContentItem({
    String? id,
    required AdminContentType type,
    required String title,
    required String description,
    required String category,
    required AdminContentStatus status,
    required bool isVisibleToPatients,
    int? durationSeconds,
  });
  Future<void> updateContentStatus({
    required AdminContentItem item,
    required AdminContentStatus status,
    required bool isVisibleToPatients,
  });
  Future<List<AdminMediaAsset>> fetchMediaAssets();
  Future<void> saveMediaAsset({
    String? id,
    required String routineId,
    required String storageBucket,
    required String storagePath,
    required String fileType,
    required int fileSizeBytes,
    required bool isActive,
  });
  Future<void> updateMediaAssetStatus({
    required String assetId,
    required bool isActive,
  });
  Future<AdminSystemSettings> fetchSystemSettings();
  Future<void> saveSystemSettings(AdminSystemSettings settings);
  Future<List<AdminLegalDocument>> fetchLegalDocuments();
  Future<void> saveLegalDocument({
    String? id,
    required String documentType,
    required String version,
    required String title,
    required String body,
    required AdminContentStatus status,
    required bool isCurrent,
  });
}

class SupabaseAdminRepository implements AdminRepository {
  SupabaseAdminRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<AdminDashboardSummary> fetchDashboardSummary() async {
    try {
      final response = await _client.rpc('admin_overview_metrics');
      final map = Map<String, dynamic>.from(response as Map);
      return AdminDashboardSummary.fromMap(map);
    } catch (_) {
      return _fetchDashboardSummaryFallback();
    }
  }

  @override
  Future<List<AdminUserAccount>> fetchUsers() async {
    List<Map<String, dynamic>> rows;
    try {
      final response = await _client
          .from('profiles')
          .select()
          .order('created_at', ascending: false);
      rows = List<Map<String, dynamic>>.from(response as List);
    } catch (_) {
      final response = await _client.from('profiles').select();
      rows = List<Map<String, dynamic>>.from(response as List);
      rows.sort(
        (a, b) => _toDateValue(
          b['created_at'],
        ).compareTo(_toDateValue(a['created_at'])),
      );
    }

    return rows.map(AdminUserAccount.fromMap).toList();
  }

  @override
  Future<void> updateUserRole({
    required String userId,
    required UserRole role,
  }) async {
    await _client
        .from('profiles')
        .update({'role': role.toShortString()})
        .eq('id', userId);
  }

  @override
  Future<void> updateUserStatus({
    required String userId,
    required AdminAccountStatus status,
  }) async {
    await _client
        .from('profiles')
        .update({
          'account_status': status.value,
          'is_active': status == AdminAccountStatus.active,
        })
        .eq('id', userId);
  }

  @override
  Future<List<AdminContentItem>> fetchContentItems() async {
    final routinesResponse = await _client
        .from('routines')
        .select(
          'id,title,description,category,duration_seconds,is_active,content_status,is_visible_to_patients,created_at,updated_at',
        )
        .order('updated_at', ascending: false);

    final assetRows = await _client
        .from('routine_assets')
        .select('routine_id,is_active');

    final assetCounts = <String, int>{};
    for (final row in List<Map<String, dynamic>>.from(assetRows as List)) {
      if (row['is_active'] == false) continue;
      final routineId = row['routine_id'] as String?;
      if (routineId == null) continue;
      assetCounts[routineId] = (assetCounts[routineId] ?? 0) + 1;
    }

    final messagesResponse = await _client
        .from('content_messages')
        .select(
          'id,title,category,message_body,version,is_active,content_status,is_visible_to_patients,created_at,updated_at',
        )
        .order('updated_at', ascending: false);

    final items = <AdminContentItem>[
      ...List<Map<String, dynamic>>.from(routinesResponse as List).map(
        (row) => AdminContentItem.fromRoutineMap(
          row,
          assetCount: assetCounts[row['id'] as String?] ?? 0,
        ),
      ),
      ...List<Map<String, dynamic>>.from(
        messagesResponse as List,
      ).map(AdminContentItem.fromMessageMap),
    ];

    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  @override
  Future<void> saveContentItem({
    String? id,
    required AdminContentType type,
    required String title,
    required String description,
    required String category,
    required AdminContentStatus status,
    required bool isVisibleToPatients,
    int? durationSeconds,
  }) async {
    if (type == AdminContentType.message) {
      final payload = {
        'title': title.trim(),
        'message_body': description.trim(),
        'category': category.trim().isEmpty ? 'general' : category.trim(),
        'content_status': status.value,
        'is_visible_to_patients': isVisibleToPatients,
        'is_active': status == AdminContentStatus.active && isVisibleToPatients,
      };

      if (id == null || id.isEmpty) {
        await _client.from('content_messages').insert(payload);
      } else {
        await _client.from('content_messages').update(payload).eq('id', id);
      }
      return;
    }

    final payload = {
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'duration_seconds': durationSeconds ?? 180,
      'content_status': status.value,
      'is_visible_to_patients': isVisibleToPatients,
      'is_active': status == AdminContentStatus.active && isVisibleToPatients,
      'updated_by': _client.auth.currentUser?.id,
    };

    if (id == null || id.isEmpty) {
      await _client.from('routines').insert({
        ...payload,
        'created_by': _client.auth.currentUser?.id,
      });
    } else {
      await _client.from('routines').update(payload).eq('id', id);
    }
  }

  @override
  Future<void> updateContentStatus({
    required AdminContentItem item,
    required AdminContentStatus status,
    required bool isVisibleToPatients,
  }) {
    return saveContentItem(
      id: item.id,
      type: item.type,
      title: item.title,
      description: item.description,
      category: item.category,
      status: status,
      isVisibleToPatients: isVisibleToPatients,
      durationSeconds: item.durationSeconds,
    );
  }

  @override
  Future<List<AdminMediaAsset>> fetchMediaAssets() async {
    final assetsResponse = await _client
        .from('routine_assets')
        .select(
          'id,routine_id,storage_bucket,storage_path,file_type,file_size_bytes,is_active,created_at,updated_at',
        )
        .order('created_at', ascending: false);

    final assetRows = List<Map<String, dynamic>>.from(assetsResponse as List);
    if (assetRows.isEmpty) return const [];

    final routineIds = assetRows
        .map((row) => row['routine_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    final routinesResponse = await _client
        .from('routines')
        .select('id,title')
        .inFilter('id', routineIds);

    final routineTitles = {
      for (final row in List<Map<String, dynamic>>.from(
        routinesResponse as List,
      ))
        row['id'] as String: row['title'] as String? ?? 'Rutina',
    };

    return assetRows
        .map(
          (row) => AdminMediaAsset.fromMap(
            row,
            routineTitle:
                routineTitles[row['routine_id'] as String?] ??
                'Rutina sin asociar',
          ),
        )
        .toList();
  }

  @override
  Future<void> saveMediaAsset({
    String? id,
    required String routineId,
    required String storageBucket,
    required String storagePath,
    required String fileType,
    required int fileSizeBytes,
    required bool isActive,
  }) async {
    final payload = {
      'routine_id': routineId,
      'storage_bucket': storageBucket.trim().isEmpty
          ? 'routines'
          : storageBucket.trim(),
      'storage_path': storagePath.trim(),
      'file_type': fileType.trim().isEmpty ? 'audio' : fileType.trim(),
      'file_size_bytes': fileSizeBytes,
      'is_active': isActive,
    };

    if (id == null || id.isEmpty) {
      await _client.from('routine_assets').insert(payload);
    } else {
      await _client.from('routine_assets').update(payload).eq('id', id);
    }
  }

  @override
  Future<void> updateMediaAssetStatus({
    required String assetId,
    required bool isActive,
  }) async {
    await _client
        .from('routine_assets')
        .update({'is_active': isActive})
        .eq('id', assetId);
  }

  @override
  Future<AdminSystemSettings> fetchSystemSettings() async {
    final response = await _client
        .from('system_settings')
        .select()
        .eq('settings_key', 'global')
        .maybeSingle();

    if (response == null) return AdminSystemSettings.empty();
    return AdminSystemSettings.fromMap(response);
  }

  @override
  Future<void> saveSystemSettings(AdminSystemSettings settings) async {
    if (settings.id.isEmpty) {
      await _client.from('system_settings').insert({
        'settings_key': 'global',
        ...settings.toUpdateMap(),
      });
      return;
    }

    await _client
        .from('system_settings')
        .update(settings.toUpdateMap())
        .eq('id', settings.id);
  }

  @override
  Future<List<AdminLegalDocument>> fetchLegalDocuments() async {
    final response = await _client
        .from('legal_documents')
        .select()
        .order('document_type')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(
      response as List,
    ).map(AdminLegalDocument.fromMap).toList();
  }

  @override
  Future<void> saveLegalDocument({
    String? id,
    required String documentType,
    required String version,
    required String title,
    required String body,
    required AdminContentStatus status,
    required bool isCurrent,
  }) async {
    final payload = {
      'document_type': documentType,
      'version': version.trim(),
      'title': title.trim(),
      'body': body.trim(),
      'content_status': status.value,
      'is_current': isCurrent,
    };

    if (id == null || id.isEmpty) {
      await _client.from('legal_documents').insert(payload);
    } else {
      await _client.from('legal_documents').update(payload).eq('id', id);
    }
  }

  Future<AdminDashboardSummary> _fetchDashboardSummaryFallback() async {
    final profiles = await _safeSelectAll('profiles');
    final routines = await _safeSelectAll('routines');
    final messages = await _safeSelectAll('content_messages');
    final assets = await _safeSelectAll('routine_assets');
    final sessions = await _safeSelectAll('activity_sessions');

    var totalUsers = 0;
    var patients = 0;
    var professionals = 0;
    var admins = 0;
    var activeAccounts = 0;
    var inactiveAccounts = 0;
    var blockedAccounts = 0;
    final usersByRole = <String, int>{};

    for (final profile in profiles) {
      totalUsers += 1;
      final role = (profile['role']?.toString() ?? 'patient').toLowerCase();
      usersByRole[role] = (usersByRole[role] ?? 0) + 1;

      switch (role) {
        case 'admin':
          admins += 1;
          break;
        case 'professional':
          professionals += 1;
          break;
        default:
          patients += 1;
      }

      final isActive = profile['is_active'] as bool? ?? true;
      final normalizedStatus =
          (profile['account_status']?.toString() ??
                  (isActive ? 'active' : 'inactive'))
              .toLowerCase();

      switch (normalizedStatus) {
        case 'blocked':
          blockedAccounts += 1;
          break;
        case 'inactive':
          inactiveAccounts += 1;
          break;
        default:
          if (isActive) {
            activeAccounts += 1;
          } else {
            inactiveAccounts += 1;
          }
      }
    }

    var routinesActive = 0;
    for (final routine in routines) {
      final isActive = routine['is_active'] as bool? ?? true;
      final status =
          (routine['content_status']?.toString() ??
                  (isActive ? 'active' : 'inactive'))
              .toLowerCase();
      final isVisible = routine['is_visible_to_patients'] as bool? ?? true;
      if (isActive && status == 'active' && isVisible) {
        routinesActive += 1;
      }
    }

    var messagesActive = 0;
    for (final message in messages) {
      final isActive = message['is_active'] as bool? ?? true;
      final status =
          (message['content_status']?.toString() ??
                  (isActive ? 'active' : 'inactive'))
              .toLowerCase();
      final isVisible = message['is_visible_to_patients'] as bool? ?? true;
      if (isActive && status == 'active' && isVisible) {
        messagesActive += 1;
      }
    }

    var sessionsCompleted = 0;
    var activeDays30 = 0;
    final now = DateTime.now().toUtc();
    final last30Days = now.subtract(const Duration(days: 30));
    final last7Days = now.subtract(const Duration(days: 6));
    final activeDayKeys = <String>{};
    final activityByDay = <String, int>{};

    for (final session in sessions) {
      final status = session['status']?.toString().toLowerCase();
      if (status == 'completed') sessionsCompleted += 1;

      final startedAt = _toDateValue(session['started_at']);
      if (startedAt.isAfter(last30Days) ||
          startedAt.isAtSameMomentAs(last30Days)) {
        activeDayKeys.add(
          '${startedAt.year.toString().padLeft(4, '0')}-${startedAt.month.toString().padLeft(2, '0')}-${startedAt.day.toString().padLeft(2, '0')}',
        );
      }
      if (startedAt.isAfter(last7Days) ||
          startedAt.isAtSameMomentAs(last7Days)) {
        final key =
            '${startedAt.year.toString().padLeft(4, '0')}-${startedAt.month.toString().padLeft(2, '0')}-${startedAt.day.toString().padLeft(2, '0')}';
        activityByDay[key] = (activityByDay[key] ?? 0) + 1;
      }
    }
    activeDays30 = activeDayKeys.length;

    final activityByPeriod = activityByDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return AdminDashboardSummary(
      totalUsers: totalUsers,
      patients: patients,
      professionals: professionals,
      admins: admins,
      activeAccounts: activeAccounts,
      inactiveAccounts: inactiveAccounts,
      blockedAccounts: blockedAccounts,
      routinesTotal: routines.length,
      routinesActive: routinesActive,
      messagesActive: messagesActive,
      assetsTotal: assets.length,
      sessionsTotal: sessions.length,
      sessionsCompleted: sessionsCompleted,
      activeDays30: activeDays30,
      usersByRole: usersByRole,
      activityByPeriod: activityByPeriod
          .map(
            (entry) => AdminActivityMetric(
              dateLabel: entry.key,
              sessions: entry.value,
            ),
          )
          .toList(),
    );
  }

  Future<List<Map<String, dynamic>>> _safeSelectAll(String table) async {
    try {
      final response = await _client.from(table).select();
      return List<Map<String, dynamic>>.from(response as List);
    } catch (_) {
      return const [];
    }
  }

  DateTime _toDateValue(dynamic value) {
    if (value is DateTime) return value.toUtc();
    return DateTime.tryParse(value?.toString() ?? '')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}
