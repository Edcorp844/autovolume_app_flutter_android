mixin KotlinDurationHandler {
  String formatDuration(Duration duration) {
    return [
      duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
      duration.inSeconds.remainder(60).toString().padLeft(2, '0'),
    ].join(':');
  }
}
