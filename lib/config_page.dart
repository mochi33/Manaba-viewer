import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled1/web_view_screen.dart';

import 'manaba_data.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({Key? key}) : super(key: key);

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {

  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _userPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                onPressed: () async {
                  if(_userIdController.text != ''&& _userPassController.text != ''){
                    const storage = FlutterSecureStorage();
                    final oldId = await storage.read(key: 'ID');
                    if(oldId != _userIdController.text) {
                      debugPrint("change");
                      ManabaData.isUserChanged = true;
                    }
                    await storage.write(key: 'ID', value: _userIdController.text);
                    await storage.write(key: 'PASSWORD', value: _userPassController.text);
                    Navigator.pop(context);
                  } else {
                    showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text('入力してない項目があります。'),
                            content: const Text('IDとパスワードを入力してください。'),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('戻る'),
                              )
                            ],
                          );
                        }
                        );
                  }
                },
                child: const SizedBox(
                  width: 80,
                  height: 50,
                  child: Center(child: Text('保存', style: TextStyle(fontSize: 30),)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
