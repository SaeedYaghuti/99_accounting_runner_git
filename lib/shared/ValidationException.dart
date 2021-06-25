class ValidationException implements Exception {
  String message;
  ValidationException(this.message);
  @override
  String toString() {
    return message;
  }
}
