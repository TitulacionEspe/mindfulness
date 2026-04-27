import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/features/admin/data/repositories/admin_repository.dart';
import 'package:mindfulness_app/features/admin/domain/entities/admin_models.dart';
import 'package:mindfulness_app/features/admin/presentation/viewmodels/admin_panel_viewmodel.dart';
import 'package:mindfulness_app/features/auth/domain/entities/user_role.dart';

class FakeAdminRepository implements AdminRepository {
  List<AdminUserAccount> users = const [];
  List<AdminContentItem> content = const [];
  bool roleUpdated = false;
  bool statusUpdated = false;
  bool contentSaved = false;

  @override
  Future<AdminDashboardSummary> fetchDashboardSummary() async {
    return const AdminDashboardSummary(
      totalUsers: 2,
      admins: 1,
      activeAccounts: 2,
    );
  }

  @override
  Future<List<AdminUserAccount>> fetchUsers() async => users;

  @override
  Future<void> updateUserRole({
    required String userId,
    required UserRole role,
  }) async {
    roleUpdated = true;
  }

  @override
  Future<void> updateUserStatus({
    required String userId,
    required AdminAccountStatus status,
  }) async {
    statusUpdated = true;
  }

  @override
  Future<List<AdminContentItem>> fetchContentItems() async => content;

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
    contentSaved = true;
  }

  @override
  Future<void> updateContentStatus({
    required AdminContentItem item,
    required AdminContentStatus status,
    required bool isVisibleToPatients,
  }) async {
    contentSaved = true;
  }

  @override
  Future<List<AdminMediaAsset>> fetchMediaAssets() async => const [];

  @override
  Future<void> saveMediaAsset({
    String? id,
    required String routineId,
    required String storageBucket,
    required String storagePath,
    required String fileType,
    required int fileSizeBytes,
    required bool isActive,
  }) async {}

  @override
  Future<void> updateMediaAssetStatus({
    required String assetId,
    required bool isActive,
  }) async {}

  @override
  Future<AdminSystemSettings> fetchSystemSettings() async {
    return AdminSystemSettings.empty();
  }

  @override
  Future<void> saveSystemSettings(AdminSystemSettings settings) async {}

  @override
  Future<List<AdminLegalDocument>> fetchLegalDocuments() async => const [];

  @override
  Future<void> saveLegalDocument({
    String? id,
    required String documentType,
    required String version,
    required String title,
    required String body,
    required AdminContentStatus status,
    required bool isCurrent,
  }) async {}
}

AdminUserAccount _user({
  required String id,
  required UserRole role,
  AdminAccountStatus status = AdminAccountStatus.active,
}) {
  return AdminUserAccount(
    id: id,
    fullName: 'Usuario $id',
    email: '$id@test.com',
    role: role,
    segment: 'student',
    status: status,
    isActive: status == AdminAccountStatus.active,
    themeMode: 'light',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  group('AdminPanelViewModel', () {
    test('prevents demoting the last active admin', () async {
      final repository = FakeAdminRepository()
        ..users = [_user(id: 'admin', role: UserRole.admin)];
      final viewModel = AdminPanelViewModel(repository: repository);

      await viewModel.loadUsers();
      final result = await viewModel.changeUserRole(
        repository.users.first,
        UserRole.patient,
      );

      expect(result, isFalse);
      expect(repository.roleUpdated, isFalse);
      expect(
        viewModel.errorMessage,
        'Debe existir al menos un administrador activo.',
      );
    });

    test('prevents deactivating the last active admin', () async {
      final repository = FakeAdminRepository()
        ..users = [_user(id: 'admin', role: UserRole.admin)];
      final viewModel = AdminPanelViewModel(repository: repository);

      await viewModel.loadUsers();
      final result = await viewModel.changeUserStatus(
        repository.users.first,
        AdminAccountStatus.inactive,
      );

      expect(result, isFalse);
      expect(repository.statusUpdated, isFalse);
      expect(
        viewModel.errorMessage,
        'Debe existir al menos un administrador activo.',
      );
    });

    test('filters users by query, role and account status', () async {
      final repository = FakeAdminRepository()
        ..users = [
          _user(id: 'admin', role: UserRole.admin),
          _user(
            id: 'patient',
            role: UserRole.patient,
            status: AdminAccountStatus.inactive,
          ),
        ];
      final viewModel = AdminPanelViewModel(repository: repository);

      await viewModel.loadUsers();
      viewModel.setUserSearchQuery('patient');
      viewModel.setRoleFilter(UserRole.patient);
      viewModel.setAccountStatusFilter(AdminAccountStatus.inactive);

      expect(viewModel.filteredUsers, hasLength(1));
      expect(viewModel.filteredUsers.first.id, 'patient');
    });

    test(
      'blocks publishing audio-based routines without an active asset',
      () async {
        final repository = FakeAdminRepository();
        final viewModel = AdminPanelViewModel(repository: repository);

        final result = await viewModel.saveContentItem(
          type: AdminContentType.routine,
          title: 'Escaneo nocturno',
          description: 'Guia para descanso.',
          category: 'sleep_induction',
          status: AdminContentStatus.active,
          isVisibleToPatients: true,
          durationSeconds: 300,
        );

        expect(result, isFalse);
        expect(repository.contentSaved, isFalse);
        expect(
          viewModel.errorMessage,
          'Asocia un audio activo antes de publicar esta rutina.',
        );
      },
    );
  });
}
