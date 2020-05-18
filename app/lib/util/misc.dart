import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

//* Utility class containing Misc functions

class Utility {
  static void showToast({
    @required String msg,
    Toast length = Toast.LENGTH_SHORT,
    Color textColor = Colors.white,
    Color bgColor = Colors.amber,
  }) =>
      Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        textColor: textColor,
        backgroundColor: bgColor,
      );


  static void logError(String code, String msg) =>
      print('Error: $code\nMessage: $msg');


  static String _timeStamp() =>
      DateTime.now().millisecondsSinceEpoch.toString();


  static Future<String> getPath() async {
    final String dirPath = await getAppDir();
    String filePath = '$dirPath/test-${_timeStamp()}.jpg';

    await Directory(dirPath).create(recursive: true);

    return Future.value(filePath);
  }


  static Future<String> getAppDir() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/Iris';

    return Future.value(dirPath);
  }


  static Future<ByteData> getBytesFromFile(File imageFile) async {
    Uint8List bytes = imageFile.readAsBytesSync();
    return ByteData.view(bytes.buffer);
  }
}
