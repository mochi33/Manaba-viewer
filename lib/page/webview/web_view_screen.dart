import 'dart:async';
import 'dart:core';
//import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled1/StreamManager.dart';
import 'package:untitled1/WebViewInfo.dart';
import 'package:untitled1/device_info.dart';
import 'package:untitled1/html_function.dart';
import 'package:untitled1/manaba_data.dart';
import 'package:untitled1/page/manage.dart';
import 'package:untitled1/page/webview/web_view_screen2.dart';
import 'package:untitled1/test_data.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:untitled1/page/main_page.dart';

WebViewController? mainController;
String? currentUrl;
bool isSigned = true;

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
  bool isLoginPage = false;
  int loadingCourseNumber = 0;
  int loginCount = 0;

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
        StreamManager.addDataToStreamSink("webViewPageState", "true");
      },
      // ページ読み込み終了
      onPageFinished: (String url) async {
        // ページタイトル取得
        final controller = await webController.future;
        mainController = controller;
        String? title = await controller.getTitle();
        currentUrl = url;
        AppInfo.isLoading = false;
        StreamManager.addDataToStreamSink("webViewPageState", "false");

        if(AppInfo.isUserChanged) {
          _cookieManager.clearCookies();
          mainController?.loadUrl('https://ct.ritsumei.ac.jp/ct/home_course');
          AppInfo.isUserChanged = false;
          return;
        }

        //サインインページ表示時
        if(title?.contains('Web Single Sign On') == true) {
          if (loginCount > 2) {
            loginCount = 0;
            return;
          }
          loginCount++;
          AppInfo.pageType = PageType.signIn;
          String userID = await storage.read(key: 'ID') ?? '';
          String passWord = await storage.read(key: 'PASSWORD') ?? '';
          if (userID == "test" && passWord == "test") {
            ManabaData.isTestMode = true;
            ManabaData.isSigned = true;
            ManabaData.queryData = TestData.queryData;
            ManabaData.reportData = TestData.reportData;
            ManabaData.courseList = TestData.courseList;
            StreamManager.addDataToStreamSink("reportQuery", "");
            StreamManager.addDataToStreamSink("courseList", "");
            print("test");
            return;
          } else {
            ManabaData.isTestMode = false;
            ManabaData.isSigned = false;
          }
          StreamManager.addDataToStreamSink("loginState", "");
          isLoginPage = true;
          await controller.runJavascript('document.getElementsByName("USER")[0].value="' + userID + '";');
          await controller.runJavascript('document.getElementsByName("PASSWORD")[0].value="' + passWord + '";');
          await controller.runJavascript('document.getElementById("Submit").click();');
        } else {
          loginCount = 0;
          ManabaData.isSigned = true;
          StreamManager.addDataToStreamSink("loginState", "");
          if (isLoginPage) {
            print("yatta");
            await mainController2?.loadUrl('https://ct.ritsumei.ac.jp/ct/home_course');
            isLoginPage = false;
          }
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
                  StreamManager.addDataToStreamSink("courseList", "");
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
                  'courseID' : ManabaData.courseList[loadingCourseNumber]['ID'] ?? '',
                  'courseTitle' : ManabaData.courseList[loadingCourseNumber]['title'] ?? '',
                  'title' : b[1].split(r'\u003C')[0],
                  'deadline' : a[i].split(r'center\">')[3].split(r'\u003C')[0],
                  'isRead' : a[i].contains('unread') ? 'false' : 'true',
                });
                debugPrint(ManabaData.queryData[ManabaData.queryData.length - 1]['title']);
                StreamManager.addDataToStreamSink("reportQuery", "");
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
                  'courseID' : ManabaData.courseList[loadingCourseNumber]['ID'] ?? "",
                  'courseTitle' : ManabaData.courseList[loadingCourseNumber]['title'] ?? '',
                  'title' : b[1].split(r'\u003C')[0],
                  'deadline' : a[i].split(r'center\">')[4].split(r'\u003C')[0],
                  'isRead' : a[i].contains('unread') ? 'false' : 'true',
                });
                debugPrint(ManabaData.reportData[ManabaData.reportData.length - 1]['title']);
                StreamManager.addDataToStreamSink("reportQuery", "");
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

            StreamManager.addDataToStreamSink("reportQuery", "");
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
              StreamManager.addDataToStreamSink("reportQueryDetail", query["detail"] ?? "");
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
              StreamManager.addDataToStreamSink("reportQueryDetail", report["detail"] ?? "");
            }
          });
        }

        //コース詳細ページ
        if (url.contains('course_') && !url.contains('report') && !url.contains('query') && !url.contains('news')) {
          AppInfo.pageType = PageType.courseDetail;
          final courseID = url.split('course_')[1];
          debugPrint(courseID);
          //コースニュース取得
          ManabaData.courseNewsList.removeWhere((map) {if(map['courseID'] == courseID) {
            debugPrint("RemoveCourseNews");
            return true;
          } else{return false;}});
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.info-list-card-body').innerHTML;");
          if (html != 'null') {
            final tbody = HtmlFunction.parseString(html, 'tbody', null);
            if (tbody != null) {
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
                StreamManager.addDataToStreamSink("course", "");
              }
            }
          }
          //コンテンツ取得
          final contentHtml = await controller.runJavascriptReturningResult("window.document.querySelector('.top-contents-list-body').innerHTML;");
          if (contentHtml != 'null') {
            ManabaData.contentsList.removeWhere((e) => e['courseID'] == courseID);
            final contentsList = contentHtml.split(r'contents-card\"').sublist(1);
            for (final content in contentsList) {
              final info = content.split(r'href=\"page_')[1];
              final info2 = info.split(r'\">');
              final _contentInfo = {
                'ID' : info2[0].split('c')[0],
                'courseID' : courseID,
                'title' : info2[1].split(r'\u003C/')[0],
                'date' : info.split(r'span>')[1].split(r'\u003C/')[0],
              };
              print('contentInfo' + _contentInfo.toString());
              ManabaData.contentsList.add(_contentInfo);
              StreamManager.addDataToStreamSink("course2", _contentInfo["ID"] ?? "");
            }
          }
        }

        //コースニュース詳細ページ
        if (url.contains('news_') && !url.contains('coursenews')) {
          AppInfo.pageType = PageType.courseNewsDetail;
          final courseNewsID = url.split('news_')[1];
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.msg-text').innerHTML;");
          for(var courseNews in ManabaData.courseNewsList) {
            if(courseNews['ID'] == courseNewsID) {
              courseNews['detail'] = html;
              StreamManager.addDataToStreamSink("courseNewsDetail", courseNewsID);
              break;
            }
          }
        }

        //コース詳細ニュースリストページ
        if (url.endsWith('_news') && url.contains('course_')) {
          final courseID = HtmlFunction.parseString(url, 'course_', '_news');
          ManabaData.courseNewsList.removeWhere((map) {
            if(map['courseID'] == courseID) {
              return true;
            } else {
              return false;
            }
          });
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.stdlist').innerHTML;");
          print('aaa' + html);
          final alist = html.split(r'=\"newstext');
          if (alist.length > 1) {
            final courseNewsList = alist.sublist(1);
            for (final courseNews in courseNewsList) {
              final href = HtmlFunction.parseString(courseNews, r'href=\"', r'\u003C/a');
              final _courseNewsInfo = {
                'ID' : HtmlFunction.parseString(href, 'news_', r'\"') ?? '',
                'courseID' : courseID ?? '',
                'title' : HtmlFunction.parseString(href, r'\">', null) ?? '',
                'date' : HtmlFunction.parseString(courseNews, r'center\">\n', r"\n") ?? '',
                'isRead' : HtmlFunction.parseString(courseNews, null, r'\"')?.contains('unread') == true ? 'false' : 'true',
              };
              ManabaData.courseNewsList.add(_courseNewsInfo);
              StreamManager.addDataToStreamSink("course", _courseNewsInfo['ID'] ?? "");
            }
          }

        }

        //コースニュースリストページ
        if (url.contains('home_coursenews_')) {
          AppInfo.pageType = PageType.courseNewsList;
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.groupthreadlist').innerHTML;");
          if (html != 'null') {
            ManabaData.courseNewsList.clear();
            final newsList = html.split(r'\u003Ctr>').sublist(1);
            for (var news in newsList) {
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
              StreamManager.addDataToStreamSink("courseNewsList", "");
            }
          }
        }

        //コンテンツ詳細ページ
        if (url.contains('page_')){
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.contentbody-left').innerHTML;");
          final contentTitle = await controller.runJavascriptReturningResult("window.document.querySelector('.contentsheader h1.contests').innerHTML;");
          final pageTitle = await controller.runJavascriptReturningResult("window.document.querySelector('.pagetitle').innerHTML;");
          final updateDate = await controller.runJavascriptReturningResult("window.document.querySelector('.contents-modtime').innerHTML;");
          final articleText = await controller.runJavascriptReturningResult("window.document.querySelector('.articletext').innerHTML;");
          final articleFile = await controller.runJavascriptReturningResult("window.document.querySelector('.articletext .inlineaf-description').innerHTML;");
          final contentsListString = await controller.runJavascriptReturningResult("window.document.querySelector('.contentslist').innerHTML;");
          print(articleText);
          if (contentsListString != 'null') {
            final contentsList = contentsListString.split('GRI').sublist(1);
            final Id = url.split('page_')[1].split('c')[0];
            bool isTopPage = url.split('page_')[1].contains('_');
            bool isFirstContent = true;
            Map<String, String> thisContent = {};
            for (final content in ManabaData.contentsList) {
              if (content['ID'] == Id) {
                thisContent = content;
                content["length"] = contentsList.length.toString();
                isFirstContent = false;
              }
            }
            if (isFirstContent) {
              thisContent = {
                'ID' : Id,
                'courseID' : url.split('page_')[1].split('c')[1].split('_')[0],
                'title' : contentTitle.split(r'\">')[1].split(r'\u003C')[0],
                'length' : contentsList.length.toString(),
              };
              ManabaData.contentsList.add(thisContent);
            }
            for (final contentDetail in contentsList) {
              final contentState = HtmlFunction.parseString(contentDetail, null, r'\"') ?? '';
              String contentDetailId = '';
              String contentInfo = HtmlFunction.parseString(contentDetail, r'href=\"', r'\u003C/a') ?? '';
              final infoList = contentInfo.split('_');
              final isCurrent = contentState.contains('current');
              print('isCurrent' + isCurrent.toString());
              contentDetailId = (infoList.length > 2) ? infoList[2].split(r'\"')[0] : '';
              ManabaData.contentsDetailList.removeWhere((element) => element['ID'] == contentDetailId);
              final contentDetailData = {
                'ID' : contentDetailId,
                'contentID' : Id,
                'isRead' : contentState.startsWith(r'read') ? 'true' : 'false',
                'title' : HtmlFunction.parseString(contentInfo, r'\">', null) ?? '',
                'body' : isCurrent ? articleText : '',//(HtmlFunction.parseString(articleText, r'p>', r'\u003C/') ?? '') : '',
                'updateDate' : updateDate,
                //'file' : articleFile,
              };
              print(contentDetailData);
              ManabaData.contentsDetailList.add(contentDetailData);
              if (!url.split('page_')[1].split('c')[1].contains('_')) {
                if (isCurrent) {
                  thisContent['topPage'] = contentDetailId;
                }
              }
            }
            StreamManager.addDataToStreamSink("contentDetail", Id);
          }
        }
        
        //その他ニュースリストページ
        if (url.contains('announcement_list') || url.contains('announcement_publist')) {
          bool isAnnouncementList = false;
          if (url.contains('announcement_list')) {
            isAnnouncementList = true;
          }
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.my-infolist-body').innerHTML;");
          if (html != 'null') {
            if (isAnnouncementList) {
              ManabaData.otherNewsList.clear();
            }
            final info1 = HtmlFunction.parseString(html, r'\u003Ctbody>', r'\u003C/tbody>');
            final newsList = info1?.split(r'\u003Ctr>') ?? [];
            if (newsList.length > 1) {
              for (final news in newsList) {
                final infoList = news.split(r'\u003Ctd');
                if (infoList.length > 3) {
                  for(final a in infoList) {
                    print('a' + a);
                  }
                  final date = HtmlFunction.parseString(infoList[1], r'\">', r'\u003C/td')?.replaceAll(r'\n', '') ?? '';
                  final id = HtmlFunction.parseString(infoList[2], r'announcement_detail_', r'\"') ?? '';
                  final info2 = HtmlFunction.parseString(infoList[2], r'href=', r'\u003C/a') ?? '';
                  final title = HtmlFunction.parseString(info2, r'title=\"', r'\">') ?? '';
                  final isRead = !infoList[2].contains('unread');
                  final writer = HtmlFunction.parseString(infoList[3], r'>', r'\u003C/')?.replaceAll(r'\n', '') ?? '';
                  final newsData = {
                    'ID' : id,
                    'title' : title,
                    'date' : date,
                    'writer' : writer,
                    'isRead' : isRead ? 'true' : 'false',
                  };
                  print(newsData);
                  ManabaData.otherNewsList.add(newsData);
                  StreamManager.addDataToStreamSink("otherNewsList", "");
                }
              }
            }
            if (isAnnouncementList) {
              mainController?.loadUrl('https://ct.ritsumei.ac.jp/ct/home_announcement_publist');
            }
          }

        }

        //その他ニュース詳細ページ
        if (url.contains('announcement_detail_')) {
          debugPrint("fdsafa");
          final newsID = url.split('_detail_')[1];
          final html = await controller.runJavascriptReturningResult("window.document.querySelector('.msg-text').innerHTML;");
          if (html != 'null') {
            for (final news in ManabaData.otherNewsList) {
              if (news['ID'] == newsID){
                news['detail'] = html;
              }
            }
            StreamManager.addDataToStreamSink("otherNewsDetail", newsID);
          }
        }

      },
    );
  }

}




