import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'misc.dart';

//* Wrapper Class for Hive package

class HiveUtil {
  static const String _HIVE_BOX = 'path';
  static final HiveUtil instance = HiveUtil._internal();

  HiveUtil._internal();

  Future<void> init(TypeAdapter adapter) async {
    final appDocDir = await getApplicationDocumentsDirectory();

    Hive.init(appDocDir.path);
    Hive.registerAdapter(adapter);
  }

  Future<Box> openBox() =>
      Hive.openBox(_HIVE_BOX, compactionStrategy: (e, d) => d > 10);

  Box _box() => Hive.box(_HIVE_BOX);

  int get size => _box().length;

  Future<void> close() => Hive.close();

  void add<T>(T data) => _box().add(data);

  T getItem<T>(int index) => _box().getAt(index);

  Future<void> clear() async {
    final dirPath = await Utility.getAppDir();
    final directory = Directory(dirPath);

    if (directory.path == null) return;

    directory.deleteSync(recursive: true);

    _box().clear();
  }

  void del(int index) => _box().deleteAt(index);
}
