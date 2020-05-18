import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'model/path.dart';
import 'util/hive_util.dart';

//* Common Widgets

TextStyle _getTextStyle() {
  return GoogleFonts.firaSans(
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}

Widget getCustomProgressIndicator() {
  return Center(
    child: Lottie.asset('assets/anim/scan.json'),
  );
}

Widget getFAB(String text, Function onPressed) {
  return FloatingActionButton.extended(
    backgroundColor: Colors.greenAccent,
    onPressed: onPressed,
    label: Text(
      text,
      style: GoogleFonts.firaSans(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
    icon: Icon(Icons.delete_outline),
  );
}

Widget getButtonOrTextField(
  IconData icons,
  String text,
  Function onButtonPressed, {
  bool textField = false,
  Function onTextChanged,
}) {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: SizedBox(
      width: double.infinity,
      height: 50,
      child: RaisedButton(
        onPressed: onButtonPressed,
        color: Colors.greenAccent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: !textField
              ? <Widget>[
                  Text(text, style: _getTextStyle()),
                  Icon(icons, color: Colors.white),
                ]
              : <Widget>[
                  Flexible(
                    child: TextField(
                      style: _getTextStyle(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        fillColor: Colors.transparent,
                        hintText: text,
                        hintStyle: _getTextStyle(),
                      ),
                      onSubmitted: onTextChanged,
                    ),
                  ),
                  Icon(icons, color: Colors.white),
                ],
        ),
      ),
    ),
  );
}

Widget getImageOrText(String imagePath, int rotation) {
  if (imagePath != null) {
    return getImageWidget(imagePath, rotation);
  } else
    return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
          child: Text(
            "Press Screen",
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              decoration: TextDecoration.none,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32.0,
            ),
          ),
        ));
}

Widget getImageWidget(String imagePath, int rotation) {
  return Center(
    child: RotatedBox(
      quarterTurns: rotation,
      child: Image.file(
        File(imagePath),
        scale: 2.0,
        filterQuality: FilterQuality.high,
      ),
    ),
  );
}

Widget getHomePageFooterText() {
  return Column(
    children: <Widget>[
      Padding(padding: const EdgeInsets.all(4.0)),
      Text(
        "Iris.",
        textAlign: TextAlign.center,
        style: GoogleFonts.openSans(
          color: Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 42.0,
        ),
      ),
      Padding(padding: const EdgeInsets.all(2.0)),
      Text(
        "Cut & Paste",
        textAlign: TextAlign.center,
        style: GoogleFonts.playfairDisplay(
          color: Colors.black87,
          fontSize: 22.0,
        ),
      )
    ],
  );
}

Widget getHistoryGridView(int count, Function onItemClicked) {
  return GridView(
    shrinkWrap: true,
    physics: BouncingScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    children: List<Widget>.generate(count, (index) {
      Path path = HiveUtil.instance.getItem(index) as Path;
      TapDownDetails details;

      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          color: Color.fromARGB(220, 255, 255, 255),
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          ),
          child: InkWell(
            onTapDown: (TapDownDetails d) => details = d,
            onLongPress: () => onItemClicked(path, details),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
            child: Image.file(
              File(path.imagePath),
              scale: 2.0,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      );
    }),
  );
}