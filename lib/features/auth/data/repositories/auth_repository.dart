import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';

/// Implementación concreta de IAuthRepository (Capa de Datos).
/// Maneja llamadas a Supabase Auth y mapeo de entidades.
/// La creación del perfil la realiza el trigger de base de datos
/// (on_auth_user_created), no es necesaria inserción manual desde Flutter.
class AuthRepository implements IAuthRepository {
  @override
  Future<UserEntity> register(String email, String password) async {
    try {
      // Sign up user in Supabase Auth.
      // The database trigger (on_auth_user_created) automatically
      // creates the profile row — no manual insert needed from Flutter.
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Error en registro: no se creó el usuario');
      }

      return _mapSupabaseUserToEntity(authResponse.user!);
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

      return _mapSupabaseUserToEntity(authResponse.user!);
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
      return _mapSupabaseUserToEntity(user);
    } catch (e) {
      return null;
    }
  }

  /// Convert Supabase User to domain UserEntity
  UserEntity _mapSupabaseUserToEntity(User user) {
    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'],
      createdAt: _parseDateTime(user.createdAt),
    );
  }

  /// Safely parse createdAt from various Supabase formats.
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}
