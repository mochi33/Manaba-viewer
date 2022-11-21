import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/main.dart';
import 'package:untitled1/page/report_and_query_page.dart';
import 'package:untitled1/page/webview/web_view_screen.dart';

import 'main_page.dart';

class Manage extends StatefulWidget {
  const Manage({Key? key}) : super(key: key);

  @override
  _ManageState createState() => _ManageState();
}

class _ManageState extends State<Manage> {

  final GlobalKey<State<WebViewScreen>> webViewScreenKey = GlobalKey<State<WebViewScreen>>();
  final GlobalKey<State<MainPage>> mainPageKey = GlobalKey<State<MainPage>>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewScreen(key: webViewScreenKey, mainPageKey: mainPageKey,),
        Container(color: Colors.blueAccent,),
        MainPage(key: mainPageKey),
      ],
    );
  }
}
