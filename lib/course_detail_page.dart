import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/course_news_detail_page.dart';
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40.0,),
                Container(
                  child: Text(_courseData['title'] ?? ''),
                ),
                const SizedBox(height: 20.0,),
                Container(
                  child: const Text("Course News"),
                ),
                const SizedBox(height: 10.0,),
                StreamBuilder(
                  stream: ManageDataStream.getCourseStream(),
                  builder: (context, snapshot) {
                    _courseNewsList.clear();
                    for (var courseNews in ManabaData.courseNewsList) {
                      if (courseNews['courseID'] == _courseData['ID']) {
                        _courseNewsList.add(courseNews);
                      }
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: _courseNewsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          alignment: Alignment.topLeft,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CourseNewsDetailPage(courseNewsData: _courseNewsList[index])),);
                            },
                            child: Text(_courseNewsList[index]['title'] ?? ''),
                          ),
                        );
                      },
                    );
                  },
                ),
                StreamBuilder(
                  stream: ManageDataStream.getReportQueryStream(),
                    builder: (context, snapshot) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: const Text('レポート'),
                          ),
                          const SizedBox(height: 10,),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: ManabaData.reportData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                alignment: Alignment.topLeft,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReportDetailPage(reportData: ManabaData.reportData[index])),);
                                  },
                                  child: Text(ManabaData.reportData[index]['title'] ?? ''),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20.0,),
                          Container(
                            child: const Text('小テスト'),
                          ),
                          const SizedBox(height: 10,),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: ManabaData.queryData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                alignment: Alignment.topLeft,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => QueryDetailPage(queryData: ManabaData.queryData[index])),);
                                  },
                                  child: Text(ManabaData.queryData[index]['title'] ?? ''),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                ),
              ],
            ),
          ),
        ),
    );
  }
}
