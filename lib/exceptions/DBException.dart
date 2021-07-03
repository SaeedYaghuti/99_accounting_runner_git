class DBException implements Exception {
  String message;
  DBException(this.message);
  @override
  String toString() {
    return message;
  }
}
