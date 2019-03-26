//CHUNK OF CODE TAKEN FROM:
//https://github.com/iampawan/Flutter-Instagram-UI-Clone

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttergram/postList.dart';

class Posts extends StatefulWidget {
  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
          child: new AppBar(
          backgroundColor: new Color(0xfff8faf8),
          elevation: 1.0,
          leading: new Icon(Icons.camera_alt),
          title: SizedBox(
            child: new Text("Fluttergram"),
          ),
        ),
      ),
      body: PostList(),
    );
  }
}