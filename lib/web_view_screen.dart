import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled1/manaba_data.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'main_page.dart';

WebViewController? mainController;

class WebViewScreen extends StatefulWidget {

  GlobalKey<State<MainPage>> mainPageKey;

  WebViewScreen({Key? key, required this.mainPageKey}) : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {

  final Completer<WebViewController> webController = Completer<WebViewController>();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final dataSink = ManageDataStream.getReportQueryDetailStreamSink();
  int loadingCourseNumber = 0;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      WebView.platform = AndroidWebView();
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
      onWebViewCreated: webController.complete,
      // ページの読み込み開始
      onPageStarted: (String url) {},
      // ページ読み込み終了
      onPageFinished: (String url) async {

        // ページタイトル取得
        final controller = await webController.future;
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

        //サインイン成功時、ホーム表示時
        if(url == 'https://ct.ritsumei.ac.jp/ct/home_course') {
          ManabaData.courseList.clear();
          ManabaData.queryData.clear();
          ManabaData.reportData.clear();
          loadingCourseNumber = 0;
          _mainPageKey.currentState?.setState(() {});
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.stdlist').innerHTML;");
          if (html != 'null') {
            debugPrint(html);
            final List<String> trList = html.split(r'\u003Ctr');
            final List<String> periodList = trList.sublist(2);
            //List<String> courseTexts = <String>[];
            for(String period in periodList){
              // period.split(r'course-cell\">').sublist(1).forEach((text) {
              //   courseTexts.add(text.split(r'\u003C/td>')[0]);
              // });
              period.split(r'\u003Ctd class=\"course').sublist(1).forEach((text) {
                if(text.contains('course-cell')){
                  var courseInfo = text.split(r'locationinfoV2')[1].split(r'=\"')[1].split(r'\"')[0];
                  Map<String, String> courseCell = {
                    'ID' : text.split(r'href=\"course_')[1].split(r'\">')[0],
                    'title' : text.split(r'href=\"course_')[1].split(r'\">')[1].split(r'\u003C/a>')[0],
                    'isHomework' : text.contains('未提出の課題') ? 'true' : 'false',
                    'dayOfWeek' : courseInfo[0],
                    'period' : courseInfo[1],
                    'place' : courseInfo.split(r':')[1].split(r'\"')[0],
                  };
                  debugPrint(courseCell['ID']);
                  debugPrint(courseCell['title']);
                  debugPrint(courseCell['isHomework']);
                  debugPrint(courseCell['dayOfWeek']);
                  debugPrint(courseCell['period']);
                  debugPrint(courseCell['place']);
                  ManabaData.courseList.add(courseCell);
                }
              });
            }
            // for (var text in courseTexts) {
            //   courseList.add({
            //     'ID' : text.split(r'href=\"course_')[1].split(r'\">')[0],
            //     'title' : text.split(r'href=\"course_')[1].split(r'\">')[1].split(r'\u003C/a>')[0],
            //     'isHomework' : text.contains('未提出の課題') ? 'true' : 'false',
            //   });
            // }
            for(var course in ManabaData.courseList){
              print(course);
            }

            if(ManabaData.courseList.isNotEmpty) {
                await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + ManabaData.courseList[0]['ID']! + '_query');
            }
          }

        }

        //小テストページ時
        if(url.contains('query') && !url.contains('query_')){
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.stdlist').innerHTML;");
          if(html != 'null'){
            print('html-----' + html);
            final a = html.split(r'\u003Ctr onmouseover');
            for(int i = 1; i < a.length; i++){
              if(a[i].contains('受付中') && a[i].contains('未提出')){
                print('aiueo');
                final b = a[i].split(r'\u003Ca href=\"')[1].split(r'\">');
                ManabaData.queryData.add({
                  'ID' : b[0].split('query_')[1],
                  'courseID' : ManabaData.courseList[loadingCourseNumber]['ID']!,
                  'title' : b[1].split(r'\u003C')[0],
                  'deadline' : a[i].split(r'center\">')[3].split(r'\u003C')[0],
                });
                debugPrint(ManabaData.queryData[ManabaData.queryData.length - 1]['title']);
                ManageDataStream.getReportQueryStreamSink().add('');
              }
            }
          }
          if(loadingCourseNumber < ManabaData.courseList.length - 1) {
            for(int i = loadingCourseNumber + 1; i < ManabaData.courseList.length; i++){
              if(ManabaData.courseList[i]['isHomework'] == 'true'){
                loadingCourseNumber = i;
                await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + ManabaData.courseList[i]['ID']! + '_query');
                break;
              }
              if(i == ManabaData.courseList.length - 1){
                loadingCourseNumber = 0;
                await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + ManabaData.courseList[loadingCourseNumber]['ID']! + '_report');
              }
            }
          } else {
            loadingCourseNumber = 0;
            await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + ManabaData.courseList[loadingCourseNumber]['ID']! + '_report');
          }
        }

        //レポートページ時
        if(url.contains('report') && !url.contains('report_')){
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.stdlist').innerHTML;");
          if(html != 'null'){
            print(loadingCourseNumber);
            print('html-----' + html);
            final a = html.split(r'\u003Ctr onmouseover');
            for(int i = 1; i < a.length; i++){
              if(a[i].contains('受付中') && a[i].contains('未提出')){
                print('aiueo');
                final b = a[i].split(r'\u003Ca href=\"')[1].split(r'\">');
                ManabaData.reportData.add({
                  'ID' : b[0].split('report_')[1],
                  'courseID' : ManabaData.courseList[loadingCourseNumber]['ID']!,
                  'title' : b[1].split(r'\u003C')[0],
                  'deadline' : a[i].split(r'center\">')[4].split(r'\u003C')[0],
                });
                debugPrint(ManabaData.reportData[ManabaData.reportData.length - 1]['title']);
                ManageDataStream.getReportQueryStreamSink().add('');
              }
            }
          }
          if(loadingCourseNumber < ManabaData.courseList.length - 1) {
            for(int i = loadingCourseNumber + 1; i < ManabaData.courseList.length; i++){
              if(ManabaData.courseList[i]['isHomework'] == 'true'){
                loadingCourseNumber = i;
                await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + ManabaData.courseList[i]['ID']! + '_report');
                break;
              }
            }
          } else if(loadingCourseNumber == ManabaData.courseList.length - 1) {
            for (var query in ManabaData.queryData) {
              print(query['title']);
            }
            for (var report in ManabaData.reportData) {
              print(report['title']);
            }

            ManageDataStream.getReportQueryStreamSink().add('');
            loadingCourseNumber = 0;
          }
        }

        //小テスト詳細ページ
        if(url.contains('query_')){
          final queryID = url.split('query_')[1];
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.contentbody-s').innerHTML;");
          ManabaData.queryData.forEach((query) {
            if(query['ID'] == queryID){
              query['detail'] = html.split(r'word-break\">')[1].split(r'\u003C')[0];
              ManageDataStream.getReportQueryDetailStreamSink().add(query['detail']);
            }
          });
        }

        //レポート詳細ページ
        if (url.contains('report_')){
          final queryID = url.split('report_')[1];
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.contentbody-l').innerHTML;");
          final detail = html.split(r'left\">')[1].split(r'\u003C/td')[0];
          ManabaData.reportData.forEach((report) {
            if(report['ID'] == queryID){
              report['detail'] = detail;
              ManageDataStream.getReportQueryDetailStreamSink().add(report['detail']);
            }
          });
          dataSink.add(detail);
        }

        //コース詳細ページ
        if (url.contains('course_') && !url.contains('report') && !url.contains('query')) {
          final courseID = url.split('course_')[1];
          debugPrint(courseID);
          ManabaData.courseNewsList.removeWhere((map) {if(map['courseID'] == courseID) {
            debugPrint("RemoveCourseNews");
            return true;
          } else{return false;}});
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.info-list-card-body').innerHTML;");
          if (html != 'null') {
            final tbody = html.split('tbody')[1];
            final courseNewsList = tbody.split(r'\u003Ctr>').sublist(1);
            for (var courseNews in courseNewsList) {
              final _info = courseNews.split(courseID + '_news_')[1];
              final _newsID = _info.split(r'\"')[0];
              final _title = _info.split(r'\">')[1].split(r'\u003C/a>')[0];
              final _courseNewsInfo = {
                'ID' : _newsID,
                'courseID' : courseID,
                'title' : _title,
                'date' : _info.split(r'news-date\">')[1].split(r'\u003C/td>')[0],
                'isRead' : courseNews.contains('unread') ? 'false' : 'true',
              };
              debugPrint(_courseNewsInfo['ID']);
              debugPrint(_courseNewsInfo['courseID']);
              debugPrint(_courseNewsInfo['title']);
              debugPrint(_courseNewsInfo['date']);
              debugPrint(_courseNewsInfo['isRead']);
              ManabaData.courseNewsList.add(_courseNewsInfo);
              ManageDataStream.getCourseStreamSink().add(courseID);
            }
          }
        }

        //コースニュース詳細ページ
        if (url.contains('news_')) {
          final courseNewsID = url.split('news_')[1];
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.msg-text').innerHTML;");
          for(var courseNews in ManabaData.courseNewsList) {
            if(courseNews['ID'] == courseNewsID) {
              courseNews['detail'] = html;
              ManageDataStream.getCourseNewsDetailStreamSink().add(courseNewsID);
              break;
            }
          }
        }

        //コースニュースリストページ
        if (url.contains('home_coursenews_')) {
          print(1);
          ManabaData.courseNewsList.clear();
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.groupthreadlist').innerHTML;");
          if (html != 'null') {
            print(2);
            final newsList = html.split(r'\u003Ctr>').sublist(1);
            for (var news in newsList) {
              print(3);
              final info = news.split(r'href=\"course_')[1];
              ManabaData.courseNewsList.add(
                {
                  'ID' : info.split('news_')[1].split(r'\"')[0],
                  'courseID' : info.split('_news')[0],
                  'title' : info.split(r'title=\"')[1].split(r'\"')[0],
                  'date' : news.split('width=')[1].split(r'\">')[1].split(r'\u003C')[0],
                  'isRead' : news.contains('unread') ? 'false' : 'true',
                  'courseInfo' : news.split('news-courseinfo')[1].split(r'title=\"')[1].split(r'\"')[0],
                }
              );
              ManageDataStream.getCourseNewsListStreamSink().add('');
            }
          }
        }
      },
    );
  }

}

