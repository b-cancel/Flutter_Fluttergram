import 'package:flutter/material.dart';

class NewPost extends StatefulWidget {
  NewPost({Key key}) : super(key: key);
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: new Text("New Post"),
    );
  }
}