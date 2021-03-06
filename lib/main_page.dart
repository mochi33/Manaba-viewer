import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/query_detail_page.dart';
import 'package:untitled1/report_detail_page.dart';
import 'package:untitled1/web_view_screen.dart';

import 'config_page.dart';

class MainPage extends StatefulWidget {
  GlobalKey<State<WebViewScreen>> webViewScreenKey;
  MainPage({Key? key, required this.webViewScreenKey}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final _webViewScreenKey = widget.webViewScreenKey;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('レポート＆小テスト'),
          actions: [
            IconButton(
                onPressed: () async {
                  mainController!.loadUrl('https://ct.ritsumei.ac.jp/ct/home_course');
                },
                icon: const Icon(Icons.update),
            )
          ],
        ),
        endDrawer: const SizedBox(
          width: double.infinity,
          child: Drawer(
            child: ConfigPage(),
          ),
        ),
        body: Column(
          children: [
            const ListTile(
              title: Text('小テスト'),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: queryData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          child: TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => QueryDetailPage(queryData: queryData[index]),));
                              },
                              child: Text(queryData[index]['title']!),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(queryData[index]['deadline']!),
                        ),
                      ],
                    );
                  },
              ),
            ),
            const ListTile(
              title: Text('レポート'),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: reportData.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ReportDetailPage(reportData: reportData[index]),));
                          },
                          child: Text(reportData[index]['title']!),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(reportData[index]['deadline']!),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],

        ),
      ),
    );
  }

}
