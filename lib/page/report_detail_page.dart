import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/StreamManager.dart';
import 'package:untitled1/page/webview/web_view_screen.dart';

class ReportDetailPage extends StatefulWidget {

  Map reportData;

  ReportDetailPage({Key? key, required this.reportData}) : super(key: key);

  @override
  _ReportDetailPageState createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {

  @override
  Widget build(BuildContext context) {
    mainController!.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + widget.reportData['courseID'] + '_report_' + widget.reportData['ID']!);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('レポート詳細'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: Text(widget.reportData['title']!),
              ),
              (widget.reportData['detail'] == null) ? StreamBuilder(
                stream: StreamManager.getStream("reportQueryDetail"),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    debugPrint('stream!!');
                    return ListTile(
                      title: Text(snapshot.data as String),
                    );
                  } else {
                    return Container();
                  }
                },
              ) : ListTile(
                title: Text(widget.reportData['detail']),
              ),
            ],
          ),
        ),
      ),
    );
  }

}