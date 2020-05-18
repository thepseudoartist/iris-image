import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'history_screen.dart';
import 'model/path.dart';
import 'util/api_services.dart';
import 'util/camera_util.dart';
import 'util/hive_util.dart';
import 'util/misc.dart';
import 'util/shared_prefs_util.dart';
import 'widgets.dart';

class CameraScreen extends StatefulWidget {
  static const String routeName = '/';
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  bool _extracted = false, _loading = false, _bottomSheetVisible = false;
  int _rotation = 1; //* Temporary fix to counter EXIF Rotation issue.
  Path _path;
  String _baseUrl;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    CameraUtil.instance.initController().then((_) {
      if (!mounted) return;
      setState(() {});
    });

    SharedPrefsUtil.getBaseUrl().then((url) {
      _baseUrl = url;
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive)
      CameraUtil.instance.dispose();
    else if (state == AppLifecycleState.resumed)
      CameraUtil.instance.initController().then((_) {
        if (!mounted) return;

        setState(() {});
      });
  }

  //! OnButtonPress callbacks...

  void _onTapTakePicture() {
    setState(() => _loading = true);

    CameraUtil.instance.takePicture().then((String filePath) {
      if (filePath != null)
        Utility.showToast(
            msg: 'Processing. Please wait.', bgColor: Colors.greenAccent);

      String fileName = filePath.split('/').last;
      File file = File(filePath);

      APIServices.cutAndDownload(file, fileName, filePath, baseUrl: _baseUrl)
          .then((String id) {
        setState(() {
          _path = Path()
            ..imagePath = filePath
            ..id = id;

          _extracted = true;
          _loading = false;
          _rotation = 1;

          HiveUtil.instance.add(_path);
        });
      });
    });
  }

  void _sendPictureToPS() {
    CameraUtil.instance.takePicture().then((String uri) {
      if (uri != null) {
        setState(() => _loading = true);

        File file = File(uri);

        APIServices.paste(file, _path.id, baseUrl: _baseUrl).then((String str) {
          Utility.showToast(msg: str, bgColor: Colors.green);
          setState(() {
            _loading = false;
            _path = null;
            _extracted = false;
          });
        });
      } else
        Utility.showToast(msg: 'Null values.');
    });
  }

  void _onClearScreenButtonPressed() {
    _extracted
        ? setState(
            () {
              _path = null;
              _extracted = false;
              Navigator.pop(context);
            },
          )
        : Utility.showToast(msg: "Nothing to clear.", bgColor: Colors.blue);
  }

  void _onImagePickerButtonPressed() {
    ImagePicker.pickImage(source: ImageSource.gallery)
        .then((File imageFile) async {
      if (imageFile == null || imageFile?.path == null) {
        Utility.showToast(
            msg: 'No file was selected.', bgColor: Colors.redAccent);

        return;
      }

      setState(() => _loading = true);

      String fileName = imageFile.path.split('/').last;

      APIServices.cut(imageFile, fileName, baseUrl: _baseUrl)
          .then((String url) async {
        final filePath = await Utility.getPath();

        APIServices.download(url, filePath).then((_) {
          setState(() {
            String id = url.split('/').last;

            _path = Path()
              ..imagePath = filePath
              ..id = id;

            _extracted = true;
            _loading = false;
            _rotation = 0;

            HiveUtil.instance.add(_path);
          });
        });
      });
    });
  }

  void _onShareSelectionButtonPressed() {
    _extracted && _path != null
        ? Utility.getBytesFromFile(File(_path.imagePath)).then((bytes) {
            Share.file("Share via:", _path.imagePath.split('/').last,
                bytes.buffer.asUint8List(), 'image/png');
          })
        : Utility.showToast(
            msg: "Select some image first.",
            bgColor: Colors.redAccent,
          );
  }

  void _onIPTextChanged(String newBaseUrl) async {
    bool valid = await APIServices.ping(newBaseUrl);

    if (valid) SharedPrefsUtil.setBaseUrl(newBaseUrl);

    Utility.showToast(
      msg: valid
          ? 'IP Changed.'
          : 'Invalid URL. Make sure to append "http://" and "/" at the end.',
      bgColor: valid ? Colors.lightGreen : Colors.redAccent,
      length: Toast.LENGTH_LONG,
    );

    _baseUrl = newBaseUrl;
  }

  void _onOpenHistoryButtonPressed() async =>
      Navigator.pushNamed(context, HistoryScreen.routeName,
          arguments: _baseUrl);

  //! Bottom Sheet Toggle

  void _toggleBottomSheet(DragUpdateDetails details) {
    //* If swipe up then open else close
    if (details.delta.direction < 0 && scaffoldKey.currentState != null)
      scaffoldKey.currentState.showBottomSheet(
        (context) {
          _bottomSheetVisible = true;

          return Container(
            height: 390,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15.0),
                topRight: const Radius.circular(15.0),
              ),
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 0.0, 24.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Options",
                          style: GoogleFonts.firaSans(
                            color: Colors.black,
                            fontSize: 32.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    getButtonOrTextField(
                      Icons.clear,
                      "Clear Selection",
                      _onClearScreenButtonPressed,
                    ),
                    getButtonOrTextField(
                      Icons.image,
                      "Load from Storage",
                      _onImagePickerButtonPressed,
                    ),
                    getButtonOrTextField(
                      Icons.share,
                      "Share",
                      _onShareSelectionButtonPressed,
                    ),
                    getButtonOrTextField(
                      Icons.history,
                      "History",
                      _onOpenHistoryButtonPressed,
                    ),
                    getButtonOrTextField(
                      Icons.network_cell,
                      "Change IP",
                      null,
                      textField: true,
                      onTextChanged: _onIPTextChanged,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
      );
    else {
      if (_bottomSheetVisible) {
        Navigator.pop(context);
        _bottomSheetVisible = false;
      }
    }
  }

  //! Build Function...

  @override
  Widget build(BuildContext context) {
    return !CameraUtil.instance.isInitialized
        ? Container()
        : Scaffold(
            key: scaffoldKey,
            body: Column(
              children: <Widget>[
                GestureDetector(
                  onLongPressStart: (LongPressStartDetails details) =>
                      !_extracted ? _onTapTakePicture() : _sendPictureToPS(),
                  onVerticalDragUpdate: _toggleBottomSheet,
                  child: AspectRatio(
                    aspectRatio: CameraUtil.instance.aspectRatio,
                    child: Stack(
                      children: <Widget>[
                        CameraUtil.instance.cameraPreview,
                        _loading
                            ? getCustomProgressIndicator()
                            : getImageOrText(_path?.imagePath, _rotation),
                      ],
                    ),
                  ),
                ),
                getHomePageFooterText(),
              ],
            ),
          );
  }
}
