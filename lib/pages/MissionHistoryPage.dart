import 'dart:async';

import 'package:flutter/material.dart';
import 'package:focus5task/util/Util.dart';
import 'package:focus5task/widgets/Timeline.dart';
import 'package:focus5task/widgets/WaterEffect.dart';

class MissionHistoryPage extends StatefulWidget {
  @override
  State<MissionHistoryPage> createState() => _MissionHistoryPageState();
}

class _MissionHistoryPageState extends State<MissionHistoryPage> {
  late Timer _timer; 
  var header = SizedBox(height: 46, width : double.infinity, child: Text(""));
  int  nTypeIndx = 0;

  @override
  void initState() {
    _timer = Timer.periodic(Duration(seconds: 8), (timer) {
      setState(() {
        // 코딩스타일 주의 - 아래코드 적용안됨 
        // nTypeIndx = nTypeIndx++ % 4 
        nTypeIndx++;
        nTypeIndx = nTypeIndx % 4;
      });
     });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WaterEffect(colorIndx: nTypeIndx, alpha: .3, backWidget: Text(""), frontWidget: Container(child: Center(
        child: Column(
          children: [
            header,
            _buildAlarmLogList(),
          ],
        ),
      ),),),
    );
  }

  // Alarm 로그리스트 
  Expanded _buildAlarmLogList() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(future: _buildAlramItems(), 
              builder: ((context, snapshot) {
                if(snapshot.hasData){
                  return Timeline(
                    children:  [ for (var i in snapshot.data as List<TimelineItem>) i  ]);
                    
                } else {
                  return const CircularProgressIndicator();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  // future builder의 UI로 전송  
  Future<List<TimelineItem>> _buildAlramItems() async{
    var lst      = await getAlarmItems();
    var children = <TimelineItem>[];
    for (var i = 0; i < lst.length; i++ ){
      String title    = "⌈ ${lst[i].desc} ⌋";
      String subtitle = "start: ${lst[i].startTime} \nend: ${lst[i].endTime}";
      
      children.add(
        TimelineItem(
          child: ListTile(key: UniqueKey(), 
          title: Text(title, style: TextStyle(fontSize: 20, color: Colors.white),), 
          subtitle: Text(subtitle, style: TextStyle(color: Colors.white),),),
          indicator: (i % 2 ==0) ? Icon(Icons.alarm_on, color: Colors.white) : Icon(Icons.alarm_off, color: Colors.white54),
        )
      );
    }

    return children;
  }
}

