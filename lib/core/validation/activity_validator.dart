class ActivityValidator {
  ActivityValidator._();

  static const _titleMaxLength = 200;

  /// Returns null if [value] is a valid activity title; an error message otherwise.
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required.';
    }
    if (value.length > _titleMaxLength) {
      return 'Title must be at most $_titleMaxLength characters.';
    }
    return null;
  }

  /// Returns null if [value] is a valid due date; an error message otherwise.
  /// A valid due date is not null and is not before the current calendar date.
  static String? validateDueDate(DateTime? value) {
    if (value == null) {
      return 'Due date is required.';
    }
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final pickedDate = DateTime(value.year, value.month, value.day);
    if (pickedDate.isBefore(todayDate)) {
      return 'Due date cannot be in the past.';
    }
    return null;
  }

  /// Returns null if [customerId] is a valid customer selection; an error message otherwise.
  static String? validateCustomer(String? customerId) {
    if (customerId == null || customerId.trim().isEmpty) {
      return 'Please select a customer.';
    }
    return null;
  }
}
