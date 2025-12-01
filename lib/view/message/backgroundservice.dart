import 'package:workmanager/workmanager.dart';

class BackgroundService {
  static void initialize() {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  static void startBackgroundTask() {
    Workmanager().registerPeriodicTask(
      "socket-listener",
      "socketListener",
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static void stopBackgroundTask() {
    Workmanager().cancelByUniqueName("socket-listener");
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // This runs in background - maintain socket connection
      // You'll need to implement socket reconnection logic here
      print("Background task executed: $task");
      return Future.value(true);
    } catch (e) {
      print("Background task failed: $e");
      return Future.value(false);
    }
  });
}
