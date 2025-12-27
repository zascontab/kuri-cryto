import 'dart:async';

/// Debouncer utility to prevent excessive function calls
///
/// Useful for search inputs, API calls, and other operations
/// that should not be triggered too frequently.
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  /// Execute the function after the delay
  /// If called again before the delay expires, the previous call is cancelled
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel any pending execution
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Check if there's a pending execution
  bool get isActive => _timer?.isActive ?? false;

  /// Dispose of the debouncer
  void dispose() {
    cancel();
  }
}

/// Throttler utility to limit function execution frequency
///
/// Unlike debouncer, throttler ensures the function is called
/// at most once per time period, regardless of how many times
/// it's triggered.
class Throttler {
  final Duration duration;
  DateTime? _lastExecution;

  Throttler({required this.duration});

  /// Execute the function if enough time has passed since last execution
  void call(void Function() action) {
    final now = DateTime.now();

    if (_lastExecution == null || now.difference(_lastExecution!) >= duration) {
      _lastExecution = now;
      action();
    }
  }

  /// Reset the throttler
  void reset() {
    _lastExecution = null;
  }

  /// Check if the throttler is currently blocking execution
  bool get isBlocked {
    if (_lastExecution == null) return false;
    return DateTime.now().difference(_lastExecution!) < duration;
  }
}

/// AsyncDebouncer for async operations
class AsyncDebouncer {
  final Duration delay;
  Timer? _timer;
  Completer<void>? _completer;

  AsyncDebouncer({required this.delay});

  /// Execute the async function after the delay
  Future<T> call<T>(Future<T> Function() action) async {
    _timer?.cancel();
    _completer?.complete();

    final completer = Completer<T>();
    _completer = Completer<void>();

    _timer = Timer(delay, () async {
      try {
        final result = await action();
        completer.complete(result);
      } catch (error) {
        completer.completeError(error);
      }
    });

    return completer.future;
  }

  /// Cancel any pending execution
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _completer?.complete();
    _completer = null;
  }

  /// Check if there's a pending execution
  bool get isActive => _timer?.isActive ?? false;

  /// Dispose of the debouncer
  void dispose() {
    cancel();
  }
}
