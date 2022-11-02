import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/course_news_detail_page.dart';
import 'package:untitled1/device_info.dart';
import 'package:untitled1/manaba_data.dart';
import 'package:untitled1/query_detail_page.dart';
import 'package:untitled1/report_detail_page.dart';
import 'package:untitled1/web_view_screen.dart';

class CourseDetailPage extends StatefulWidget {

  Map<String, String> courseData;
  CourseDetailPage({Key? key, required this.courseData}) : super(key: key);

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {

  List<Map<String, String>> _courseReportList = [];
  List<Map<String, String>> _courseQueryList = [];

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
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10.0,),
                Center(
                  child: Text(_courseData['title'] ?? '', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: 20.0,),
                const SizedBox(height: 10.0,),
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
                                            child: Text(_courseNewsList[index]['title'] ?? ''),
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
                        _courseReportList.clear();
                        for(var report in ManabaData.reportData) {
                          if(report['courseID'] == _courseData['ID']) {
                            _courseReportList.add(report);
                          }
                        }
                        _courseQueryList.clear();
                        for(var query in ManabaData.queryData) {
                          if(query['courseID'] == _courseData['ID']) {
                            _courseQueryList.add(query);
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
                                  SizedBox(height: (_courseReportList.isEmpty) ? 40 : 0,),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _courseReportList.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Container(
                                        alignment: Alignment.topLeft,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => ReportDetailPage(reportData: _courseReportList[index])),);
                                              },
                                              child: Text(_courseReportList[index]['title'] ?? ''),
                                            ),
                                            Text(_courseReportList[index]['deadline'] ?? ''),
                                            SizedBox(height: (index == _courseNewsList.length - 1) ? 20.0 : 5.0),
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
                                  SizedBox(height: (_courseQueryList.isEmpty) ? 40 : 0,),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _courseQueryList.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Container(
                                        alignment: Alignment.topLeft,
                                        child: Column(
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => QueryDetailPage(queryData: _courseQueryList[index])),);
                                              },
                                              child: Text(_courseQueryList[index]['title'] ?? ''),
                                            ),
                                            Text(_courseQueryList[index]['deadline'] ?? ''),
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
              ],
            ),
          ),
        ),
    );
  }
}
