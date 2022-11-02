import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/course_detail_page.dart';
import 'package:untitled1/device_info.dart';
import 'package:untitled1/manaba_data.dart';
import 'package:untitled1/web_view_screen.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({Key? key}) : super(key: key);

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {

  final List<String> _dayOfWeekList = ["月", "火", "水", "木", "金", "土", "日"];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo((DeviceInfo.deviceWidth / 4) * (DeviceInfo.dayOfWeek + 1.5));
      debugPrint('adffasdf');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("コース時間割"),
            actions: [
              IconButton(
                onPressed: () async {
                  mainController!.loadUrl('https://ct.ritsumei.ac.jp/ct/home_course');
                  setState(() {});
                },
                icon: const Icon(Icons.update),
              )
            ],
          ),
          body: Container(
            child: StreamBuilder(
              stream: ManageDataStream.getCourseListStream(),
              builder: (context, snapshot) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: (DeviceInfo.deviceWidth / 4 * 3) + ((DeviceInfo.deviceWidth / 4) * (DeviceInfo.dayOfWeek + 0.3)),),
                            const Text('本日', style: TextStyle(color: Colors.lightGreen)),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          children: [
                            SizedBox(width: DeviceInfo.deviceWidth / 4 * 3,),
                            Table(
                              border:  TableBorder.all(color: Colors.lightBlueAccent),
                              columnWidths: const <int, TableColumnWidth>{
                                0: IntrinsicColumnWidth(),
                                1: IntrinsicColumnWidth(),
                                2: IntrinsicColumnWidth(),
                                3: IntrinsicColumnWidth(),
                                4: IntrinsicColumnWidth(),
                                5: IntrinsicColumnWidth(),
                                6: IntrinsicColumnWidth(),
                              },
                              children: [
                                dayOfWeekRow(),
                                timetableRow("1"),
                                timetableRow("2"),
                                timetableRow("3"),
                                timetableRow("4"),
                                timetableRow("5"),
                              ],
                            ),
                            SizedBox(width: DeviceInfo.deviceWidth / 4 * 3,),
                          ],
                        ),
                        SizedBox(height: DeviceInfo.deviceHeight * 0.5,),
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
        )
    );
  }

  TableRow dayOfWeekRow() {
    List<Widget> weekDayList = [];
    for (var dayOfWeek in _dayOfWeekList) {
      if(dayOfWeek == _dayOfWeekList[DeviceInfo.dayOfWeek]) {
        weekDayList.add(
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(width: 2, color: Colors.lightGreenAccent), left: BorderSide(width: 2, color: Colors.lightGreenAccent), right: BorderSide(width: 2, color: Colors.lightGreenAccent)),
              ),
              child: Text(dayOfWeek),
            )
        );
      } else {
        weekDayList.add(Text(dayOfWeek));
      }
    }

    return TableRow(
        children: weekDayList,
    );
  }

  TableRow timetableRow(String period) {
    List<Widget> periodCellList = [];

    for (String dayOfWeek in _dayOfWeekList) {
      periodCellList.add(timetableCell(dayOfWeek, period));
    }

    return TableRow(
      children: periodCellList,
    );
  }

  Widget timetableCell(String dayOfWeek, String period) {
    for (var course in ManabaData.courseList) {
      if (course["dayOfWeek"] == dayOfWeek && course["period"] == period) {
        if(dayOfWeek == _dayOfWeekList[DeviceInfo.dayOfWeek]) {
          if(period != '5') {
            return SizedBox(
              height: DeviceInfo.deviceHeight / 5,
              width: DeviceInfo.deviceWidth / 4,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(width: 2, color: Colors.lightGreenAccent), right: BorderSide(width: 2, color: Colors.lightGreenAccent)),
                ),
                padding: const EdgeInsets.all(3.0),
                alignment: Alignment.topCenter,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetailPage(courseData: course)),);
                  },
                  child: Text(course["title"] ?? ""),
                ),
              ),
            );
          } else {
            return SizedBox(
              height: DeviceInfo.deviceHeight / 5,
              width: DeviceInfo.deviceWidth / 4,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(width: 2, color: Colors.lightGreenAccent), right: BorderSide(width: 2, color: Colors.lightGreenAccent), bottom: BorderSide(width: 2, color: Colors.lightGreenAccent)),
                ),
                padding: const EdgeInsets.all(3.0),
                alignment: Alignment.topCenter,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetailPage(courseData: course)),);
                  },
                  child: Text(course["title"] ?? ""),
                ),
              ),
            );
          }
        } else {
          return SizedBox(
            height: DeviceInfo.deviceHeight / 5,
            width: DeviceInfo.deviceWidth / 4,
            child: Container(
              padding: const EdgeInsets.all(3.0),
              alignment: Alignment.topCenter,
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetailPage(courseData: course)),);
                },
                child: Text(course["title"] ?? ""),
              ),
            ),
          );
        }
      }
    }
    if (dayOfWeek == _dayOfWeekList[DeviceInfo.dayOfWeek]) {
      if (period != '5') {
        return Container(
          height: DeviceInfo.deviceHeight / 5,
          width: DeviceInfo.deviceWidth / 4,
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(width: 2, color: Colors.lightGreenAccent), right: BorderSide(width: 2, color: Colors.lightGreenAccent)),
          ),
        );
      }
      return Container(
        height: DeviceInfo.deviceHeight / 5,
        width: DeviceInfo.deviceWidth / 4,
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(width: 2, color: Colors.lightGreenAccent), right: BorderSide(width: 2, color: Colors.lightGreenAccent), bottom: BorderSide(width: 2, color: Colors.lightGreenAccent)),
        ),
      );
    }
    return Container(
      height: DeviceInfo.deviceHeight / 5,
      width: DeviceInfo.deviceWidth / 4,
    );
  }
}
