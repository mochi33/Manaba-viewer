import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/page/course_news_detail_page.dart';
import 'package:untitled1/device_info.dart';
import 'package:untitled1/manaba_data.dart';
import 'package:untitled1/page/manage.dart';
import 'package:untitled1/page/query_detail_page.dart';
import 'package:untitled1/page/report_detail_page.dart';
import 'package:untitled1/page/rotating_update_button.dart';
import 'package:untitled1/page/webview/web_view_screen.dart';

import 'content_detail_page.dart';

class CourseDetailPage extends StatefulWidget {

  Map<String, String> courseData;
  CourseDetailPage({Key? key, required this.courseData}) : super(key: key);

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {

  List<Map<String, String>> courseReportList = [];
  List<Map<String, String>> courseQueryList = [];
  List<Map<String, String>> courseContentsList = [];

  void _getData(String courseID) async {
    await mainController?.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + courseID);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> _courseData = widget.courseData;
    if (_courseData['ID'] != null) {
      _getData(_courseData['ID']!);
    }
    List<Map<String, String>> _courseNewsList = [];
    for (var courseNews in ManabaData.courseNewsList) {
      if (courseNews['courseID'] == _courseData['ID']) {
        _courseNewsList.add(courseNews);
      }
    }

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("コース詳細"),
            actions: [
              IconButton(
                onPressed: () async {
                  _getData(_courseData['ID']!);
                  setState(() {});
                },
                icon: const RotatingUpdateButton(),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10.0,),
                  Center(
                    child: Text(_courseData['title'] ?? '', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(height: 10.0,),
                  const Divider(color: Colors.black87),
                  const SizedBox(height: 20.0,),
                  SizedBox(
                    width: DeviceInfo.deviceWidth * 0.7,
                    child: StreamBuilder(
                      stream: ManageDataStream.getCourseStream(),
                      builder: (context, snapshot) {
                        _courseNewsList.clear();
                        for (var courseNews in ManabaData.courseNewsList) {
                          if (courseNews['courseID'] == _courseData['ID']) {
                            _courseNewsList.add(courseNews);
                          }
                        }
                        return Column(
                          children: [
                            const Center(
                              child: Text("コースニュース"),
                            ),
                            const SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: (_courseNewsList.isEmpty) ? 40 : 0,),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _courseNewsList.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Container(
                                        padding: const EdgeInsets.only(left: 5),
                                        alignment: Alignment.topLeft,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => CourseNewsDetailPage(courseNewsData: _courseNewsList[index])),);
                                              },
                                              child: Text(_courseNewsList[index]['title'] ?? '', style: TextStyle(color: (_courseNewsList[index]['isRead'] == 'true') ? Colors.blueAccent : Colors.orange),),
                                            ),
                                            Text(_courseNewsList[index]['date'] ?? ''),
                                            SizedBox(height: (index == _courseNewsList.length - 1) ? 20.0 : 5.0),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0,),
                  SizedBox(
                    width: DeviceInfo.deviceWidth * 0.7,
                    child: StreamBuilder(
                      stream: ManageDataStream.getReportQueryStream(),
                        builder: (context, snapshot) {
                          courseReportList.clear();
                          for(var report in ManabaData.reportData) {
                            if(report['courseID'] == _courseData['ID']) {
                              courseReportList.add(report);
                            }
                          }
                          courseQueryList.clear();
                          for(var query in ManabaData.queryData) {
                            if(query['courseID'] == _courseData['ID']) {
                              courseQueryList.add(query);
                            }
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                  child: Text('レポート')
                              ),
                              const SizedBox(height: 10,),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                                alignment: Alignment.topLeft,
                                child: Column(
                                  children: [
                                    SizedBox(height: (courseReportList.isEmpty) ? 40 : 0,),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: courseReportList.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Container(
                                          alignment: Alignment.topLeft,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ReportDetailPage(reportData: courseReportList[index])),);
                                                },
                                                child: Text(courseReportList[index]['title'] ?? ''),
                                              ),
                                              Text('締切: ' + (courseReportList[index]['deadline'] ?? '')),
                                              SizedBox(height: (index == courseReportList.length - 1) ? 20.0 : 5.0),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20.0,),
                              const Center(
                                child: Text('小テスト'),
                              ),
                              const SizedBox(height: 10,),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                                alignment: Alignment.topLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: (courseQueryList.isEmpty) ? 40 : 0,),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: courseQueryList.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Container(
                                          alignment: Alignment.topLeft,
                                          child: Column(
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => QueryDetailPage(queryData: courseQueryList[index])),);
                                                },
                                                child: Text(courseQueryList[index]['title'] ?? ''),
                                              ),
                                              Text('締切: ' + (courseQueryList[index]['deadline'] ?? '')),
                                              SizedBox(height: (index == courseQueryList.length - 1) ? 20.0 : 5.0),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                    ),
                  ),
                  const SizedBox(height: 20,),
                  SizedBox(
                    width: DeviceInfo.deviceWidth * 0.7,
                    child: StreamBuilder(
                      stream: ManageDataStream.getCourse2Stream(),
                      builder: (context, snapshot) {
                        courseContentsList.clear();
                        for (final content in ManabaData.contentsList) {
                          if (content['courseID'] == _courseData['ID']) {
                            courseContentsList.add(content);
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                                child: Text('コンテンツ')
                            ),
                            const SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2),),
                              alignment: Alignment.topLeft,
                              child: Column(
                                children: [
                                  SizedBox(height: (courseContentsList.isEmpty) ? 40 : 0,),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: courseContentsList.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          alignment: Alignment.topLeft,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ContentDetailPage(contentData: courseContentsList[index], isTopPage: true,)),);
                                                },
                                                child: Text(courseContentsList[index]['title'] ?? ''),
                                              ),
                                              Text(courseContentsList[index]['date'] ?? ''),
                                              SizedBox(height: (index == courseContentsList.length - 1) ? 20.0 : 5.0),
                                            ],
                                          ),
                                        );;
                                      }
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40,),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
