import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/course_detail_page.dart';
import 'package:untitled1/manaba_data.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({Key? key}) : super(key: key);

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {

  final List<String> _dayOfWeekList = ["月", "火", "水", "木", "金", "土", "日"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("コース時間割"),
          ),
          body: Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  const SizedBox(height: 20.0,),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 20.0,),
                        Table(
                          border:  TableBorder.all(color: Colors.lightBlueAccent),
                          columnWidths: const <int, TableColumnWidth>{
                            0: FixedColumnWidth(100.0),
                            1: FixedColumnWidth(100.0),
                            2: FixedColumnWidth(100.0),
                            3: FixedColumnWidth(100.0),
                            4: FixedColumnWidth(100.0),
                            5: FixedColumnWidth(100.0),
                            6: FixedColumnWidth(100.0),
                          },
                          children: [
                            TableRow(
                              children: [
                                Text(_dayOfWeekList[0]),
                                Text(_dayOfWeekList[1]),
                                Text(_dayOfWeekList[2]),
                                Text(_dayOfWeekList[3]),
                                Text(_dayOfWeekList[4]),
                                Text(_dayOfWeekList[5]),
                                Text(_dayOfWeekList[6]),
                              ]
                            ),
                            timetableRow("1"),
                            timetableRow("2"),
                            timetableRow("3"),
                            timetableRow("4"),
                            timetableRow("5"),
                          ],
                        ),
                        const SizedBox(width: 20.0,),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
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
        return SizedBox(
          height: 150.0,
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
    return Container(height: 150.0,);
  }
}
