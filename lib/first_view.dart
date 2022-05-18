import 'package:flutter/material.dart';
import 'package:untitled1/config_page.dart';
import 'package:untitled1/web_view_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FirstView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('立命館manaba'),
        ),
        endDrawer: SizedBox(
          width: double.infinity,
          child: Drawer(
            child: configPage(),
          ),
        ),
        body: _FirstView(),
      ),
    );
  }
}

class _FirstView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final _cookieManager = CookieManager();
          _cookieManager.clearCookies();
          Navigator.push(
            context,
            MaterialPageRoute<WebViewScreen>(
              builder: (BuildContext _context) => WebViewScreen(),
            ),
          );
        },
        child: const Text('manabaを開く'),
      ),
    );
  }
}