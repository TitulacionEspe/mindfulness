import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/i_auth_repository.dart';

/// Concrete implementation of IAuthRepository (Data Layer).
/// Handles calls to Supabase Auth and entity mapping.
/// Profile creation is handled by the database trigger (on_auth_user_created).
class AuthRepository implements IAuthRepository {
  @override
  Future<UserEntity> register(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      // Sign up user in Supabase Auth.
      // We pass the full_name in the data field (raw_user_meta_data)
      // to trigger the profile creation in the database.
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName.trim()},
      );

      if (authResponse.user == null) {
        throw Exception('Error en registro: no se creó el usuario');
      }

      // After registration, the role is default ('patient')
      return _mapSupabaseUserToEntity(authResponse.user!, UserRole.patient);
    } catch (e) {
      final message = e.toString();
      // Map common Supabase errors to user-friendly Spanish messages
      if (message.contains('email_rate_limit')) {
        throw Exception(
          'Demasiados intentos. Espera unos minutos e intenta de nuevo',
        );
      }
      if (message.contains('Email not') || message.contains('email_already')) {
        throw Exception('Este correo electrónico ya está registrado');
      }
      if (message.contains('password')) {
        throw Exception(
          'La contraseña no cumple con los requisitos de seguridad',
        );
      }
      if (message.contains('network') ||
          message.contains('connect') ||
          message.contains('fetch')) {
        throw Exception('Error de conexión. Verifica tu conexión a internet');
      }
      throw Exception('Error en registro: $message');
    }
  }

  @override
  Future<UserEntity> signIn(String email, String password) async {
    try {
      final authResponse = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);

      if (authResponse.user == null) {
        throw Exception('Credenciales inválidas');
      }

      // Fetch the role from the profiles table
      final role = await _getUserRole(authResponse.user!.id);

      return _mapSupabaseUserToEntity(authResponse.user!, role);
    } catch (e) {
      final message = e.toString();
      if (message.contains('Invalid login') ||
          message.contains('credentials')) {
        throw Exception('Correo o contraseña incorrectos');
      }
      throw Exception('Error al iniciar sesión: $message');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return null;

      // Fetch the role from the profiles table
      final role = await _getUserRole(user.id);

      return _mapSupabaseUserToEntity(user, role);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> hasAcceptedConsent(String userId, String documentVersion) async {
    try {
      final response = await Supabase.instance.client
          .from('consents')
          .select('id')
          .eq('patient_id', userId)
          .eq('document_version', documentVersion)
          .maybeSingle();

      return response != null;
    } catch (e) {
      // If error (e.g. network), assume not accepted for safety
      return false;
    }
  }

  @override
  Future<void> saveConsent(String userId, String documentVersion) async {
    try {
      await Supabase.instance.client.from('consents').insert({
        'patient_id': userId,
        'document_version': documentVersion,
        'terms_accepted': true,
      });
    } catch (e) {
      throw Exception('Error al guardar el consentimiento: ${e.toString()}');
    }
  }

  /// Fetches the user role from the 'profiles' table.
  /// Defaults to [UserRole.patient] if not found or on error.
  Future<UserRole> _getUserRole(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();

      return UserRole.fromString(data['role'] as String?);
    } catch (e) {
      // For safety, fallback to patient role if profile cannot be read
      return UserRole.patient;
    }
  }

  /// Convert Supabase User to domain UserEntity with explicitly provided role
  UserEntity _mapSupabaseUserToEntity(User user, UserRole role) {
    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'],
      createdAt: _parseDateTime(user.createdAt),
      role: role,
    );
  }

  /// Safely parse createdAt from various Supabase formats.
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}
