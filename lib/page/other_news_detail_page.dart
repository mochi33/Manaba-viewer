import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:untitled1/page/webview/web_view_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../html_function.dart';
import '../manaba_data.dart';

class OtherNewsDetailPage extends StatefulWidget {

  Map<String, String> otherNewsData;
  OtherNewsDetailPage({Key? key, required this.otherNewsData}) : super(key: key);

  @override
  State<OtherNewsDetailPage> createState() => _OtherNewsDetailPageState();
}

class _OtherNewsDetailPageState extends State<OtherNewsDetailPage> {

  bool isFirstGet = false;

  void getData(String id) {
    print('fdaf');
    mainController?.loadUrl("https://ct.ritsumei.ac.jp/ct/home_announcement_detail_" + id);
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
              Center(child: Text(widget.otherNewsData['title'] ?? '', style: const TextStyle(fontSize: 20),)),
              const SizedBox(height: 10.0,),
              Container(
                // decoration: BoxDecoration(
                //   border: Border.all(color: Colors.black, width: 2),
                // ),
                child: StreamBuilder(
                  stream: ManageDataStream.getOtherNewsDetailStream(),
                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if(!isFirstGet) {
                      getData(widget.otherNewsData['ID'] ?? '');
                      isFirstGet = true;
                    }
                    Map<String, String> _otherNewsData = widget.otherNewsData;
                    if(snapshot.data != null && snapshot.data == _otherNewsData['ID']) {
                      _otherNewsData = ManabaData.otherNewsList.firstWhere((news) => news['ID'] == _otherNewsData['ID']);
                    }
                    debugPrint(_otherNewsData['detail'] ?? '');
                    return Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Html(
                            data: HtmlFunction.parseHTML(_otherNewsData['detail'] ?? ''),
                            onLinkTap: (link, a, b, c) async {
                              print(b);
                              print(link);
                              final uri = Uri.parse(HtmlFunction.parseString(link, r'\"', null) ?? '');
                              if (link?.contains('iframe') == false) {
                                if (link?.contains('http') == true) {
                                  launchUrl(Uri.parse((HtmlFunction.parseString(link, r'\"', null) ?? '')), mode: LaunchMode.externalApplication);
                                } else {
                                  launchUrl(Uri.parse('https://ct.ritsumei.ac.jp/ct/' + (HtmlFunction.parseString(link, r'\"', null) ?? '')), mode: LaunchMode.externalApplication);
                                }
                              } else {
                                launchUrl(Uri.parse(HtmlFunction.urlAsciiDecoder(link?.split('url=')[1] ?? '')), mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                          const SizedBox(height: 30.0),
                          Text(_otherNewsData['date'] ?? ''),
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
