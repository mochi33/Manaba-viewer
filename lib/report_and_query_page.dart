import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/WebViewInfo.dart';
import 'package:untitled1/manaba_data.dart';
import 'package:untitled1/query_detail_page.dart';
import 'package:untitled1/report_detail_page.dart';
import 'package:untitled1/web_view_screen.dart';
import 'config_page.dart';

class ReportAndQueryPage extends StatefulWidget {
  ReportAndQueryPage({Key? key}) : super(key: key);

  @override
  State<ReportAndQueryPage> createState() => _ReportAndQueryPageState();
}

class _ReportAndQueryPageState extends State<ReportAndQueryPage> {

  double _rotateUpdateIcon = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('レポート＆小テスト'),
          actions: [
            IconButton(
              onPressed: () async {
                mainController!.loadUrl('https://ct.ritsumei.ac.jp/ct/home_course');
                setState(() {});
              },
              icon: StreamBuilder(
                stream: ManageDataStream.getWebViewPageStateStream(),
                builder: (context, snapshot) {
                  if (AppInfo.isLoading) {
                    Timer.periodic(const Duration(milliseconds: 50), (timer) {_rotateUpdateIcon += 1; setState(() {});});
                    return Transform.rotate(
                      angle: _rotateUpdateIcon * pi / 180,
                      child: const Icon(Icons.update),
                    );
                  }
                  return const Icon(Icons.update);
                },
              ),
            )
          ],
        ),
        endDrawer: const SizedBox(
          width: double.infinity,
          child: Drawer(
            child: ConfigPage(),
          ),
        ),
        body: StreamBuilder(
          stream: ManageDataStream.getReportQueryStream(),
          builder: (context, snapshot) {
            return Column(
              children: [
                const ListTile(
                  title: Text('小テスト'),
                ),
                Expanded(
                  child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: ManabaData.queryData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5.0),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => QueryDetailPage(queryData: ManabaData.queryData[index]),));
                                  },
                                  child: Text(ManabaData.queryData[index]['title']!),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(ManabaData.queryData[index]['deadline']!),
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
                    itemCount: ManabaData.reportData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ReportDetailPage(reportData: ManabaData.reportData[index]),));
                              },
                              child: Text(ManabaData.reportData[index]['title']!),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(ManabaData.reportData[index]['deadline']!),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],

            );
          }
        ),
      ),
    );
  }
}

