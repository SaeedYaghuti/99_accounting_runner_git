class AccessDeniedException implements Exception {
  String message;
  AccessDeniedException(this.message);
  @override
  String toString() {
    return message;
  }
}
