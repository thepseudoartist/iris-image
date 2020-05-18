import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'misc.dart';

//* BASE_URL for local server.
const String BASE_URL = 'http://192.168.43.70:9000/';
const int SUCCESS_CODE = 200;

//* Contains function for interacting with server.
class APIServices {

  APIServices._();
  
  //* POST request to server to cut object from image.
  //* return: String to cut object URL.
  static Future<String> cut(File file, String fileName,
      {String baseUrl = BASE_URL}) async {
    FormData formData = FormData.fromMap({
      'name': fileName,
      'image': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    try {
      var response = await Dio().post(
        baseUrl == null ? BASE_URL : baseUrl + 'cut_img/',
        data: formData,
        options: Options(responseType: ResponseType.json),
      );

      print(response.data);

      if (response.statusCode == SUCCESS_CODE) {
        return Future.value(response.data['url']);
      }
    } catch (e) {}

    return Future.value(null);
  }

  //* Ping server after IP Changes for validity.
  static Future<bool> ping(String url) async {
    if (!Uri.parse(url).isAbsolute) return false;

    try {
      var response = await Dio().get(url);
      return response?.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  //* GET request to download cut object from server.
  //* Saves the downloaded file to provided `savePath`
  static Future<void> download(String url, String savePath) async {
    var response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    File file;

    try {
      file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      Utility.showToast(msg: 'Fetching files failed.', bgColor: Colors.red);
    }
  }

  //* Combines `cut` and `download` operation.
  static Future<String> cutAndDownload(
    File inputImage,
    String inputImageName,
    String responseSavePath, {
    String baseUrl = BASE_URL,
  }) async {
    try {
      String url = await cut(inputImage, inputImageName, baseUrl: baseUrl);
      await download(url, responseSavePath);

      return Future.value(url.split('/').last);
    } catch (e) {
      Utility.showToast(msg: 'Something went wrong.');
      return Future.value("");
    }
  }

  //* POST request to paste cut object to Adobe Photoshop
  static Future<String> paste(File file, String fileName,
      {String baseUrl = BASE_URL}) async {
    try {
      FormData formData = FormData.fromMap({
        'name': fileName,
        'image': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      var response = await Dio().post(
        baseUrl == null ? BASE_URL : baseUrl + 'paste_img/',
        data: formData,
        options: Options(responseType: ResponseType.json),
      );

      print(response.data);

      if (response.statusCode == SUCCESS_CODE) {
        return Future.value(response.data['message']);
      }
    } catch (e) {}

    return Future.value('Something\'s wrong.');
  }
}
