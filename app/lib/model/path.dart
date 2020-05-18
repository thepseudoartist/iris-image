
import 'package:hive/hive.dart';

part 'path.g.dart';

@HiveType(typeId: 0)
class Path {
  @HiveField(0)
  String imagePath;

  @HiveField(1)
  String id;
}