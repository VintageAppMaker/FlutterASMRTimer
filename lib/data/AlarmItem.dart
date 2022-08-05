import 'package:hive/hive.dart';
part 'AlarmItem.g.dart';

@HiveType(typeId: 1)
class AlarmItem {
  AlarmItem({required this.desc, required this.type, required this.startTime, required this.endTime});

  @HiveField(0)
  late String desc;

  @HiveField(1)
  late int type;

  @HiveField(2)
  late String startTime;

  @HiveField(3)
  late String endTime;

}