class EmailValidator {
  EmailValidator._();

  static const _localPartMaxLength = 64;
  static const _domainMaxLength = 255;

  /// Returns null if [value] is a valid email address; an error message otherwise.
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    final parts = value.split('@');
    if (parts.length != 2) return 'Enter a valid email address.';
    final local = parts[0];
    final domain = parts[1];
    if (local.isEmpty || local.length > _localPartMaxLength) {
      return 'Enter a valid email address.';
    }
    if (domain.isEmpty || domain.length > _domainMaxLength || !domain.contains('.')) {
      return 'Enter a valid email address.';
    }
    return null;
  }
}
