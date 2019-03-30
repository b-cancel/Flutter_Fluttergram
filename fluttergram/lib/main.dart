//flutter
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//dart
import 'dart:convert';
import 'dart:io';

//plugins
import 'package:http/http.dart' as http; 

//within project
import 'package:fluttergram/shared.dart';
import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final appData = new Data();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Fluttergram',
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => Home(),
      },
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

  Widget question(){
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: (login.value == false) ? "Don't have an account?" : "Already have an account?",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          TextSpan(
            text: (login.value == false) ? " Sign up." : " Log in.",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 38, 38, 38),
              fontSize: 12,
            ),
          ),
        ]
      ),
    );
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
    ).then((response){
      if(response.statusCode == 200){
        var jsonResponse = jsonDecode(response.body);
        if(jsonResponse["message"] == "Valid Token"){
          http.get(
            widget.appData.url + "/api/v1/my_account",
            headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
          ).then((response){
            if(response.statusCode == 200){
              var jsonResponse = jsonDecode(response.body);

              //set our appData vars
              widget.appData.currentUserID = jsonResponse["id"];

              //go to next page with valid token
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Home(
                    appData: widget.appData,
                  ),
                ),
              );
            }
            else{
              print(widget.appData.url + "/api/v1/my_account" + " problem");
              //TODO... trigger some visual error
            }
          });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                "English (United States)",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              new Icon(
                FontAwesomeIcons.chevronDown,
                size: 8,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: AnimatedBuilder(
            animation: login,
            builder: (context, child){
              return new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      alignment: Alignment.center,
                      child: new Text(
                        "Fluttergram",
                        style: TextStyle(
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: ShapeDecoration(
                      color: Color.fromARGB(255, 235, 235, 235),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        side: new BorderSide(
                          color: Colors.grey,
                        ),
                      )
                    ),
                    child: new TextFormField(
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      controller: username,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        border: InputBorder.none,
                        hintText: "Email",
                      ),
                    ),
                  ),
                  Container(
                    height: 12,
                    child: Container(),
                  ),
                  Container(
                    decoration: ShapeDecoration(
                      color: Color.fromARGB(255, 235, 235, 235),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        side: new BorderSide(
                          color: Colors.grey,
                        ),
                      )
                    ),
                    child: new TextFormField(
                      obscureText: true,
                      controller: password,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        border: InputBorder.none,
                        hintText: "Password",
                      ),
                    ),
                  ),
                  Container(
                    height: 12,
                    child: Container(),
                  ),
                  new RaisedButton(
                    onPressed: submitAction,
                    color: Colors.blue,
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
            border: Border(
              top: BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
          child: AnimatedBuilder(
            animation: login,
            builder: (BuildContext context, Widget child) {
              return new FlatButton(
                onPressed: () => login.value = !login.value,
                child: question(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CustomLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        width: width,
        padding: EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Container(
          height: width/5,
          width: width/5,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}