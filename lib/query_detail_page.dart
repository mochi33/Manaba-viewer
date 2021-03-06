import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/web_view_screen.dart';

class QueryDetailPage extends StatefulWidget {

  Map queryData;

  QueryDetailPage({Key? key, required this.queryData}) : super(key: key);

  @override
  _QueryDetailPageState createState() => _QueryDetailPageState();
}

class _QueryDetailPageState extends State<QueryDetailPage> {

  @override
  Widget build(BuildContext context) {
    mainController!.loadUrl('https://ct.ritsumei.ac.jp/ct/course_' + widget.queryData['courseID'] + '_query_' + widget.queryData['ID']!);

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('小テスト詳細'),
          ),
          body: Column(
            children: [
              ListTile(
                title: Text(widget.queryData['title']!),
              ),
              (widget.queryData['detail'] == null) ? StreamBuilder(
                stream: ManageDataStream.getStream(),
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
                title: Text(widget.queryData['detail']),
              ),
            ],
          ),
        ),
    );
  }


}
