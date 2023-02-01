import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:untitled1/page/webview/web_view_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../device_info.dart';

class WebViewScreen2 extends StatefulWidget {

  String url;
  WebViewScreen2({Key? key, required this.url}) : super(key: key);

  @override
  _WebViewScreen2State createState() => _WebViewScreen2State();

}

class _WebViewScreen2State extends State<WebViewScreen2> {

  final Completer<WebViewController> _controller = Completer<WebViewController>();
  WebViewController? _webViewController;

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
        actions: [
          IconButton(
            onPressed: () async {
              await _webViewController?.reload();
            },
            icon: Icon(Icons.update, size: DeviceInfo.deviceHeight * 0.04),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _webViewController?.goBack();
        },
        child: const Icon(Icons.subdirectory_arrow_left),
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
      initialUrl: widget.url,
      // jsを有効化
      javascriptMode: JavascriptMode.unrestricted,
      // controllerを登録
      onWebViewCreated: _controller.complete,
      // ページの読み込み開始
      onPageStarted: (String url) async {
        // ローディング開始
        setState(() {
          _isLoading = true;
        });
        if(!url.startsWith('http')) {
          await launchUrl(Uri.parse(url));
        }
      },
      // ページ読み込み終了
      onPageFinished: (String url) async {
        // ローディング終了
        setState(() {
          _isLoading = false;
        });
        // ページタイトル取得
        final controller = await _controller.future;
        _webViewController = controller;
        final title = await controller.getTitle();
        setState(() {
          if (title != null) {
            _title = title;
          }
        });
      },
    );
  }
}