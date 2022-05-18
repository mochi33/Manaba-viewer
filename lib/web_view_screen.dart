import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  final storage = FlutterSecureStorage();

  bool _isLoading = false;
  String _title = '';

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        if (_isLoading) const LinearProgressIndicator(),
        Expanded(
          child: _buildWebView(),
        ),
      ],
    );
  }

  Widget _buildWebView() {
    return WebView(
      initialUrl: 'https://ct.ritsumei.ac.jp/ct/home',
      // jsを有効化
      javascriptMode: JavascriptMode.unrestricted,


      // controllerを登録
      onWebViewCreated: _controller.complete,
      // ページの読み込み開始
      onPageStarted: (String url) {
        // ローディング開始
        setState(() {
          _isLoading = true;
        });
      },
      // ページ読み込み終了
      onPageFinished: (String url) async {
        // ローディング終了
        setState(() {
          _isLoading = false;
        });
        // ページタイトル取得
        final controller = await _controller.future;
        final title = await controller.getTitle();
        if(title?.contains('Web Single Sign On') == true) {
          String userID = await storage.read(key: 'ID') ?? '';
          String passWord = await storage.read(key: 'PASSWORD') ?? '';
          await controller.runJavascript('document.getElementsByName("USER")[0].value="' + userID + '";');
          await controller.runJavascript('document.getElementsByName("PASSWORD")[0].value="' + passWord + '";');
          await controller.runJavascript('document.getElementById("Submit").click();');
        }
        setState(() {
          if (title != null) {
            _title = title;
          }
        });
      },
    );
  }
}