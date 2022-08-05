
import 'package:focus5task/data/AlarmItem.dart';
import 'package:hive/hive.dart';

String getForegroundTimeFomat(int n ){
  String format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
  return format ( Duration(seconds: n) );
}

// 알람종료시 로그저장
Future<void> addAlarmItem(String desc, String startTime, String endTime, int type) async {
  var box = await Hive.openBox('focusTimer');
  var al = AlarmItem(
    desc : desc,
    startTime: startTime,
    endTime: endTime,
    type: 1
  );

  var ids = DateTime.now().toString();
  await box.put(ids, al);
}

// 알람종료시 로그저장
Future<List <AlarmItem>> getAlarmItems() async {
  var box = await Hive.openBox('focusTimer');
  
  List <AlarmItem> lst =[];
  for(var i = 0; i < box.length; i++){
    var item = await box.getAt(i);
    lst.add(item);
  }

  return lst;
}

Future<void> debugPrintHive() async {
  var box = await Hive.openBox('focusTimer');
  for (var i = 0; i < box.length; i++){
      var item = box.getAt(i) as AlarmItem;
      print ("🍕 desc: ${item.desc} startTime:  ${item.startTime} endTime:  ${item.endTime} type:  ${item.type} " );
  }
  
}