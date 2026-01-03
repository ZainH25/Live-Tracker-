import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'location_task_handler.dart';

class ForegroundService {
  static Future<void> start() async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) return;

    await FlutterForegroundTask.startService(
      notificationTitle: 'Live Location Active',
      notificationText: 'Tracking location in background',
      callback: startCallback,
    );
  }

  static void stop() {
    FlutterForegroundTask.stopService();
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}
