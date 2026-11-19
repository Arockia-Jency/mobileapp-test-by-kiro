class PasswordValidator {
  PasswordValidator._();

  static const _minLength = 6;
  static const _maxLength = 128;

  /// Returns null if [value] is a valid password; an error message otherwise.
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < _minLength) {
      return 'Password must be at least $_minLength characters.';
    }
    if (value.length > _maxLength) {
      return 'Password must be at most $_maxLength characters.';
    }
    return null;
  }
}
