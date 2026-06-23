class AuthValidators {
  AuthValidators._();

  static const int minFullNameLength = 3;
  static const int maxFullNameLength = 80;
  static const int maxEmailLength = 254;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 72;

  static String normalizeName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String normalizeEmail(String value) {
    return value.trim().toLowerCase();
  }

  static String? fullName(String? value) {
    final normalized = normalizeName(value ?? '');
    if (normalized.isEmpty) return 'Ingresa tu nombre completo.';
    if (normalized.length < minFullNameLength) {
      return 'El nombre debe tener al menos $minFullNameLength caracteres.';
    }
    if (normalized.length > maxFullNameLength) {
      return 'El nombre no debe superar $maxFullNameLength caracteres.';
    }
    if (!RegExp(r"^[a-zA-ZÀ-ÿ' -]+$").hasMatch(normalized)) {
      return 'Usa solo letras, espacios, guiones o apóstrofes.';
    }
    return null;
  }

  static String? email(String? value) {
    final normalized = normalizeEmail(value ?? '');
    if (normalized.isEmpty) return 'Ingresa tu correo.';
    if (normalized.length > maxEmailLength) {
      return 'El correo no debe superar $maxEmailLength caracteres.';
    }
    if (!RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    ).hasMatch(normalized)) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  static String? requiredPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Ingresa tu contraseña.';
    return null;
  }

  static String? securePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Ingresa una contraseña.';
    if (password.length < minPasswordLength) {
      return 'La contraseña debe tener al menos $minPasswordLength caracteres.';
    }
    if (password.length > maxPasswordLength) {
      return 'La contraseña no debe superar $maxPasswordLength caracteres.';
    }
    if (password.trim().isEmpty) {
      return 'La contraseña no puede estar compuesta solo por espacios.';
    }
    if (password != password.trim()) {
      return 'Evita espacios al inicio o al final de la contraseña.';
    }
    if (!RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(password)) {
      return 'Incluye al menos una letra.';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Incluye al menos un número.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String originalPassword) {
    final passwordError = securePassword(value);
    if (passwordError != null) return passwordError;
    if ((value ?? '') != originalPassword) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }
}
