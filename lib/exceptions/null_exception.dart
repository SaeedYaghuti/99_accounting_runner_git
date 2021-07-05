class NullException implements Exception {
  String message;
  NullException(this.message);
  @override
  String toString() {
    return message;
  }
}
