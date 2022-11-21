import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:untitled1/WebViewInfo.dart';
import 'package:untitled1/page/webview/web_view_screen.dart';

import '../device_info.dart';

class RotatingUpdateButton extends StatefulWidget {
  const RotatingUpdateButton({Key? key}) : super(key: key);

  @override
  State<RotatingUpdateButton> createState() => _RotatingUpdateButtonState();
}

class _RotatingUpdateButtonState extends State<RotatingUpdateButton> {

  Timer? _timer;
  double updateButtonAngle = 0;
  bool beforeState = false;

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ManageDataStream.getWebViewPageStateStream(),
      builder: (con, snapshot) {
        if(beforeState != AppInfo.isLoading) {
          _timer?.cancel();
          if (AppInfo.isLoading == true) {
            _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
              updateButtonAngle += 3;
              setState(() {});
            });
          } else {
            updateButtonAngle = 0;
          }
        }

        if (AppInfo.isLoading == true) {
          return Transform.rotate(
            angle: updateButtonAngle * pi / 180,
            child: Icon(Icons.update, size: DeviceInfo.deviceHeight * 0.04),);
        } else {
          return Icon(Icons.update, size: DeviceInfo.deviceHeight * 0.04);
        }
      },
    );
  }
}
