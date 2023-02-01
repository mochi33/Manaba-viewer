import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled1/WebViewInfo.dart';
import 'package:untitled1/page/webview/web_view_screen.dart';

import '../device_info.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({Key? key}) : super(key: key);

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {

  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _userPassController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: Container(
        padding: EdgeInsets.only(right: DeviceInfo.deviceWidth * 0.05, left: DeviceInfo.deviceWidth * 0.05),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('ID', style: TextStyle(fontSize: 15.0)),
              const SizedBox(height: 10.0),
              TextField(
                controller: _userIdController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  filled: true,
                  hintText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0),),borderSide: BorderSide(color: Colors.white),),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0),),borderSide: BorderSide(color: Colors.white),),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0),),borderSide: BorderSide(color: Colors.white),),
                  contentPadding: EdgeInsets.only(left: 10.0, right: 10.0, top: 3.0,),
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              const Text('PASSWORD', style: TextStyle(fontSize: 15.0)),
              const SizedBox(height: 10.0,),
              TextField(
                controller: _userPassController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  filled: true,
                  hintText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0),),borderSide: BorderSide(color: Colors.white),),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0),),borderSide: BorderSide(color: Colors.white),),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0),),borderSide: BorderSide(color: Colors.white),),
                  contentPadding: EdgeInsets.only(left: 10.0, right: 10.0, top: 3.0,),
                ),
              ),
              const SizedBox(height: 50.0,),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: !_isLoading ? MaterialStateProperty.all<Color>(Colors.blueAccent) : MaterialStateProperty.all<Color>(Colors.black12),
                ),
                onPressed: () async {
                  if(_userIdController.text != ''&& _userPassController.text != ''){
                    const storage = FlutterSecureStorage();
                    final _oldId = await storage.read(key: 'ID');
                    if (_oldId != _userIdController.text) {
                      AppInfo.isUserChanged = true;
                    }
                    await storage.write(key: 'ID', value: _userIdController.text);
                    await storage.write(key: 'PASSWORD', value: _userPassController.text);
                    await mainController!.loadUrl('https://ct.ritsumei.ac.jp/ct/home_course');
                    setState(() {
                      _isLoading = true;
                    });
                    await Future.delayed(const Duration(seconds: 3));
                    setState(() {
                      _isLoading = false;
                    });
                    if (currentUrl?.contains('https://ct.ritsumei.ac.jp/ct') == true) {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('ログインに成功しました。'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('戻る'),
                                )
                              ],
                            );
                          });
                    } else {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('IDまたはパスワードが間違っています。'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('戻る'),
                            )
                          ],
                        );
                      });
                    }
                  } else {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('入力してない項目があります。'),
                            content: const Text('IDとパスワードを入力してください。'),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('戻る'),
                              )
                            ],
                          );
                        }
                        );
                  }
                },
                child: SizedBox(
                  width: 80,
                  height: 50,
                  child: Center(child: !_isLoading ? Text('保存', style: const TextStyle(fontSize: 30),) : const Icon(Icons.update)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
