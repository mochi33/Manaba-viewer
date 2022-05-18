import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class configPage extends StatefulWidget {
  const configPage({Key? key}) : super(key: key);

  @override
  _configPageState createState() => _configPageState();
}

class _configPageState extends State<configPage> {

  TextEditingController _userIdController = TextEditingController();
  TextEditingController _userPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ID', style: TextStyle(fontSize: 15.0)),
              SizedBox(height: 10.0),
              TextField(
                controller: _userIdController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  filled: true,
                  hintText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0),),borderSide: BorderSide(color: Colors.white),),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0),),borderSide: BorderSide(color: Colors.white),),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0),),borderSide: BorderSide(color: Colors.white),),
                  contentPadding: EdgeInsets.only(left: 10.0, right: 10.0, top: 3.0,),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Text('PASSWORD', style: TextStyle(fontSize: 15.0)),
              SizedBox(height: 10.0,),
              TextField(
                controller: _userPassController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  filled: true,
                  hintText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0),),borderSide: BorderSide(color: Colors.white),),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0),),borderSide: BorderSide(color: Colors.white),),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0),),borderSide: BorderSide(color: Colors.white),),
                  contentPadding: EdgeInsets.only(left: 10.0, right: 10.0, top: 3.0,),
                ),
              ),
              SizedBox(height: 50.0,),
              ElevatedButton(
                onPressed: () async {
                  if(_userIdController.text != '' && _userPassController != ''){
                    final storage = FlutterSecureStorage();
                    await storage.write(key: 'ID', value: _userIdController.text);
                    await storage.write(key: 'PASSWORD', value: _userPassController.text);
                  }
                  Navigator.pop(context);
                },
                child: SizedBox(
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
