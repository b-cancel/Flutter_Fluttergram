import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttergram/main.dart';
import 'package:fluttergram/profile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dart:convert';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;

class Comments extends StatefulWidget {
  final Data appData;
  final int postID;
  final String postOwnerImageUrl;
  final String postOwnerEmail;
  final String postCaption;
  final String postTimeStamp;
  final Function callback;

  Comments({
    Key key,
    this.appData,
    this.postID,
    this.postOwnerImageUrl,
    this.postOwnerEmail,
    this.postCaption,
    this.postTimeStamp,
    @required this.callback,
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
    //make url
    var urlMod = widget.appData.url + "/api/v1/posts/" + widget.postID.toString() + "/comments";

    //get data from server
    return await http.get(
      urlMod, 
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
    ).then((response){
        if(response.statusCode == 200){
          return jsonDecode(response.body);
        }
        else{ 
          print(urlMod + " get comments fail");
          //TODO... trigger some visual error
        }
    });

    //turn off force fetch in case we where triggered because of it
    forceFetch = false;
  }

  TextEditingController newCommentText = new TextEditingController();

  void newComment(){
    var comment = newCommentText.text;
    if(comment != ""){
      var urlMod = widget.appData.url + "/api/v1/posts/" 
      + widget.postID.toString() + "/comments?text=" + comment;

      http.post(
        urlMod, 
        headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
      ).then((response){
          if(response.statusCode == 200){
            //Submit Field
            newCommentText.text = ""; 
            FocusScope.of(context).requestFocus(new FocusNode());

            //Fetch New Comment
            forceFetch = true;
            setState(() {}); //should trigger re-fetching of data
          }
          else{ 
            print(urlMod + " post comment fail");
            //TODO... trigger some visual error
          }
      });
    }
    //ELSE... we ignore your dumb request
  }

  bool forceFetch = false;

  final AsyncMemoizer fetchImageMemoi = AsyncMemoizer();

  fetchImageData() {
    return this.fetchImageMemoi.runOnce(() async {
      return await getImageData();
    });
  }

  Future getImageData() async{
    var urlMod = widget.appData.url + "/api/v1/users/" + widget.appData.currentUserID.toString();

    return await http.get(
      urlMod, 
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
    ).then((response){
        if(response.statusCode == 200){
          return jsonDecode(response.body);
        }
        else{ 
          print(urlMod + " get image fail");
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
          leading: IconButton(
            icon: const BackButtonIcon(),
            color: Colors.black,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              Navigator.maybePop(context).then((value){
                widget.callback();
              });
            }
          ),
          backgroundColor: new Color(0xfff8faf8),
          elevation: 1.0,
          centerTitle: false,
          title: new Text("Comments")
        ),
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder(
            future: (forceFetch) ? getData() : fetchData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.connectionState == ConnectionState.done){
                //convert to list so we can actually use it
                List list = snapshot.data;

                //return the data
                return ListView(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: PostComment(
                        appData: widget.appData,
                        imageUrl: widget.postOwnerImageUrl,
                        email: widget.postOwnerEmail,
                        comment: widget.postCaption,
                        timeStamp: widget.postTimeStamp,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) => PostComment(
                        appData: widget.appData,
                        userID: list[index]["user_id"],
                        comment: list[index]["text"],
                        timeStamp: list[index]["created_at"],
                      ),
                    ),
                  ],
                );
              }
              else return CustomLoading();
            },
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey,
                  )
                )
              ),
              child: new TextFormField(
                controller: newCommentText,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(0, 16, 8, 16),
                  border: InputBorder.none,
                  hintText: "Add a comment...",
                  hintStyle: TextStyle(
                    color: Colors.grey
                  ),
                  icon: Container(
                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                    child: FutureBuilder(
                      future: getImageData(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        //generate the url
                        var imageUrl = "";
                        if(snapshot.connectionState == ConnectionState.done){
                          if(snapshot.data["profile_image_url"] == null){
                            imageUrl = "https://prd-wret.s3-us-west-2.amazonaws.com/assets/palladium/production/s3fs-public/thumbnails/image/Placeholder_person.png";
                          }
                          else{
                            imageUrl = snapshot.data["profile_image_url"];
                          }
                        }
                        else{
                          imageUrl = "https://prd-wret.s3-us-west-2.amazonaws.com/assets/palladium/production/s3fs-public/thumbnails/image/Placeholder_person.png";
                        }

                        //display
                        return Container(
                          height: 35.0,
                          width: 35.0,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new NetworkImage(
                                imageUrl,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  suffixIcon: new FlatButton(
                    onPressed: () => newComment(),
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

class PostComment extends StatefulWidget {
  final Data appData;
  final int userID;
  final String imageUrl;
  final String email;
  final String comment;
  final String timeStamp;

  const PostComment({
    //TODO... add functionality
    this.appData, //used to allow edit and delete
    this.userID,
    this.imageUrl,
    this.email,
    this.comment,
    this.timeStamp,
    Key key,
  }) : super(key: key);

  @override
  _PostCommentState createState() => _PostCommentState();
}

class _PostCommentState extends State<PostComment> {
  final AsyncMemoizer fetchImageMemoi = AsyncMemoizer();

  fetchImageData() {
    return this.fetchImageMemoi.runOnce(() async {
      return await getImageData();
    });
  }

  Future getImageData() async{
    var urlMod = widget.appData.url + "/api/v1/users/" + widget.userID.toString();

    return await http.get(
      urlMod, 
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
    ).then((response){
        if(response.statusCode == 200){
          return jsonDecode(response.body);
        }
        else{ 
          print(urlMod + " get image fail");
          //TODO... trigger some visual error
        }
    });
  }

  final AsyncMemoizer fetchEmailMemoi = AsyncMemoizer();

  fetchEmailData() {
    return this.fetchEmailMemoi.runOnce(() async {
      return await getEmailData();
    });
  }

  Future getEmailData() async{
    var urlMod = widget.appData.url + "/api/v1/users/" + widget.userID.toString();

    return await http.get(
      urlMod, 
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
    ).then((response){
        if(response.statusCode == 200){
          return jsonDecode(response.body);
        }
        else{ 
          print(urlMod + " get email fail");
          //TODO... trigger some visual error
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          (widget.imageUrl == null)
          ? FutureBuilder(
            future: fetchImageData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              //generate the url
              var imageUrl = "";
              if(snapshot.connectionState == ConnectionState.done){
                if(snapshot.data["profile_image_url"] == null){
                  imageUrl = "https://prd-wret.s3-us-west-2.amazonaws.com/assets/palladium/production/s3fs-public/thumbnails/image/Placeholder_person.png";
                }
                else{
                  imageUrl = snapshot.data["profile_image_url"];
                }
              }
              else{
                imageUrl = "https://prd-wret.s3-us-west-2.amazonaws.com/assets/palladium/production/s3fs-public/thumbnails/image/Placeholder_person.png";
              }

              //display
              return new Container(
                height: 40.0,
                width: 40.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: new NetworkImage(
                      imageUrl,
                    ),
                  ),
                ),
              );
            },
          )
          : Container(
            height: 40.0,
            width: 40.0,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                fit: BoxFit.fill,
                image: new NetworkImage(
                  widget.imageUrl,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                (widget.email == null)
                ? FutureBuilder(
                  future: getEmailData(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if(snapshot.connectionState ==ConnectionState.done){
                      return RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: (snapshot.data["email"]).split('@')[0],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: " " + widget.comment,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ]
                        ),
                      );
                    }
                    else{
                      return RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          text: widget.comment,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                  },
                )
                : RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: (widget.email).split('@')[0],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: " " + widget.comment,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ]
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "posted on " + widget.timeStamp, 
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