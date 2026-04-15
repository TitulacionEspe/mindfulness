/// Represents the possible roles a user can have in the system.
/// Matches the 'user_role' ENUM in Supabase database.
enum UserRole {
  patient,
  professional,
  admin;

  /// Converts a String from the database to a UserRole enum.
  /// Defaults to [UserRole.patient] if the string is unknown or null.
  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'professional':
        return UserRole.professional;
      case 'patient':
      default:
        return UserRole.patient;
    }
  }

  /// Converts the enum value back to a String for database operations.
  String toShortString() => name;
}
