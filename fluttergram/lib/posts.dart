//CHUNK OF CODE TAKEN FROM:
//https://github.com/iampawan/Flutter-Instagram-UI-Clone

import 'package:flutter/material.dart';
import 'package:fluttergram/main.dart';
import 'package:fluttergram/postList.dart';

class Posts extends StatefulWidget {
  final Data appData;

  Posts({
    Key key,
    this.appData,
  }) : super(key: key);

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  Data modForAllPosts(appData){
    appData.whoOwnsPostsID = -1; //the secret code for all posts
    return appData;
  }
  
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
      body: PostList(
        appData: modForAllPosts(widget.appData),
        callback: () => print("callback not needed we are at home"),
      ),
    );
  }
}