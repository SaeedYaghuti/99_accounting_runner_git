class DirtyDatabaseException implements Exception {
  String message;
  DirtyDatabaseException(this.message);
  @override
  String toString() {
    return message;
  }
}
