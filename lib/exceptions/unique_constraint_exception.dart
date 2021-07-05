class UniqueConstraintException {
  String message;
  UniqueConstraintException(this.message);
  @override
  String toString() {
    return message;
  }
}
