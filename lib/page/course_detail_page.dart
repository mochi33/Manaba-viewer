import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/StreamManager.dart';
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
  bool isAddCourseNewsList = false;

  void _getData(String courseID) async {
    await mainController?.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + courseID);
  }

  void _getCourseNewsData(String courseID) async {
    await mainController?.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + courseID + '_news');
  }

  @override
  void initState() {
    super.initState();
    if (widget.courseData['ID'] != null) {
      _getData(widget.courseData['ID']!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> _courseData = widget.courseData;
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
                    child: Text(_courseData['title'] ?? '', style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(height: 10.0,),
                  const Divider(color: Colors.black87),
                  const SizedBox(height: 20.0,),
                  SizedBox(
                    width: DeviceInfo.deviceWidth * 0.7,
                    child: StreamBuilder(
                      stream: StreamManager.getStream("course"),
                      builder: (context, snapshot) {
                        _courseNewsList.clear();
                        for (var courseNews in ManabaData.courseNewsList) {
                          if (courseNews['courseID'] == _courseData['ID']) {
                            _courseNewsList.add(courseNews);
                          }
                        }
                        return Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      if (ManabaData.isCourseNewsListOpened) {
                                        ManabaData.isCourseNewsListOpened = false;
                                      } else {
                                        ManabaData.isCourseNewsListOpened = true;
                                      }
                                      setState(() {});
                                      },
                                    icon: Icon((ManabaData.isCourseNewsListOpened) ? Icons.arrow_drop_down_outlined : Icons.arrow_drop_up_outlined)),
                                const Text("コースニュース" , style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: (ManabaData.isCourseNewsListOpened) ? Column(
                                children: [
                                  SizedBox(height: (_courseNewsList.isEmpty) ? 40 : 0,),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
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
                                              child: Text(
                                                _courseNewsList[index]['title'] ?? '',
                                                style: TextStyle(color: (_courseNewsList[index]['isRead'] == 'true') ? Colors.blueAccent : Colors.orange),
                                              ),
                                            ),
                                            Text(_courseNewsList[index]['date'] ?? ''),
                                            SizedBox(height: (index == _courseNewsList.length - 1) ? 20.0 : 5.0),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  (_courseNewsList.length > 4 && !isAddCourseNewsList) ?
                                      Container(
                                        child: TextButton(
                                          onPressed: () {
                                            _getCourseNewsData(_courseData['ID'] ?? '');
                                            isAddCourseNewsList = true;

                                          },
                                          child: const Text('さらに表示'),
                                        ),
                                        alignment: Alignment.centerRight,
                                      ): Container(),
                                ],
                              ) : Container(),
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
                      stream: StreamManager.getStream("reportQuery"),
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
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        if (ManabaData.isReportListOpened) {
                                          ManabaData.isReportListOpened = false;
                                        } else {
                                          ManabaData.isReportListOpened = true;
                                        }
                                        setState(() {});
                                      },
                                      icon: Icon((ManabaData.isReportListOpened) ? Icons.arrow_drop_down_outlined : Icons.arrow_drop_up_outlined)),
                                  const Text("未提出のレポート" , style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                                alignment: Alignment.topLeft,
                                child: (ManabaData.isReportListOpened) ? Column(
                                  children: [
                                    SizedBox(height: (courseReportList.isEmpty) ? 40 : 0,),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
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
                                                child: Text(
                                                  courseReportList[index]['title'] ?? '',
                                                  style: TextStyle(color: (courseReportList[index]['isRead'] == 'true') ? Colors.blueAccent : Colors.orange),
                                                ),
                                              ),
                                              Text('締切: ' + (courseReportList[index]['deadline'] ?? '')),
                                              SizedBox(height: (index == courseReportList.length - 1) ? 20.0 : 5.0),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ) : Container(),
                              ),
                              const SizedBox(height: 20.0,),
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        if (ManabaData.isQueryListOpened) {
                                          ManabaData.isQueryListOpened = false;
                                        } else {
                                          ManabaData.isQueryListOpened = true;
                                        }
                                        setState(() {});
                                      },
                                      icon: Icon((ManabaData.isQueryListOpened) ? Icons.arrow_drop_down_outlined : Icons.arrow_drop_up_outlined)),
                                  const Text("未提出の小テスト" , style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                                alignment: Alignment.topLeft,
                                child: (ManabaData.isQueryListOpened) ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: (courseQueryList.isEmpty) ? 40 : 0,),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
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
                                                child: Text(
                                                  courseQueryList[index]['title'] ?? '',
                                                  style: TextStyle(color: (courseQueryList[index]['isRead'] == 'true') ? Colors.blueAccent : Colors.orange),
                                                ),
                                              ),
                                              Text('締切: ' + (courseQueryList[index]['deadline'] ?? '')),
                                              SizedBox(height: (index == courseQueryList.length - 1) ? 20.0 : 5.0),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ) : Container(),
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
                      stream: StreamManager.getStream("course2"),
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
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      if (ManabaData.isContentsListOpened) {
                                        ManabaData.isContentsListOpened = false;
                                      } else {
                                        ManabaData.isContentsListOpened = true;
                                      }
                                      setState(() {});
                                    },
                                    icon: Icon((ManabaData.isContentsListOpened) ? Icons.arrow_drop_down_outlined : Icons.arrow_drop_up_outlined)),
                                const Text("未提出のコンテンツ" , style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2),),
                              alignment: Alignment.topLeft,
                              child: (ManabaData.isContentsListOpened) ? Column(
                                children: [
                                  SizedBox(height: (courseContentsList.isEmpty) ? 40 : 0,),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
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
                              ) : Container(),
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
