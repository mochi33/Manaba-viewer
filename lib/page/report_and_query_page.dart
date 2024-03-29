import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:untitled1/StreamManager.dart';
import 'package:untitled1/WebViewInfo.dart';
import 'package:untitled1/device_info.dart';
import 'package:untitled1/manaba_data.dart';
import 'package:untitled1/page/query_detail_page.dart';
import 'package:untitled1/page/report_detail_page.dart';
import 'package:untitled1/page/rotating_update_button.dart';
import 'package:untitled1/page/webview/web_view_screen.dart';
import 'package:untitled1/test_data.dart';
import 'config_page.dart';

class ReportAndQueryPage extends StatefulWidget {
  ReportAndQueryPage({Key? key}) : super(key: key);

  @override
  State<ReportAndQueryPage> createState() => _ReportAndQueryPageState();
}

class _ReportAndQueryPageState extends State<ReportAndQueryPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(DeviceInfo.deviceHeight * 0.07),
        child: AppBar(
          title: const Text('レポート＆小テスト'),
          actions: [
            IconButton(
              onPressed: () async {
                mainController!.loadUrl('https://ct.ritsumei.ac.jp/ct/home_course');
                setState(() {});
              },
              icon: const RotatingUpdateButton(),
            )
          ],
        ),
      ),
      endDrawer: const SizedBox(
        width: double.infinity,
        child: Drawer(
          child: ConfigPage(),
        ),
      ),
      body: StreamBuilder(
        stream: StreamManager.getStream("reportQuery"),
        builder: (context, snapshot) {
          return Column(
            children: [
              const ListTile(
                title: Text('未提出の小テスト'),
              ),
              Expanded(
                child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: ManabaData.queryData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: Colors.black26,),
                            Container(
                              padding: const EdgeInsets.all(5.0),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => QueryDetailPage(queryData: ManabaData.queryData[index]),));
                                },
                                child: Text(
                                  ManabaData.queryData[index]['title']!,
                                  style: TextStyle(
                                      color: (ManabaData.queryData[index]['isRead'] == 'true') ? Colors.blueAccent : Colors.orange,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(ManabaData.queryData[index]['courseTitle'] ?? ""),
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
                title: Text('未提出のレポート'),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ManabaData.reportData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: Colors.black26,),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ReportDetailPage(reportData: ManabaData.reportData[index]),));
                            },
                            child: Text(ManabaData.reportData[index]['title'] ?? ""),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(ManabaData.reportData[index]['courseTitle'] ?? ""),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(ManabaData.reportData[index]['deadline'] ?? ""),
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
    );
  }
}