class ManageDataStream {
  static StreamController onReportQueryDataChange = StreamController<String>();
  static StreamController onReportQueryDetailDataChange = StreamController<String>();
  static StreamController onCourseDataChange = StreamController<String>();
  static StreamController onCourseNewsListChange = StreamController<String>();
  static StreamController onCourseNewsDetailDataChange = StreamController<String>();

  static Stream getReportQueryStream(){
    onReportQueryDataChange = StreamController<String>();
    return onReportQueryDataChange.stream;
  }

  static StreamSink getReportQueryStreamSink(){
    return onReportQueryDataChange.sink;
  }

  static Stream getReportQueryDetailStream(){
    onReportQueryDetailDataChange = StreamController<String>();
    return onReportQueryDetailDataChange.stream;
  }

  static StreamSink getReportQueryDetailStreamSink(){
    return onReportQueryDetailDataChange.sink;
  }

  static Stream getCourseStream(){
    onCourseDataChange = StreamController<String>();
    return onCourseDataChange.stream;
  }

  static StreamSink getCourseStreamSink(){
    return onCourseDataChange.sink;
  }

  static Stream getCourseNewsDetailStream(){
    onCourseNewsDetailDataChange = StreamController<String>();
    return onCourseNewsDetailDataChange.stream;
  }

  static StreamSink getCourseNewsDetailStreamSink(){
    return onCourseNewsDetailDataChange.sink;
  }

  static Stream getCourseNewsListStream(){
    onCourseNewsListChange = StreamController<String>();
    return onCourseNewsListChange.stream;
  }

  static StreamSink getCourseNewsListStreamSink(){
    return onCourseNewsListChange.sink;
  }
}

