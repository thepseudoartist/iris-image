import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'misc.dart';

//* Camera Utility Class: Wraps camera package

class CameraUtil {
  static final CameraUtil instance = CameraUtil._internal();

  CameraUtil._internal();

  List<CameraDescription> _listCameraDescription;
  CameraController _controller;
  bool _initialized = false;
  
  CameraDescription get rearCamera => _listCameraDescription?.first;
  CameraDescription get frontCamera => _listCameraDescription?.last;

  CameraController get controller => _controller;

  bool get isInitialized => _controller.value.isInitialized;

  double get aspectRatio => _controller.value.aspectRatio;

  Widget get cameraPreview => CameraPreview(_controller);

  void dispose() => _controller?.dispose(); 

  Future<void> init() async {
    await availableCameras().then((list) {
      _listCameraDescription = list;
      _initialized = true;
    });
  }

  Future<void> initController() async {
    assert(_initialized, "Call init before runApp() method.");

    _controller = CameraController(_listCameraDescription.first, ResolutionPreset.max);
    return _controller.initialize();
  }

  Future<String> takePicture() async {
    if (!_controller.value.isInitialized) {
      Utility.showToast(msg: 'Error: Initializing camera.');
      return null;
    }

    final filePath = await Utility.getPath();

    if (_controller.value.isTakingPicture) return null;

    try {
      await _controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return Future.value(filePath);
  }

  void _showCameraException(CameraException e) {
    Utility.logError(e.code, e.description);
    Utility.showToast(msg: 'Error: ${e.code}\n${e.description}');
  }
}