import 'package:flutter/material.dart';
import 'package:fluttergram/shared.dart';

class NewPost extends StatefulWidget {
  final Data appData;

  NewPost({
    this.appData,
    Key key,
  }) : super(key: key);
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
              child: Container(
               child: new Text("New Post"),
            ),
          ),
          BottomNav(
            appData: widget.appData,
            selectedMenuItem: 1,
          ),
        ],
      ),
    );
  }
}