import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:untitled1/page/news_list_page.dart';
import 'package:untitled1/page/timetable_page.dart';
import 'package:untitled1/page/query_detail_page.dart';
import 'package:untitled1/page/report_and_query_page.dart';
import 'package:untitled1/page/report_detail_page.dart';
import 'package:untitled1/page/webview/web_view_screen.dart';
import 'package:untitled1/page/webview/web_view_screen2.dart';

import 'config_page.dart';
import '../device_info.dart';
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
  int selectedPage = 0;

  late final _screens = [
    ReportAndQueryPage(key: reportAndQueryPageKey,),
    TimetablePage(key: timetablePageKey,),
    const NewsListPage(),
    WebViewScreen2(url: "https://ct.ritsumei.ac.jp/ct/home"),
    const ConfigPage(),
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
      body: Stack(
        children: [
          PersistentTabView(
            context,
            screens: _screens,
            items: [
              PersistentBottomNavBarItem(icon: const Icon(Icons.sticky_note_2_outlined), title: '課題'),
              PersistentBottomNavBarItem(icon: const Icon(Icons.calendar_today_outlined), title: 'コース一覧'),
              PersistentBottomNavBarItem(icon: const Icon(Icons.report), title: 'お知らせ'),
              PersistentBottomNavBarItem(icon: const Icon(Icons.smartphone), title: 'ブラウザ'),
              PersistentBottomNavBarItem(icon: const Icon(Icons.settings), title: '設定'),
            ],
            onItemSelected: (index) {
              selectedPage = index;
              setState(() {});
            },
            navBarHeight: DeviceInfo.deviceHeight * 0.10,
            navBarStyle: NavBarStyle.style8,
          ),
          (!isSigned && selectedPage != 4) ? const Center(
              child: Text("設定からログインしてください。")
          ) : Container()
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex:  _selectedIndex,
      //   onTap: _onIconTapped,
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(icon: Icon(Icons.home_work_outlined), label: 'レポート＆小テスト'),
      //     BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'コース一覧'),
      //     BottomNavigationBarItem(icon: Icon(Icons.report), label: 'お知らせ'),
      //   ],
      //   type: BottomNavigationBarType.fixed,
      // ),
    );
  }

}
