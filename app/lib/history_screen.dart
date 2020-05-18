import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'model/path.dart';
import 'util/hive_util.dart';
import 'util/misc.dart';
import 'widgets.dart';

class HistoryScreen extends StatefulWidget {
  static const String routeName = '/history';

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _size = HiveUtil.instance.size;
  bool _bottomSheet = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  void _onClearHistoryButtonPressed() async {
    HiveUtil.instance.size > 0
        ? await HiveUtil.instance.clear().then((_) => setState(() => _size = 0))
        : Utility.showToast(
            msg: 'Nothing to Clear in History.',
            bgColor: Colors.redAccent,
          );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: Container(
        child: GestureDetector(
          onVerticalDragUpdate: (DragUpdateDetails details) {
            if (_bottomSheet && details.delta.direction > 0) {
              Navigator.pop(scaffoldKey.currentContext);
              _bottomSheet = false;
            }
          },
          child: Scaffold(
            backgroundColor: Color.fromARGB(240, 255, 255, 255),
            key: scaffoldKey,
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 50.0, width: 1.0),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 0, 0, 0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "History",
                        textAlign: TextAlign.left,
                        style: GoogleFonts.firaSans(
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          fontSize: 40.0,
                        ),
                      ),
                    ),
                  ),
                  getHistoryGridView(_size, _onItemClicked),
                ],
              ),
            ),
            floatingActionButton: getFAB("Clear", _onClearHistoryButtonPressed),
          ),
        ),
      ),
    );
  }

  void _onShareButtonPressed(Path path) {
    path != null || path.imagePath != null
        ? Utility.getBytesFromFile(File(path.imagePath)).then((bytes) {
            Share.file("Share via:", path.imagePath.split('/').last,
                bytes.buffer.asUint8List(), 'image/png');
          })
        : Utility.showToast(
            msg: 'File doesn\'t exist in device.',
            bgColor: Colors.redAccent,
          );
  }

  void _onItemClicked(Path path, TapDownDetails details) {
    scaffoldKey.currentState.showBottomSheet((context) {
      _bottomSheet = true;

      return Container(
        height: 250,
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
                  Icons.share,
                  "Share Item",
                  () => _onShareButtonPressed(path),
                ),
                getButtonOrTextField(
                  Icons.add_photo_alternate,
                  "Send to Photoshop",
                  () {
                    //TODO: Implement this method.
                  },  
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
