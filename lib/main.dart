import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled1/device_info.dart';
import 'package:untitled1/page/manage.dart';
import 'package:untitled1/page/webview/web_view_screen.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Permission.storage.request();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'manaba viewer',
      home: Manage(),
    );
  }
}


