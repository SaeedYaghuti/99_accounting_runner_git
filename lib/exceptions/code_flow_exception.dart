class CodeFlowException implements Exception {
  String message;
  CodeFlowException(this.message);
  @override
  String toString() {
    return message;
  }
}
