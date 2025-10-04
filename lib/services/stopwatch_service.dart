import 'dart:async';
import 'package:clock_sessions/services/notification_service.dart';
import 'package:flutter/foundation.dart';

class StopwatchService extends ChangeNotifier {
  final NotificationService _notificationService;
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  Duration _elapsed = Duration.zero;
  bool _fiveHourNotificationSent = false;

  StopwatchService(this._notificationService);

  bool get isRunning => _stopwatch.isRunning;
  Duration get elapsed => _elapsed;

  void start() {
    if (!isRunning) {
      _fiveHourNotificationSent = false;
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
      notifyListeners();
    }
  }

  void stop() {
    if (isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
      _elapsed = _stopwatch.elapsed;
      notifyListeners();
    }
  }

  void reset() {
    _stopwatch.reset();
    _elapsed = Duration.zero;
    notifyListeners();
  }

  void _onTick(Timer timer) {
    _elapsed = _stopwatch.elapsed;
    if (!_fiveHourNotificationSent && _elapsed.inHours >= 5) {
      _notificationService.showNotification(
        'Congratulations!',
        'You have completed 5 hours at the office.',
      );
      _fiveHourNotificationSent = true;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}