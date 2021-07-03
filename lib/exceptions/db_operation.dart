class DBOperationException implements Exception {
  String message;
  DBOperationException(this.message);
  @override
  String toString() {
    return message;
  }
}
