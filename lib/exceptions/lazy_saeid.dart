class LazySaeidException implements Exception {
  String message;
  LazySaeidException(this.message);
  @override
  String toString() {
    return message;
  }
}
