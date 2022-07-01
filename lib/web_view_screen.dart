import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'main_page.dart';

List<Map<String, String>> courseList = <Map<String, String>>[];
List<Map<String, String>> queryData = <Map<String, String>>[];
List<Map<String, String>> reportData = <Map<String, String>>[];
WebViewController? mainController;

class WebViewScreen extends StatefulWidget {

  GlobalKey<State<MainPage>> mainPageKey;
  WebViewScreen({Key? key, required this.mainPageKey}) : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  FlutterSecureStorage storage = const FlutterSecureStorage();
  int loadingCourseNumber = 0;

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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: _buildWebView(),
        ),
      ],
    );
  }

  Widget _buildWebView() {
    final _mainPageKey = widget.mainPageKey;

    return WebView(
      initialUrl: 'https://ct.ritsumei.ac.jp/ct/home_course',
      // jsを有効化
      javascriptMode: JavascriptMode.unrestricted,
      // controllerを登録
      onWebViewCreated: _controller.complete,
      // ページの読み込み開始
      onPageStarted: (String url) {},
      // ページ読み込み終了
      onPageFinished: (String url) async {

        // ページタイトル取得
        final controller = await _controller.future;
        mainController = controller;
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
          courseList.clear();
          queryData.clear();
          reportData.clear();
          loadingCourseNumber = 0;
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.stdlist').innerHTML;");
          print("html---" + html);
          if (html != 'null') {
            final List<String> trList = html.split(r'\u003Ctr');
            final List<String> periodList = trList.sublist(2);
            List<String> courseTexts = <String>[];
            for(String period in periodList){
              period.split(r'course-cell\">').sublist(1).forEach((text) {
                courseTexts.add(text.split(r'\u003C/td>')[0]);
              });
            }
            for (var text in courseTexts) {
              courseList.add({
                'ID' : text.split(r'href=\"course_')[1].split(r'\">')[0],
                'title' : text.split(r'href=\"course_')[1].split(r'\">')[1].split(r'\u003C/a>')[0],
                'isHomework' : text.contains('未提出の課題') ? 'true' : 'false',
              });
            }
            for(Map course in courseList){
              print('b' + course['title']);
            }
            if(courseList.isNotEmpty) {
                await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + courseList[0]['ID']! + '_query');
            }
          }

        }

        //小テストページ時
        if(url?.contains('query') == true){
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.stdlist').innerHTML;");
          if(html != 'null'){
            print('html-----' + html);
            final a = html.split(r'\u003Ctr onmouseover');
            for(int i = 1; i < a.length; i++){
              if(a[i].contains('受付中') && a[i].contains('未提出')){
                print('aiueo');
                final b = a[i].split(r'\u003Ca href=\"')[1].split(r'\">');
                queryData.add({
                  'ID' : b[0],
                  'courseID' : courseList[loadingCourseNumber]['ID']!,
                  'title' : b[1].split(r'\u003C')[0],
                  'deadline' : a[i].split(r'center\">')[3].split(r'\u003C')[0],
                });
                debugPrint(queryData[queryData.length - 1]['title']);
                _mainPageKey.currentState!.setState(() {});
              }
            }
          }
          if(loadingCourseNumber < courseList.length - 1) {
            for(int i = loadingCourseNumber + 1; i < courseList.length; i++){
              if(courseList[i]['isHomework'] == 'true'){
                loadingCourseNumber = i;
                await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + courseList[i]['ID']! + '_query');
                break;
              }
              if(i == courseList.length - 1){
                loadingCourseNumber = 0;
                await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + courseList[loadingCourseNumber]['ID']! + '_report');
              }
            }
          } else {
            loadingCourseNumber = 0;
            await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + courseList[loadingCourseNumber]['ID']! + '_report');
          }
        }

        //レポートページ時
        if(url?.contains('report') == true){
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.stdlist').innerHTML;");
          if(html != 'null'){
            print(loadingCourseNumber);
            print('html-----' + html);
            final a = html.split(r'\u003Ctr onmouseover');
            for(int i = 1; i < a.length; i++){
              if(a[i].contains('受付中') && a[i].contains('未提出')){
                print('aiueo');
                final b = a[i].split(r'\u003Ca href=\"')[1].split(r'\">');
                reportData.add({
                  'ID' : b[0],
                  'courseID' : courseList[loadingCourseNumber]['ID']!,
                  'title' : b[1].split(r'\u003C')[0],
                  'deadline' : a[i].split(r'center\">')[4].split(r'\u003C')[0],
                });
                debugPrint(reportData[reportData.length - 1]['title']);
                _mainPageKey.currentState!.setState(() {});
              }
            }
          }
          if(loadingCourseNumber < courseList.length - 1) {
            for(int i = loadingCourseNumber + 1; i < courseList.length; i++){
              if(courseList[i]['isHomework'] == 'true'){
                loadingCourseNumber = i;
                await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + courseList[i]['ID']! + '_report');
                break;
              }
            }
          } else if(loadingCourseNumber == courseList.length - 1) {
            for (var query in queryData) {
              print(query['title']);
            }
            for (var report in reportData) {
              print(report['title']);
            }

            _mainPageKey.currentState!.setState(() {});
            loadingCourseNumber = 0;
          }
        }
      },
    );
  }

  Future<void> updateData() async {
    final controller = await _controller.future;
    await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/home_course');
    debugPrint('update');
  }
}