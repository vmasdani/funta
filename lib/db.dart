import 'package:hive/hive.dart';

part 'db.g.dart';

@HiveType(typeId: 1)
class Note {
  Note();

  @HiveField(0)
  String? title;
  @HiveField(1)
  String? content;
  @HiveField(2)
  int? created;
  @HiveField(3)
  int? updated;
  @HiveField(4)
  int? deleted;
  @HiveField(5)
  String? uuid;
}
