int seconsdOfDateTime(DateTime time) {
  return (time.millisecondsSinceEpoch / 1000).round();
}

DateTime secondsToDateTime(int seconds) {
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
}
