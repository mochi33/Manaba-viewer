import 'package:flutter/material.dart';
import 'package:untitled1/page/webview/web_view_screen.dart';

class ContentDetailPage extends StatefulWidget {

  Map<String, String> contentData;

  ContentDetailPage({Key? key, required this.contentData}) : super(key: key);

  @override
  State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('コンテンツ詳細'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: Text(widget.contentData['title']!),
                ),
                (widget.contentData['detail'] == null) ? StreamBuilder(
                  stream: ManageDataStream.getReportQueryDetailStream(),
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
                  title: Text(widget.contentData['detail'] ?? ''),
                ),
              ],
            ),
          ),
        )
    );
  }
}
