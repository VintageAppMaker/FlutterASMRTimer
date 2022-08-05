import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:focus5task/pages/CountDownTimerPage.dart';
import 'package:focus5task/pages/MissionHistoryPage.dart';
import 'package:focus5task/util/Util.dart';
import 'package:focus5task/util/foregroundUtil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wakelock/wakelock.dart';

import 'data/AlarmItem.dart';

void main() async{
  runApp(const MainApp());
  Wakelock.enable();

  await Hive.initFlutter();
  Hive.registerAdapter(AlarmItemAdapter());

  debugPrintHive();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
  ));
}

void startCallback() {
  FlutterForegroundTask.setTaskHandler(CountTaskHandler());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: "noto"),
      initialRoute: '/',
      routes: {
        '/': (context) => const CountdownPage(),
        '/history': (context) => MissionHistoryPage(),
      },
    );
  }
}

