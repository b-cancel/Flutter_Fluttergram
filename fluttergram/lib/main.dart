import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http; 

import 'package:flutter/material.dart';

import 'home.dart';

void main() => runApp(MyApp());

class Data {
  String url = "https://serene-beach-48273.herokuapp.com";
  String token = "";
  int currentUserID;
  int whoOwnsPostsID;
}

class MyApp extends StatelessWidget {
  final appData = new Data();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Fluttergram',
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
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient( 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromRGBO(145, 85, 179, 1), 
              const Color.fromRGBO(198, 55, 102, 1),
            ], 
            tileMode: TileMode.repeated,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: login,
            builder: (context, child){
              return new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: new Text(
                      "Fluttergram",
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    color: Color.fromARGB(255, 175, 80, 150), 
                    padding: EdgeInsets.all(4),
                    child: new TextFormField(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      cursorColor: Colors.white,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      controller: username,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Username",
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 16,
                    child: Container(),
                  ),
                  Container(
                    color: Color.fromARGB(255, 175, 80, 150), 
                    padding: EdgeInsets.all(4),
                    child: new TextFormField(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      cursorColor: Colors.white,
                      obscureText: true,
                      controller: password,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Password",
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  new OutlineButton(
                    borderSide: BorderSide(
                      color: Colors.white, 
                    ),
                    onPressed: submitAction,
                    child: new Text(
                      action(),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient( 
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromRGBO(165, 101, 136, 1), 
                const Color.fromRGBO(203, 66, 105, 1),
              ], 
              tileMode: TileMode.repeated,
            ),
            border: Border(
              top: BorderSide(
                color: Color.fromRGBO(255, 255, 255, .75),
              ),
            ),
          ),
          child: AnimatedBuilder(
            animation: login,
            builder: (BuildContext context, Widget child) {
              return new FlatButton(
                onPressed: () => login.value = !login.value,
                child: new Text(question()),
              );
            },
          ),
        ),
      ),
    );
  }
}