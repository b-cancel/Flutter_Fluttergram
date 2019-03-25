import 'package:flutter/material.dart';
import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: Home(),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text("Welcome to Fluttergram"),
              new TextFormField(
                autofocus: true,
                controller: username,
                decoration: InputDecoration(
                  labelText: "Username",
                  hintText: "Your Username Here"
                ),
              ),
              new TextFormField(
                obscureText: true,
                controller: password,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Your Password Here"
                ),
              ),
              new RaisedButton(
                onPressed: () => print("bro no"),
                child: new Text("Log-In"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
