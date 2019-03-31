//CHUNK OF CODE TAKEN FROM:
//https://github.com/iampawan/Flutter-Instagram-UI-Clone

//flutter
import 'package:flutter/material.dart';

//within project
import 'package:fluttergram/postList.dart';
import 'package:fluttergram/shared.dart';

class Home extends StatefulWidget {
  final Data appData;
  //NOTE: we dont need a selectedMenuItem because if we are here we know its 0

  Home({
    Key key, 
    this.appData,
  }) : super(key: key);
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    print("*****rebuilding home");

    return Scaffold(
      appBar: PreferredSize(
        //The TopBar Widget will handel the size
        preferredSize: Size.fromHeight(45),
        child: TopBar(
          leading: new IconButton(
            onPressed: (){
              selectImage(true, context, widget.appData);
            },
            icon: Icon(Icons.camera_alt),
          ),
          title: new Text("Fluttergram"),
        ),
      ),
      body: Stack(
        children: <Widget>[
          PostList(
            appData: modForAllPosts(widget.appData),
            selectedMenuItem: 0,
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: BottomNav(
              appData: widget.appData,
              selectedMenuItem: 0,
            ),
          ),
        ],
      ),
    );
  }
}