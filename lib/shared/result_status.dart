class ResultStatus {
  final bool isSuccessful;
  final String? errorMessage;
  ResultStatus(this.isSuccessful, [this.errorMessage]);
}

class Result<T> {
  final T? outcome;
  final String? errorMessage;
  Result(this.outcome, [this.errorMessage]);
}
