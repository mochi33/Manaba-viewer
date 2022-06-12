import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'main_page.dart';

List<String> courseList = <String>[];
List<String> queryData = <String>[];
List<String> reportData = <String>[];

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  final storage = const FlutterSecureStorage();
  final GlobalKey<State<MainPage>> _key = GlobalKey<State<MainPage>>();

  bool _isLoading = false;
  int courseNumber = 0;

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
      body: Stack(
        children: [
          _buildBody(),
          MainPage(key: _key,),
        ],
      ),
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
      initialUrl: 'https://ct.ritsumei.ac.jp/ct/home_course',
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
        String? title = await controller.getTitle();
        //サインインページ表示時
        if(title?.contains('Web Single Sign On') == true) {
          String userID = await storage.read(key: 'ID') ?? '';
          String passWord = await storage.read(key: 'PASSWORD') ?? '';
          await controller.runJavascript('document.getElementsByName("USER")[0].value="' + userID + '";');
          await controller.runJavascript('document.getElementsByName("PASSWORD")[0].value="' + passWord + '";');
          await controller.runJavascript('document.getElementById("Submit").click();');
        }
        final url = await controller.currentUrl();
        //サインイン成功時
        if(url == 'https://ct.ritsumei.ac.jp/ct/home_course') {
          courseList = <String>[];
          queryData = <String>[];
          reportData = <String>[];
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.stdlist').innerHTML;");
          print(html);
          final List<String> trList = html.split(r'\u003Ctr');
          final List<String> periodList = trList.sublist(2);
          print(periodList);
          for(int i = 0; i < 5; i++){
            final a = periodList[i].split("'event':event,'href':'").sublist(1);
            courseList.addAll(a);
          }
          print("courseList-------" + courseList[11]);
          if(courseList.isNotEmpty) {
              await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/' + courseList[0].substring(0, 14) + '_query');
          }
        }
        //小テストページ時
        if(url?.contains('query') == true){
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.stdlist').innerHTML;");
          if(html != null){
            print('html-----' + html);
            final a = html.split(r'\u003Ctr onmouseover');
            for(int i = 1; i < a.length; i++){
              if(a[i].contains('deadline')){
                print('aiueo');
                queryData.add(a[i].split(r'\u003Ca')[1]);
                print(a[i].split(r'\u003Ca')[1]);
                _key.currentState!.setState(() {});
              }
            }
          }
          if(courseNumber < courseList.length) {
            await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/' + courseList[courseNumber++].substring(0, 14) + '_query');
          } else if(courseNumber == courseList.length){
            courseNumber = 0;
            await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/' + courseList[courseNumber++].substring(0, 14) + '_report');
          }
        }
        //レポートページ時
        if(url?.contains('report') == true){
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.stdlist').innerHTML;");
          if(html != null){
            print('html-----' + html);
            final a = html.split(r'\u003Ctr onmouseover');
            for(int i = 1; i < a.length; i++){
              if(a[i].contains('deadline')){
                print('aiueo');
                reportData.add(a[i].split(r'\u003Ca')[1]);
                print(a[i].split(r'\u003Ca')[1]);
              }
            }
          }
          if(courseNumber < courseList.length) {
            await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/' + courseList[courseNumber++].substring(0, 14) + '_report');
          } else if(courseNumber == courseList.length) {
            for (var query in queryData) {
              print(query.substring(0, 60));
            }
            for (var report in reportData) {
              print(report.substring(0, 60));
            }
            _key.currentState!.setState(() {});
            courseNumber = 0;
            //Navigator.push(context, MaterialPageRoute(builder: (context) => const MainPage()));
          }
        }
        setState(() {

        });
      },
    );
  }
}