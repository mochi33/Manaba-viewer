import 'dart:async';
import 'dart:core';
import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled1/WebViewInfo.dart';
import 'package:untitled1/device_info.dart';
import 'package:untitled1/html_function.dart';
import 'package:untitled1/manaba_data.dart';
import 'package:untitled1/page/manage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:untitled1/page/main_page.dart';

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
  final _cookieManager = CookieManager();
  bool _isNextLoad = false;
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

    return WebView(
      initialUrl: 'https://ct.ritsumei.ac.jp/ct/home_course',
      // jsを有効化
      javascriptMode: JavascriptMode.unrestricted,
      // controllerを登録
      onWebViewCreated: webController.complete,
      // ページの読み込み開始
      onPageStarted: (String url) {
        AppInfo.isLoading = true;
        _isNextLoad = false;
        ManageDataStream.getWebViewPageStateStreamSink().add('true');
      },
      // ページ読み込み終了
      onPageFinished: (String url) async {

        // ページタイトル取得
        final controller = await webController.future;
        mainController = controller;
        String? title = await controller.getTitle();

        if(AppInfo.isUserChanged) {
          _cookieManager.clearCookies();
          mainController?.loadUrl('https://ct.ritsumei.ac.jp/ct/home_course');
          AppInfo.isUserChanged = false;
        }

        //サインインページ表示時
        if(title?.contains('Web Single Sign On') == true) {
          AppInfo.pageType = PageType.signIn;
          String userID = await storage.read(key: 'ID') ?? '';
          String passWord = await storage.read(key: 'PASSWORD') ?? '';
          await controller.runJavascript('document.getElementsByName("USER")[0].value="' + userID + '";');
          await controller.runJavascript('document.getElementsByName("PASSWORD")[0].value="' + passWord + '";');
          _isNextLoad = true;
          await controller.runJavascript('document.getElementById("Submit").click();');
        }

        //サインイン成功時、ホーム表示時
        if(url == 'https://ct.ritsumei.ac.jp/ct/home_course') {
          AppInfo.pageType = PageType.home;
          ManabaData.courseList.clear();
          ManabaData.queryData.clear();
          ManabaData.reportData.clear();
          loadingCourseNumber = 0;
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
                  ManageDataStream.getCourseListStreamSink().add(courseCell['ID']);
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
              _isNextLoad = true;
              await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + ManabaData.courseList[0]['ID']! + '_query');
            }
          }

        }

        //小テストページ時
        if(url.contains('query') && !url.contains('query_')){
          AppInfo.pageType = PageType.queryList;
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.stdlist').innerHTML;");
          if(html != 'null'){
            print('html-----' + html);
            final a = html.split(r'\u003Ctr onmouseover');
            for(int i = 1; i < a.length; i++){
              if(a[i].contains('受付中') && a[i].contains('未提出')){
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
                _isNextLoad = true;
                await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + ManabaData.courseList[i]['ID']! + '_query');
                break;
              }
              if(i == ManabaData.courseList.length - 1){
                loadingCourseNumber = 0;
                _isNextLoad = true;
                await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + ManabaData.courseList[loadingCourseNumber]['ID']! + '_report');
              }
            }
          } else {
            loadingCourseNumber = 0;
            _isNextLoad = true;
            await controller.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + ManabaData.courseList[loadingCourseNumber]['ID']! + '_report');
          }
        }

        //レポートページ時
        if(url.contains('report') && !url.contains('report_')){
          AppInfo.pageType = PageType.reportList;
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
                _isNextLoad = true;
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
            debugPrint('statefalse');
          }
        }

        //小テスト詳細ページ
        if(url.contains('query_')){
          AppInfo.pageType = PageType.queryDetail;
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
          AppInfo.pageType = PageType.reportDetail;
          final queryID = url.split('report_')[1];
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.contentbody-l').innerHTML;");
          final detail = html.split(r'left\">')[1].split(r'\u003C/td')[0];
          ManabaData.reportData.forEach((report) {
            if(report['ID'] == queryID){
              report['detail'] = detail;
              ManageDataStream.getReportQueryDetailStreamSink().add(report['detail']);
            }
          });
        }

        //コース詳細ページ
        if (url.contains('course_') && !url.contains('report') && !url.contains('query') && !url.contains('news')) {
          AppInfo.pageType = PageType.courseDetail;
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
          final contentHtml = await controller.runJavascriptReturningResult("window.document.querySelector('.top-contents-list-body').innerHTML;");
          if (contentHtml != 'null') {
            final contentsList = contentHtml.split(r'contents-card\"').sublist(1);
            for (final content in contentsList) {
              final info = content.split(r'href=\"page_')[1];
              final info2 = info.split(r'\">');
              final _contentInfo = {
                'ID' : info2[0],
                'courseID' : courseID,
                'title' : info2[1].split(r'\u003C/')[0],
                'date' : info.split(r'span>')[1].split(r'\u003C/')[0],
              };
              ManabaData.contentsList.add(_contentInfo);
              ManageDataStream.getCourse2StreamSink().add(_contentInfo['ID']);
            }
          }
        }

        //コースニュース詳細ページ
        if (url.contains('news_')) {
          AppInfo.pageType = PageType.courseNewsDetail;
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
          AppInfo.pageType = PageType.courseNewsList;
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
                  'date' : news.split('width=')[1].split(r'\">')[1].split(r'\u003C')[0].replaceAll(r'\n', '').trimLeft(),
                  'isRead' : news.contains('unread') ? 'false' : 'true',
                  'courseInfo' : news.split('news-courseinfo')[1].split(r'title=\"')[1].split(r'\"')[0],
                }
              );
              ManageDataStream.getCourseNewsListStreamSink().add('');
            }
          }
        }

        //コンテンツ詳細ページ
        if (url.contains('page_')){
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.contentbody-left').innerHTML;");
          final contentTitle = await controller.runJavascriptReturningResult("window.document.querySelector('.contentsheader h1.contests').innerHTML;");
          final pageTitle = await controller.runJavascriptReturningResult("window.document.querySelector('.pagetitle').innerHTML;");
          final articleText = await controller.runJavascriptReturningResult("window.document.querySelector('.articletext').innerHTML;");
          final contentsListString = await controller.runJavascriptReturningResult("window.document.querySelector('.contentslist').innerHTML;");
          if (html != 'null') {

          }
          if (contentsListString != 'null') {
            final contentsList = contentsListString.split('GRI').sublist(1);
            final Id = url.split('page_')[1].split('c')[0];
            bool isFirstContent = true;
            for (final content in ManabaData.contentsList) {
              if (content['ID'] == Id) {
                isFirstContent = false;
              }
            }
            if (isFirstContent) {
              ManabaData.contentsList.add({
                'ID' : Id,
                'courseID' : url.split('page_')[1].split('c')[1].split('_')[0],
                'title' : contentTitle.split(r'\">')[1].split(r'\<')[0],
                'length' : contentsList.length.toString(),
              });
            }
            for (final contentDetail in contentsList) {
              String contentDetailId = '';
              bool isTopPage;
              if (url.split('page_')[1].contains('_')) {
                contentDetailId = url.split('page_')[1].split('_')[1];
              } else {
                contentDetailId = HtmlFunction.parseString(contentDetail, r'\"page_', r'c') ?? '';

              }
              contentDetail.startsWith(r'unread');
              ManabaData.contentsDetailList.add({
                'ID' : contentDetailId,
                'ContentID' : ,
                'is'
              });
            }
          }
        }

        if (!_isNextLoad) {
          AppInfo.isLoading = false;
          ManageDataStream.getWebViewPageStateStreamSink().add('false');
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
  static StreamController onCourseListChange = StreamController<String>();
  static StreamController onWebViewPageStateChage = StreamController<Stream>();
  static StreamController onCourseData2Change = StreamController<Stream>();
  static StreamController onContentDetailDataChange = StreamController<Stream>();

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

  static Stream getCourseListStream(){
    onCourseListChange = StreamController<String>();
    return onCourseListChange.stream;
  }

  static StreamSink getCourseListStreamSink(){
    return onCourseListChange.sink;
  }

  static Stream getWebViewPageStateStream(){
    onWebViewPageStateChage = StreamController<String>();
    return onWebViewPageStateChage.stream;
  }

  static StreamSink getWebViewPageStateStreamSink(){
    return onWebViewPageStateChage.sink;
  }

  static Stream getCourse2Stream(){
    onCourseData2Change = StreamController<String>();
    return onCourseData2Change.stream;
  }

  static StreamSink getCourse2StreamSink(){
    return onCourseData2Change.sink;
  }

  static Stream getContentDetailStream(){
    onContentDetailDataChange = StreamController<String>();
    return onContentDetailDataChange.stream;
  }

  static StreamSink getContentDetailStreamSink(){
    return onContentDetailDataChange.sink;
  }
}

