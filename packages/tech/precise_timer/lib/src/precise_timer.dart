import 'dart:async';

class PreciseTimer {
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  Duration get elapsed => _stopwatch.elapsed;
  bool get isRunning => _stopwatch.isRunning;

  void start() {
    _timer?.cancel();
    _stopwatch = Stopwatch();
    _stopwatch.start();
  }

  void stop() => _stopwatch.stop();
  void reset() => _stopwatch.reset();

  void pause() {
    if (!_stopwatch.isRunning) return;
    _stopwatch.stop();
  }

  void resume() {
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
  }

  void timerCallback(void Function(Duration) callback) {
    _timer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => callback(_stopwatch.elapsed),
    );
  }

  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
  }
}
