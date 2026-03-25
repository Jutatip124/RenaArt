/// Centralized validation service for input validation.
/// Provides reusable validators with consistent error messages.
class ValidationService {
  ValidationService._();
  static final ValidationService instance = ValidationService._();

  // Email validation
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Username validation (alphanumeric and underscore, 3-20 chars)
  static final _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  // Detect potential PII in text (for bug reports)
  static final _emailPatternInText = RegExp(
    r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b',
  );
  static final _phonePattern = RegExp(
    r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b|\b\d{10}\b',
  );

  /// Validate email format
  ValidationResult validateEmail(String email) {
    if (email.isEmpty) {
      return ValidationResult.error('Email is required');
    }
    if (!_emailRegex.hasMatch(email)) {
      return ValidationResult.error('Please enter a valid email address');
    }
    if (email.length > 254) {
      return ValidationResult.error('Email is too long');
    }
    return ValidationResult.success();
  }

  /// Validate password strength
  ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult.error('Password is required');
    }
    if (password.length < 6) {
      return ValidationResult.error('Password must be at least 6 characters');
    }
    if (password.length > 128) {
      return ValidationResult.error('Password is too long');
    }
    // Check for common weak passwords
    final weakPasswords = ['password', '123456', 'qwerty', 'abc123'];
    if (weakPasswords.contains(password.toLowerCase())) {
      return ValidationResult.error('Password is too weak. Please choose a stronger password');
    }
    return ValidationResult.success();
  }

  /// Validate username format
  ValidationResult validateUsername(String username) {
    if (username.isEmpty) {
      return ValidationResult.error('Username is required');
    }
    if (username.length < 3) {
      return ValidationResult.error('Username must be at least 3 characters');
    }
    if (username.length > 20) {
      return ValidationResult.error('Username must be 20 characters or less');
    }
    if (!_usernameRegex.hasMatch(username)) {
      return ValidationResult.error(
        'Username can only contain letters, numbers, and underscores',
      );
    }
    // Check for reserved usernames
    final reserved = ['admin', 'root', 'system', 'guest', 'anonymous'];
    if (reserved.contains(username.toLowerCase())) {
      return ValidationResult.error('This username is reserved');
    }
    return ValidationResult.success();
  }

  /// Validate nickname/display name
  ValidationResult validateNickname(String nickname) {
    if (nickname.isEmpty) {
      return ValidationResult.error('Nickname is required');
    }
    if (nickname.length < 2) {
      return ValidationResult.error('Nickname must be at least 2 characters');
    }
    if (nickname.length > 50) {
      return ValidationResult.error('Nickname must be 50 characters or less');
    }
    // Remove excessive whitespace
    final trimmed = nickname.trim();
    if (trimmed != nickname) {
      return ValidationResult.warning('Nickname has extra whitespace');
    }
    return ValidationResult.success();
  }

  /// Sanitize and validate bug report description
  ValidationResult validateBugReport(String description) {
    if (description.isEmpty) {
      return ValidationResult.error('Description is required');
    }
    if (description.length < 10) {
      return ValidationResult.error('Please provide more details (at least 10 characters)');
    }
    if (description.length > 2000) {
      return ValidationResult.error('Description is too long (max 2000 characters)');
    }

    // Check for potential PII
    final warnings = <String>[];
    if (_emailPatternInText.hasMatch(description)) {
      warnings.add('Email address detected');
    }
    if (_phonePattern.hasMatch(description)) {
      warnings.add('Phone number detected');
    }

    if (warnings.isNotEmpty) {
      return ValidationResult.warning(
        'Warning: Your report may contain personal information (${warnings.join(', ')}). '
        'Please remove sensitive data before submitting.',
      );
    }

    return ValidationResult.success();
  }

  /// Sanitize user input by removing potentially dangerous characters
  String sanitizeInput(String input) {
    // Remove control characters and normalize whitespace
    return input
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Validate password confirmation
  ValidationResult validatePasswordConfirmation(String password, String confirmation) {
    if (confirmation.isEmpty) {
      return ValidationResult.error('Please confirm your password');
    }
    if (password != confirmation) {
      return ValidationResult.error('Passwords do not match');
    }
    return ValidationResult.success();
  }
}

/// Result of a validation operation
class ValidationResult {
  final bool isValid;
  final String? message;
  final ValidationLevel level;

  ValidationResult._(this.isValid, this.message, this.level);

  factory ValidationResult.success() {
    return ValidationResult._(true, null, ValidationLevel.success);
  }

  factory ValidationResult.error(String message) {
    return ValidationResult._(false, message, ValidationLevel.error);
  }

  factory ValidationResult.warning(String message) {
    return ValidationResult._(true, message, ValidationLevel.warning);
  }

  bool get hasWarning => level == ValidationLevel.warning;
  bool get hasError => level == ValidationLevel.error;
}

enum ValidationLevel {
  success,
  warning,
  error,
}
