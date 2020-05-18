import 'package:flutter/material.dart';

import 'camera_screen.dart';
import 'history_screen.dart';
import 'model/path.dart';
import 'util/camera_util.dart';
import 'util/hive_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CameraUtil.instance.init();
  await HiveUtil.instance.init(PathAdapter());

  runApp(HomePage());
}

class HomePage extends StatefulWidget{
  static const String routeName = '/';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, WidgetBuilder> routes = {
    HistoryScreen.routeName: (context) => HistoryScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iris',
      routes: routes,
      home: FutureBuilder(
        future: HiveUtil.instance.openBox(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? CameraScreen()
              : Scaffold(
                  body: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  ),
                );
        },
      ),
    );
  }

  @override
  void dispose() {
    HiveUtil.instance.close();
    super.dispose();
  }
}