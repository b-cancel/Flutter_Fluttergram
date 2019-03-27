import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttergram/main.dart';
import 'package:fluttergram/profile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dart:async';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;

class Comments extends StatefulWidget {
  final Data appData;
  final int postID;

  Comments({
    Key key,
    this.appData,
    this.postID,
  }) : super(key: key);

  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  fetchData() {
    return this._memoizer.runOnce(() async {
      return await getData();
    });
  }

  Future getData() async{
    //retreive data from server
    var urlMod = widget.appData.url + "/api/v1/posts/" + widget.postID.toString() + "/comments";

    return await http.get(
      urlMod, 
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
    ).then((response){
        if(response.statusCode == 200){
          return jsonDecode(response.body);
        }
        else{ 
          print(urlMod + " get posts fail");
          //TODO... trigger some visual error
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          backgroundColor: new Color(0xfff8faf8),
          elevation: 1.0,
          centerTitle: false,
          title: new Text("Comments")
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              PostComment(),
              PostComment(),
              PostComment(),
            ],
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey,
                  )
                )
              ),
              child: new TextFormField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(0, 16, 8, 16),
                  border: InputBorder.none,
                  hintText: "Add a comment...",
                  hintStyle: TextStyle(
                    color: Colors.grey
                  ),
                  icon: Container(
                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                    child: new Container(
                      height: 35.0,
                      width: 35.0,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(
                            "https://pbs.twimg.com/profile_images/916384996092448768/PF1TSFOE_400x400.jpg",
                          ),
                        ),
                      ),
                    ),
                  ),
                  suffixIcon: new FlatButton(
                    onPressed: () => print("submit comment"),
                    child: new Text(
                      "Post",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  )
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostComment extends StatelessWidget {
  const PostComment({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Container(
            height: 40.0,
            width: 40.0,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                fit: BoxFit.fill,
                image: new NetworkImage(
                  "https://pbs.twimg.com/profile_images/916384996092448768/PF1TSFOE_400x400.jpg",
                ),
              ),
            ),
          ),
          new SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "the fellas name",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: " " + "a comment that merits everyones attention",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ]
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "posted on " + "12/23/13 9:00 pm", 
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}