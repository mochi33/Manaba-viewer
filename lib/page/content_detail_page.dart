
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:untitled1/html_function.dart';
import 'package:untitled1/manaba_data.dart';
import 'package:untitled1/page/pdf_page.dart';
import 'package:untitled1/page/webview/web_view_screen.dart';
import 'package:untitled1/page/webview/web_view_screen2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

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
            child: Container(
              padding: EdgeInsets.only(left: DeviceInfo.deviceWidth * 0.1, right: DeviceInfo.deviceWidth * 0.1),
              child: Column(
                children: [
                  Center(
                    child: ListTile(
                      title: Text(widget.contentData['title']!),
                    ),
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
                                return Column(
                                  children: [
                                    TextButton(
                                      child: Text(contentDetailList[index]['title'] ?? ''),
                                      onPressed: () => setState(() {
                                        isFirstLoad = false;
                                        contentDetailID = contentDetailList[index]['ID'] ?? '';
                                        contentStream = ManageDataStream.getContentDetailStream();
                                      }),
                                    ),
                                    Divider(height: DeviceInfo.deviceHeight * 0.005),
                                  ],
                                );
                                },
                            ),
                            SizedBox(height: DeviceInfo.deviceHeight * 0.04,),
                            Center(child: Text(contentDetail['title'] ?? ''),),
                            Divider(height: DeviceInfo.deviceHeight * 0.01, color: Colors.black87),
                            SizedBox(height: DeviceInfo.deviceHeight * 0.02,),
                            (contentDetail['body'] != null && contentDetail['body'] != '') ? Container(
                              // decoration: BoxDecoration(
                              //   border: Border.all(color: Colors.black, width: 2),
                              // ),
                              child: Html(
                                data: HtmlFunction.parseHTML(contentDetail['body']!),
                                onLinkTap: (link, a, b, c) async {
                                  print(link);
                                  print('https://ct.ritsumei.ac.jp/ct/' + (HtmlFunction.parseString(link, r'\"', null) ?? ''));
                                  if (link?.contains('iframe') == false) {
                                    if (link?.contains('http') == true) {
                                      launchUrl(Uri.parse((HtmlFunction.parseString(link, r'\"', null) ?? '')), mode: LaunchMode.externalApplication);
                                    } else {
                                      launchUrl(Uri.parse('https://ct.ritsumei.ac.jp/ct/' + (HtmlFunction.parseString(link, r'\"', null) ?? '')), mode: LaunchMode.externalApplication);
                                    }
                                  } else {
                                    launchUrl(Uri.parse(HtmlFunction.urlAsciiDecoder(link?.split('url=')[1] ?? '')), mode: LaunchMode.externalApplication);
                                  }
                                  //final filename = await downloadFile('https://ct.ritsumei.ac.jp/ct/' + (HtmlFunction.parseString(link, r'\"', null) ?? ''), "", '');
                                  //print(filename);
                                  //print(HtmlFunction.urlAsciiDecoder(link?.split('url=')[1] ?? ''));
                                 // Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewScreen2(url: 'https://ct.ritsumei.ac.jp/ct/' + (HtmlFunction.parseString(link, r'\"', null) ?? ''))));
                                  //Navigator.push(context, MaterialPageRoute(builder: (context) => PDFPage(pdfURL: 'https://ct.ritsumei.ac.jp/ct/' + (HtmlFunction.parseString(link, r'\"', null) ?? ''))));
                                  // launchUrl(Uri.parse('https://ct.ritsumei.ac.jp/ct/' + (HtmlFunction.parseString(link, r'\"', null) ?? '')),);
                                  // Map<String, String> header = {'cookie' : webViewCookie ?? ''};
                                  // http.Response response = await http.get(Uri.parse('https://ct.ritsumei.ac.jp/ct/' + (HtmlFunction.parseString(link, r'\"', null) ?? '')), headers: header);
                                  // print(response.body);
                                },
                              ),
                            ) : Container(),
                            SizedBox(height: DeviceInfo.deviceHeight * 0.05,),
                            // (contentDetail['file'] != null || contentDetail['file'] != '') ? Container(
                            //   decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.black, width: 2),
                            //   ),
                            //   child: Html(
                            //     data: HtmlFunction.parseHTML((contentDetail['file'] == null || contentDetail['file'] == '') ? '' : contentDetail['file']!),
                            //     onLinkTap: (link, a, b, c) {
                            //       print(b);
                            //       print(link);
                            //       Navigator.push(context, MaterialPageRoute(builder: (context) => PDFPage(pdfURL: link ?? '')));
                            //       //downloadFile('https://ct.ritsumei.ac.jp/ct/' + (HtmlFunction.parseString(link, r'\"', null) ?? ''));
                            //       //Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewScreen2(url: 'https://docs.google.com/viewer?url=' + 'https://ct.ritsumei.ac.jp/ct/' + (HtmlFunction.parseString(link, r'\"', null) ?? ''))));
                            //     },
                            //   ),
                            // ) : Container(),
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
          ),
        )
    );

  }

  Future<String> downloadFile(String url, String fileName, String dir) async {
    HttpClient httpClient = HttpClient();
    File file;
    String filePath = '';
    String myUrl = '';

    try {
      //myUrl = url+'/'+fileName;
      myUrl = url;
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();
      if(response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName';
        file = File(filePath);
        await file.writeAsBytes(bytes);
      } else {
        filePath = 'Error code:'+response.statusCode.toString();
      }
    } catch(ex){
      filePath = 'Can not fetch url';
    }

    return filePath;
  }

  // Widget titleList(List<Map<String, String>> contentDetailList) {
  //   List<Map<String, String>> titleList = [];
  //   for (final content in contentDetailList) {
  //     titleList.add(content['title'] ?? '');
  //   }
  //   return Column();
  // }
}

