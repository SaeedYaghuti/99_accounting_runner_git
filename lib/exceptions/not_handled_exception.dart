class NotHandledException implements Exception {
  String message;
  NotHandledException(this.message);
  @override
  String toString() {
    return '@ < $message > you did not handled an element!';
  }
}
