import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:untitled1/html_function.dart';
import 'package:untitled1/manaba_data.dart';
import 'package:untitled1/page/webview/web_view_screen.dart';
import 'package:untitled1/page/webview/web_view_screen2.dart';
import 'package:url_launcher/url_launcher.dart';

import '../device_info.dart';

class ContentDetailPage extends StatefulWidget {

  Map<String, String> contentData;
  bool isTopPage;
  String contentDetailID;

  ContentDetailPage({Key? key, required this.contentData, required this.isTopPage, this.contentDetailID = ''}) : super(key: key);

  @override
  State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage> {

  List<Map<String, String>> contentDetailList = [];
  Map<String, String> contentDetail = {};
  String contentDetailID = '';
  bool isFirstLoad = true;
  late Stream contentStream = ManageDataStream.getContentDetailStream();

  @override
  Widget build(BuildContext context) {
    if (isFirstLoad) {
      mainController!.loadUrl('https://ct.ritsumei.ac.jp/ct/page_' + (widget.contentData['ID'] ?? '') + 'c' + (widget.contentData['courseID'] ?? '') + (!widget.isTopPage ? '_' + widget.contentDetailID : ''));
      contentDetailID = widget.contentDetailID;
    } else {
      mainController!.loadUrl('https://ct.ritsumei.ac.jp/ct/page_' + (widget.contentData['ID'] ?? '') + 'c' + (widget.contentData['courseID'] ?? '') + '_' + contentDetailID);
    }

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
                StreamBuilder(
                  stream: contentStream,
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      contentDetailList.clear();
                      for (final contentDetailData in ManabaData.contentsDetailList) {
                        if (contentDetailData['contentID'] == widget.contentData['ID']) {
                          contentDetailList.add(contentDetailData);
                        }
                        if (!widget.isTopPage || !isFirstLoad) {
                          if (contentDetailData['ID'] == contentDetailID) {
                            contentDetail = contentDetailData;
                          }
                        } else {
                          if (contentDetailData['ID'] == widget.contentData['topPage']) {
                            contentDetail = contentDetailData;
                          }
                        }
                      }
                      for(final a in contentDetailList) {
                        print('a' + a.toString());
                      }
                      return Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: contentDetailList.length,
                            itemBuilder: (context, index) {
                              return TextButton(
                                child: Text(contentDetailList[index]['title'] ?? ''),
                                onPressed: () => setState(() {
                                  isFirstLoad = false;
                                  contentDetailID = contentDetailList[index]['ID'] ?? '';
                                  contentStream = ManageDataStream.getContentDetailStream();
                                }),
                              );
                              },
                          ),
                          SizedBox(height: DeviceInfo.deviceHeight * 0.08,),
                          Html(
                            data: HtmlFunction.parseHTML(contentDetail['body'] ?? ''),
                            onLinkTap: (link, a, b, c) {
                              print(b);
                              print(link);
                              print(HtmlFunction.urlAsciiDecoder(link?.split('url=')[1] ?? ''));
                              Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewScreen2(url: HtmlFunction.urlAsciiDecoder(link?.split('url=')[1] ?? ''))));
                            },
                          ),
                          Html(
                            data: HtmlFunction.parseHTML(contentDetail['file'] ?? ''),
                            onLinkTap: (link, a, b, c) {
                              print(b);
                              print(link);
                              launchUrl(Uri(

                              ));
                              //downloadFile('https://ct.ritsumei.ac.jp/ct/' + (HtmlFunction.parseString(link, r'\"', null) ?? ''));
                              //Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewScreen2(url: 'https://docs.google.com/viewer?url=' + 'https://ct.ritsumei.ac.jp/ct/' + (HtmlFunction.parseString(link, r'\"', null) ?? ''))));
                            },
                          )
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ),
        )
    );

  }

  // Widget titleList(List<Map<String, String>> contentDetailList) {
  //   List<Map<String, String>> titleList = [];
  //   for (final content in contentDetailList) {
  //     titleList.add(content['title'] ?? '');
  //   }
  //   return Column();
  // }
}

