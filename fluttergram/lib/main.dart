import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http; 

import 'package:flutter/material.dart';

import 'home.dart';



void main() => runApp(MyApp());

class Data {
  String url = "https://serene-beach-48273.herokuapp.com";
  String token = "";
}

class MyApp extends StatelessWidget {
  final appData = new Data();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Instagram',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.black,
          primaryIconTheme: IconThemeData(color: Colors.black),
          primaryTextTheme: TextTheme(
              title: TextStyle(color: Colors.black, fontFamily: "Aveny")),
          textTheme: TextTheme(title: TextStyle(color: Colors.black))),
      home: new LoginPage(appData),
    ); 
  }
}

class LoginPage extends StatefulWidget {
  final appData;
  LoginPage(this.appData);

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();

  ValueNotifier<bool> login = new ValueNotifier(true);

  String title(){
    if(login.value) return "Login to Fluttergram";
    else return 'Create a Fluttergram Account';
  }

  String question(){
    if(login.value) return "Don't have an Account?";
    else return "Already have an Account?";
  }

  String action(){
    if(login.value) return "Login";
    else return "Sign Up";
  }

  void submitAction(){
    //TODO... inspect the parameters

    //request
    if(login.value) loginUser();
    else{
      var urlMod = widget.appData.url + "/api";
      urlMod += "/register" + "?username=" + username.text + "&password=" + password.text;  

      http.post(urlMod).then((response){
        //confirm valid response
        if(response.statusCode == 201){ 
          //account successfull created
          loginUser();
        }
        else{ 
          print(urlMod + " register fail");
          //TODO... trigger some visual error
        }
      });
    }
  }

  void loginUser(){
    var urlMod = widget.appData.url + "/api";
    urlMod += "/login" + "?username=" + username.text + "&password=" + password.text;  

    http.get(urlMod).then((response){
        //confirm valid response
        if(response.statusCode == 200){ 
          //save our token
          var jsonResponse = jsonDecode(response.body);
          widget.appData.token = jsonResponse["token"].toString();
          //confirm token
          confirmToken();
        }
        else{ 
          print(urlMod + " login fail");
          //TODO... trigger some visual error
        }
    });
  }

  void confirmToken(){
    http.get(
      widget.appData.url + "/api/token_check", 
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
    ).then((respone){
      if(respone.statusCode == 200){
        var jsonResponse = jsonDecode(respone.body);
        if(jsonResponse["message"] == "Valid Token"){
          //go to next page with valid token
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Home(
                appData: widget.appData,
              ),
            ),
          );
        }
        else{
          print(widget.appData.url + "/api/token_check" + " token problem 2 " + jsonResponse["message"]);
          //TODO... trigger some visual error
        }
      }
      else{
        print(widget.appData.url + "/api/token_check" + " token problem");
        //TODO... trigger some visual error
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedBuilder(
            animation: login,
            builder: (context, child){
              return new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Text(title()),
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
                  new FlatButton(
                    onPressed: () => login.value = !login.value,
                    child: new Text(question()),
                  ),
                  new RaisedButton(
                    onPressed: submitAction,
                    child: new Text(action()),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}