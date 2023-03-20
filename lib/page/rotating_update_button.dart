import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:untitled1/StreamManager.dart';
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
      stream: StreamManager.getCommonStream("webViewPageState"),
      builder: (con, snapshot) {
        return Icon((!AppInfo.isLoading) ? Icons.update : Icons.cloud_download_outlined, size: DeviceInfo.deviceHeight * 0.04,);
      },
    );
  }
}
