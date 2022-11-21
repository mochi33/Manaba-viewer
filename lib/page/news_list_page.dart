import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/device_info.dart';
import 'package:untitled1/manaba_data.dart';
import 'package:untitled1/page/rotating_update_button.dart';
import 'package:untitled1/page/webview/web_view_screen.dart';

import 'course_news_detail_page.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({Key? key}) : super(key: key);

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  
  bool isFirstGet = false;
  
  void _getData() {
    mainController?.loadUrl('https://ct.ritsumei.ac.jp/ct/home_coursenews_');
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(DeviceInfo.deviceHeight * 0.07),
            child: AppBar(
              title: const Text('お知らせ'),
              actions: [
                IconButton(
                  onPressed: () async {
                    _getData();
                    setState(() {});
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
                const Text('コースニュース'),
                const SizedBox(height: 10.0,),
                StreamBuilder(
                  stream: ManageDataStream.getCourseNewsListStream(),
                  builder: (context, snapshot) {
                    if (!isFirstGet) {
                      _getData();
                      isFirstGet = true;
                    }
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
                                  child: Text(ManabaData.courseNewsList[index]['title'] ?? ''),
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
                ),
              ],
            ),
          ),
        )
    );
  }
}
