import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/web_view_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レポート＆小テスト'),
      ),
      body: Column(
        children: [
          const ListTile(
            title: Text('小テスト'),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: queryData.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: Text(queryData[index].split(r'\u003C/a>')[0].split(r'">')[1]),
                );
              },
          ),
          const ListTile(
            title: Text('レポート'),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reportData.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: Text(reportData[index].split(r'\u003C/a>')[0].split(r'">')[1]),
              );
            },
          ),
        ],

      ),
    );
  }

  Future<void> waitQuery() async{
    
  }
}
