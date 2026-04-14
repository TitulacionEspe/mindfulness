/// Entity representing a user in the domain layer.
/// This is independent of Firebase Auth or database models.
class UserEntity {
  final String id;
  final String email;
  final String? fullName;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    required this.createdAt,
  });
}
