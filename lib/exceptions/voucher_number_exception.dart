class VoucherNumberException implements Exception {
  String message;
  VoucherNumberException(this.message);
  @override
  String toString() {
    return message;
  }
}
