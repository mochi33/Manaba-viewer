
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:untitled1/manaba_data.dart';
import 'package:untitled1/web_view_screen.dart';
import 'package:untitled1/web_view_screen2.dart';

import 'html_function.dart';

class CourseNewsDetailPage extends StatefulWidget {

  Map<String, String> courseNewsData;
  CourseNewsDetailPage({Key? key, required this.courseNewsData}) : super(key: key);

  @override
  State<CourseNewsDetailPage> createState() => _CourseNewsDetailPageState();
}

class _CourseNewsDetailPageState extends State<CourseNewsDetailPage> {

  bool isFirstGet = false;

  void getData(String? courseID,String? courseNewsID) {
    if(courseID == null || courseNewsID == null) {
      return;
    }
    mainController?.loadUrl("https://ct.ritsumei.ac.jp/ct/course_" + courseID + "_news_" +courseNewsID);
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("コースニュース詳細"),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30.0,),
                Text(widget.courseNewsData['title'] ?? ''),
                const SizedBox(height: 10.0,),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: StreamBuilder(
                    stream: ManageDataStream.getCourseNewsDetailStream(),
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if(!isFirstGet) {
                        getData(widget.courseNewsData['courseID'], widget.courseNewsData['ID']);
                        isFirstGet = true;
                      }
                      Map<String, String> _courseNewsData = widget.courseNewsData;
                      if(snapshot.data != null && snapshot.data == _courseNewsData['ID']) {
                        _courseNewsData = ManabaData.courseNewsList.firstWhere((News) => News['ID'] == _courseNewsData['ID']);
                      }
                      debugPrint(_courseNewsData['detail'] ?? '');
                      return Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Html(
                              data: HtmlFunction.parseHTML(_courseNewsData['detail'] ?? ''),
                              onLinkTap: (link, a, b, c) {
                                print(b);
                                print(link);
                                print(HtmlFunction.urlAsciiDecoder(link?.split('url=')[1] ?? ''));
                                Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewScreen2(url: HtmlFunction.urlAsciiDecoder(link?.split('url=')[1] ?? ''))));
                              },
                            ),
                            const SizedBox(height: 30.0),
                            Text(_courseNewsData['date'] ?? ''),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }
}
