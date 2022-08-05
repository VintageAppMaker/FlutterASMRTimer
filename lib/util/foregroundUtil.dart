import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:focus5task/util/Util.dart';

void startCallback() {
  FlutterForegroundTask.setTaskHandler(CountTaskHandler());
}

class CountTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;
  late String title;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;
    title = await FlutterForegroundTask.getData<String>(key: 'title') ?? "focus timer";    
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: title,
      notificationText: '⏰ ${getForegroundTimeFomat( _eventCount )}'
    );

    sendPort?.send(_eventCount);
    _eventCount++;
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) async {
    print('onButtonPressed >> $id');
    if(id == "closeButton"){
      _sendPort?.send('onCloseService');
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp("/");
    _sendPort?.send('onNotificationPressed');
  }
}