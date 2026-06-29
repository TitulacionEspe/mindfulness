class AuthValidators {
  AuthValidators._();

  static const int minFullNameLength = 3;
  static const int maxFullNameLength = 50;
  static const int requiredNameWords = 2;
  static const int maxEmailLength = 254;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 30;
  static const String allowedPasswordSpecialChars = '*.@';

  static String normalizeName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String normalizeEmail(String value) {
    return value.trim().toLowerCase();
  }

  static String? fullName(String? value) {
    final normalized = normalizeName(value ?? '');
    if (normalized.isEmpty) return 'Ingresa tu nombre y apellido.';
    if (normalized.length < minFullNameLength) {
      return 'El nombre debe tener al menos $minFullNameLength caracteres.';
    }
    if (normalized.length > maxFullNameLength) {
      return 'El nombre no debe superar $maxFullNameLength caracteres.';
    }

    final words = normalized.split(' ');
    if (words.length != requiredNameWords) {
      return 'Ingresa solo un nombre y un apellido.';
    }

    if (!RegExp(r"^[a-zA-ZÀ-ÿÑñ' -]+$").hasMatch(normalized)) {
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
    if (!hasValidPasswordLength(password)) {
      return 'La contraseña debe tener entre $minPasswordLength y $maxPasswordLength caracteres.';
    }
    if (password.trim().isEmpty) {
      return 'La contraseña no puede estar compuesta solo por espacios.';
    }
    if (password != password.trim()) {
      return 'Evita espacios al inicio o al final de la contraseña.';
    }
    if (!hasUppercase(password)) {
      return 'Incluye al menos una letra mayúscula.';
    }
    if (!hasLowercase(password)) {
      return 'Incluye al menos una letra minúscula.';
    }
    if (!hasNumber(password)) {
      return 'Incluye al menos un número.';
    }
    if (hasInvalidPasswordCharacter(password)) {
      return 'Usa solo letras, números y los caracteres especiales *, . o @.';
    }
    if (!hasAllowedSpecialCharacter(password)) {
      return 'Incluye al menos un carácter especial: *, . o @.';
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

  static bool hasValidPasswordLength(String value) {
    return value.length >= minPasswordLength &&
        value.length <= maxPasswordLength;
  }

  static bool hasUppercase(String value) =>
      RegExp(r'[A-ZÀ-ÝÑ]').hasMatch(value);

  static bool hasLowercase(String value) =>
      RegExp(r'[a-zà-ÿñ]').hasMatch(value);

  static bool hasNumber(String value) => RegExp(r'\d').hasMatch(value);

  static bool hasAllowedSpecialCharacter(String value) {
    return RegExp(r'[*\.@]').hasMatch(value);
  }

  static bool hasInvalidPasswordCharacter(String value) {
    return RegExp(r'[^A-Za-zÀ-ÿÑñ0-9*\.@]').hasMatch(value);
  }

  static bool passwordsMatch(String password, String confirmation) {
    return confirmation.isNotEmpty && password == confirmation;
  }
}
