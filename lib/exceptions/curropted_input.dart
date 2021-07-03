class CurroptedInputException implements Exception {
  String message;
  CurroptedInputException(this.message);
  @override
  String toString() {
    return message;
  }
}
