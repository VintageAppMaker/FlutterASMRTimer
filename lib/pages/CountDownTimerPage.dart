import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:focus5task/util/ThemeColors.dart';
import 'package:focus5task/util/Util.dart';
import 'package:focus5task/util/define.dart';
import 'package:focus5task/util/foregroundUtil.dart';
import 'package:focus5task/widgets/ExpandableFAB.dart';
import 'package:focus5task/widgets/SImpleDialogWidget.dart';
import 'package:focus5task/widgets/WaterEffect.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:intl/intl.dart';


class CountdownPage extends StatefulWidget {
  const CountdownPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  ReceivePort? _receivePort;
  String sCountDownInfo = "";
  int nTickCount = 0;
  double waterAlpha = 0.9;
  
  int MAX_TICK_COUNT = 60 * 30;
  String notificationTitle ="";

  // 알람시작정보
  String AlarmStartTime  = "";
  int    AlarmtypeIndx   = 0 ;
  String AlarmDesc       = "";

  // Fab 메인버튼처리를 위한 GlobalKey
  var fabKey = GlobalKey();

  List<AnimatedText> _animatedTextList = [
    for (var emoji in emojies)
      TypewriterAnimatedText(emoji, speed: Duration(milliseconds: 200))
  ];

  Future<void> _initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'focusTimer_channel_id',
        channelName: 'focusTimer',
        channelDescription: 'focus timer is running',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Color(0xC733E0C6),
        ),
        buttons: [
          const NotificationButton(id: 'closeButton', text: 'close'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 1000,
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
      printDevLog: true,
    );
  }

  Future<bool> _startForegroundTask() async {
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        return false;
      }
    }

    
    bool reqResult;
    if (await FlutterForegroundTask.isRunningService) {
      reqResult = await FlutterForegroundTask.restartService();
    } else {
      reqResult = await FlutterForegroundTask.startService(
        notificationTitle: 'focus timer가 실행중입니다.',
        notificationText: '앱으로 이동',
        callback: startCallback,
      );
    }

    // 기타정보저장
    await FlutterForegroundTask.saveData(key: 'title', value: notificationTitle);
    
    
    ReceivePort? receivePort;
    if (reqResult) {
      receivePort = await FlutterForegroundTask.receivePort;
    }

    return _registerReceivePort(receivePort);
  }

  Future<bool> _stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? receivePort) {
    _closeReceivePort();

    // 정보수신처리 
    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {
        if (message is int) {
          setState(() {
            nTickCount = message;
            waterAlpha = getAlpahByTickcount();
            sCountDownInfo = getForegroundTimeFomat(message);

            // 최대값을 넘어가면 종료
            if (nTickCount >= MAX_TICK_COUNT) {
              saveEndAlarmInfo();

              _stopForegroundTask();
              setClearValue();
            }
          });
        } else if (message is String) {
          if (message == 'onNotificationPressed') {
            Navigator.of(context).pushNamed('/');
          }

          if (message == 'onCloseService') {
            _stopForegroundTask();
            setClearValue();
          }
        } 

      });

      return true;
    }

    return false;
  }

  // 알람종료정보를 저장한다.
  void saveEndAlarmInfo() {
    DateTime now = DateTime.now();
    var AlarmEndTime = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
    
    addAlarmItem(AlarmDesc, AlarmStartTime, AlarmEndTime, AlarmtypeIndx);
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  T? _ambiguate<T>(T? value) => value;

  @override
  void initState() {
    super.initState();
    _initForegroundTask();
    _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = await FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
  }

  @override
  void dispose() {
    _closeReceivePort();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: Scaffold(
        body: _buildContentView(),
      ),
    );
  }

  void setStartValue() {
    setState(() {
      showSnackBar("티이머 시작합니다");
    });
  }

  void showSnackBar(String s) {
    final snackBar = SnackBar(
        backgroundColor: Colors.transparent,
        duration: Duration(seconds: 2),
        content: Text(s));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void setClearValue() {
    setState(() {
      showSnackBar("타이머 종료합니다");

      nTickCount = 0;
      sCountDownInfo = "";
    });
  }

  Widget _buildContentView() {
    void closeExpandableFab(){
      var c = fabKey.currentState as ExpandableFabState;
      c.toggle();
    }

    return Scaffold(
      floatingActionButton: ExpandableFab(
        key: fabKey, 
        color: themeWaterColors[AlarmtypeIndx][0],
        distance: 90,
        children: [
          ActionButton(
            color: themeWaterColors[AlarmtypeIndx][0],
            onPressed: () {
              showSelectSimpleDialog(context, "시간설정", ["25분", "45분", "1시간", "1시간25분"],
                  (String select_title, String desc) {
                if (select_title == "25분") {
                  AlarmtypeIndx = 0;
                  notificationTitle = "25분 Timer";
                  MAX_TICK_COUNT = 60 * 25;
                } else if (select_title == "45분") {
                  AlarmtypeIndx = 1;
                  notificationTitle = "45분 Timer";
                  MAX_TICK_COUNT = 60 * 45;
                } else if (select_title == "1시간"){
                  AlarmtypeIndx = 2;
                  notificationTitle = "1시간 Timer";
                  MAX_TICK_COUNT = 60 * 60;
                } else if (select_title == "1시간25분") {
                  AlarmtypeIndx = 3;
                  notificationTitle = "1시간25분 Timer";
                  MAX_TICK_COUNT = 60 * ( 60 + 25 );
                }

                // 알람시작정보 저장
                AlarmDesc =  desc;
                DateTime now = DateTime.now();
                AlarmStartTime = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);

                _startForegroundTask();
                setStartValue();

                closeExpandableFab();

              });
            },
            icon: const Icon(Icons.play_circle),
          ),
          ActionButton(
            color: themeWaterColors[AlarmtypeIndx][0],
            onPressed: () {
              saveEndAlarmInfo();
              
              _stopForegroundTask();
              setClearValue();

              closeExpandableFab();
            },
            icon: const Icon(Icons.stop_circle),
          ), 
          ActionButton(
            color: themeWaterColors[AlarmtypeIndx][0],
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
            icon: const Icon(Icons.note),
          )
        ],
      ),
      body: WaterEffect(
        alpha: waterAlpha,
        colorIndx: AlarmtypeIndx,
        backWidget: Center(
          child: Text('${sCountDownInfo}',
              style: TextStyle(
                  fontWeight: FontWeight.w200,
                  wordSpacing: 3,
                  color: Colors.white.withOpacity(.7)),
              textScaleFactor: 7),
        ),
        frontWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: 350.0,
                child: (nTickCount > 0)
                    ? DefaultTextStyle(
                        style: TextStyle(
                            color: themeWaterColors[AlarmtypeIndx][0],
                            fontSize: 18.0,
                            fontFamily: "noto"),
                        child: AnimatedTextKit(
                          repeatForever: (nTickCount > 0) ? true : false,
                          animatedTexts: _animatedTextList,
                          pause: Duration(seconds: 2),
                        ),
                      )
                    : Text(""),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double getAlpahByTickcount() {
    var alphalist = <double>[0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.15];
    double STEP_SIZE = MAX_TICK_COUNT / 10; 
    int nIndx = (nTickCount / STEP_SIZE).toInt();
    if (nIndx >= alphalist.length) nIndx = alphalist.length - 1;
    return alphalist[nIndx];
  }
}

class ResumeRoutePage extends StatelessWidget {
  const ResumeRoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Route'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
            Navigator.of(context).pop();
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}

