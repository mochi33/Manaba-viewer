import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:untitled1/device_info.dart';
import 'package:untitled1/manaba_data.dart';
import 'package:untitled1/page/rotating_update_button.dart';
import 'package:untitled1/page/webview/web_view_screen.dart';

import '../StreamManager.dart';
import 'course_news_detail_page.dart';
import 'other_news_detail_page.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({Key? key}) : super(key: key);

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  
  bool isCourseNewsFirstGet = false;
  bool isOtherNewsFirstGet = false;
  int newsType = 0;
  
  void _getCourseNewsData() {
    mainController?.loadUrl('https://ct.ritsumei.ac.jp/ct/home_coursenews_');
  }

  void _getOtherNewsData() {
    mainController?.loadUrl('https://ct.ritsumei.ac.jp/ct/home_announcement_list');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(DeviceInfo.deviceHeight * 0.07),
        child: AppBar(
          title: const Text('お知らせ'),
          actions: [
            IconButton(
              onPressed: () async {
                if (newsType == 0) {
                  _getCourseNewsData();
                } else {
                  _getOtherNewsData();
                }
              },
              icon: const RotatingUpdateButton(),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0,),
            Row(
              children: [
                TextButton(
                    onPressed: () {
                      if (newsType != 0) {
                        newsType = 0;
                        setState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5.0),
                      decoration: (newsType == 0) ? BoxDecoration(
                        border: Border.all(color: Colors.pink),
                        borderRadius: BorderRadius.circular(7.0),
                      ) : null,
                      child: const Text('コースニュース'),
                    ),
                ),
                TextButton(
                  onPressed: () {
                    if (newsType != 1) {
                      newsType = 1;
                      setState(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: (newsType == 1) ? BoxDecoration(
                      border: Border.all(color: Colors.pink),
                      borderRadius: BorderRadius.circular(7.0),
                    ) : null,
                    child: const Text('その他のニュース'),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10.0,),
            isSigned ? ((newsType == 0) ? StreamBuilder(
              stream: StreamManager.getStream("courseNewsList"),
              builder: (context, snapshot) {
                if (!isCourseNewsFirstGet) {
                  _getCourseNewsData();
                  isCourseNewsFirstGet = true;
                }
                final newsList = ManabaData.courseNewsList.sort((a, b) => (b['date'] ?? "0000-00-00").compareTo(a['date'] ?? "0000-00-00"));
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: ManabaData.courseNewsList.length,
                  itemBuilder: (context, index) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: Colors.black26,),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => CourseNewsDetailPage(courseNewsData: ManabaData.courseNewsList[index])),);
                              },
                              child: Text(
                                ManabaData.courseNewsList[index]['title'] ?? '',
                                style: TextStyle(color: (ManabaData.courseNewsList[index]['isRead'] == 'true') ? Colors.blueAccent : Colors.orange),
                              ),
                            ),
                            Text(ManabaData.courseNewsList[index]['courseInfo'] ?? ''),
                            const SizedBox(height: 3,),
                            Text(ManabaData.courseNewsList[index]['date'] ?? '')
                          ],
                        ),
                      );
                      },
                );
              }
            ) : StreamBuilder(
                stream: StreamManager.getStream("otherNewsList"),
                builder: (context, snapshot) {
                  if (!isOtherNewsFirstGet) {
                    _getOtherNewsData();
                    isOtherNewsFirstGet = true;
                  }
                  final newsList = ManabaData.otherNewsList.sort((a, b) => (b['date'] ?? "0000-00-00").compareTo(a['date'] ?? "0000-00-00"));
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: ManabaData.otherNewsList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: Colors.black26,),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => OtherNewsDetailPage(otherNewsData: ManabaData.otherNewsList[index])),);
                              },
                              child: Text(
                                ManabaData.otherNewsList[index]['title'] ?? '',
                                style: TextStyle(color: (ManabaData.otherNewsList[index]['isRead'] == 'true') ? Colors.blueAccent : Colors.orange),
                              ),
                            ),
                            Text(ManabaData.otherNewsList[index]['writer'] ?? ''),
                            const SizedBox(height: 3,),
                            Text(ManabaData.otherNewsList[index]['date'] ?? '')
                          ],
                        ),
                      );
                    },
                  );
                })) : Container(),
          ],
        ),
      ),
    );
  }
}
