import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/news_list_page.dart';
import 'package:untitled1/timetable_page.dart';
import 'package:untitled1/query_detail_page.dart';
import 'package:untitled1/report_and_query_page.dart';
import 'package:untitled1/report_detail_page.dart';
import 'package:untitled1/web_view_screen.dart';

import 'config_page.dart';
import 'device_info.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {

  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {

  final GlobalKey<State<ReportAndQueryPage>> reportAndQueryPageKey = GlobalKey<State<ReportAndQueryPage>>();
  final GlobalKey<State<TimetablePage>> timetablePageKey = GlobalKey<State<TimetablePage>>();

  late final _screens = [
    ReportAndQueryPage(key: reportAndQueryPageKey,),
    TimetablePage(key: timetablePageKey,),
    const NewsListPage(),
  ];

  int _selectedIndex = 0;

  void _onIconTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void update() {
    reportAndQueryPageKey.currentState?.setState(() {});
    timetablePageKey.currentState?.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    update();
    DeviceInfo.deviceHeight = MediaQuery.of(context).size.height;
    DeviceInfo.deviceWidth = MediaQuery.of(context).size.width;
    var now = DateTime.now();
    DeviceInfo.day = now.day;
    DeviceInfo.month = now.month;
    DeviceInfo.dayOfWeek = now.weekday - 1;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:  _selectedIndex,
        onTap: _onIconTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_work_outlined), label: 'レポート＆小テスト'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'コース一覧'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'お知らせ'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

}
