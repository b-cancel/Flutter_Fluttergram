import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttergram/main.dart';

import 'dart:convert';
import 'package:async/async.dart';
import 'package:fluttergram/shared.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class Comments extends StatefulWidget {
  final Data appData;
  final int postID;
  final String postOwnerImageUrl;
  final String postOwnerEmail;
  final int postOwnerID;
  final String postCaption;
  final String postTimeStamp;
  final int selectedMenuItem;

  Comments({
    Key key,
    this.appData,
    this.postID,
    this.postOwnerImageUrl,
    this.postOwnerEmail,
    @required this.postOwnerID,
    this.postCaption,
    this.postTimeStamp,
    @required this.selectedMenuItem,
  }) : super(key: key);

  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  bool forceFetch = false;

  fetchData() {
    return this._memoizer.runOnce(() async {
      return await getData();
    });
  }

  Future getData() async{
    //turn off force fetch in case we where triggered because of it
    forceFetch = false;
    
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
      ).then((response) async{
          if(response.statusCode == 200){
            //wipe and unfocus the text field
            newCommentText.text = ""; 
            FocusScope.of(context).requestFocus(new FocusNode());

            //get the new file
            Future.delayed(Duration(milliseconds: 250), forceReload);
          }
          else{ 
            print(urlMod + " post comment fail");
            //TODO... trigger some visual error
          }
      });
    }
    //ELSE... we ignore your dumb request
  }

  Future forceReload(){
    forceFetch = true;
    setState(() {});
    return new Future<bool>.value(true);
  }

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
        //The TopBar Widget will handel the size
        preferredSize: Size.fromHeight(45),
        child: TopBar(
          title: new Text("Comments"),
        ),
      ),
      body: Stack(
        children: <Widget>[
          RefreshIndicator(
            onRefresh: () => forceReload(),
            child: ListView(
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
                    userID: widget.postOwnerID,
                    email: widget.postOwnerEmail,
                    comment: widget.postCaption,
                    timeStamp: widget.postTimeStamp,
                    selectedMenuItem: widget.selectedMenuItem,
                    potentiallyEditable: false,
                  ),
                ),
                FutureBuilder(
                  future: (forceFetch) ? getData() : fetchData(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if(snapshot.connectionState == ConnectionState.done){
                      //convert to list so we can actually use it
                      List list = snapshot.data;

                      //update stuff
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: list.length,
                        itemBuilder: (context, index) => PostComment(
                          appData: widget.appData,
                          imageUrl: list[index]["user"]["profile_image_url"],
                          email: list[index]["user"]["email"],
                          userID: list[index]["user_id"],
                          comment: list[index]["text"],
                          timeStamp: list[index]["created_at"],
                          selectedMenuItem: widget.selectedMenuItem,
                          potentiallyEditable: true,
                        ),
                      );
                    }
                    else return CustomLoading();
                  },
                ),
                BottomBarSpacer(),
              ],
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Hero(
              tag: 'bottomNav',
              //NOTE: this material widget is required so during our transition to another page we dont get an error
              //even if every page technically has a material ancestor because of the scaffold
              //also also technically doesnt while its transition to the other page
              child: Material(
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
  final int selectedMenuItem;
  final bool potentiallyEditable;

  const PostComment({
    this.appData, //used to allow edit and delete
    this.userID,
    this.imageUrl,
    this.email,
    this.comment,
    this.timeStamp,
    @required this.selectedMenuItem,
    @required this.potentiallyEditable,
    Key key,
  }) : super(key: key);

  @override
  _PostCommentState createState() => _PostCommentState();
}

class _PostCommentState extends State<PostComment> {
  void goToThisUsersProfile(){
    goToUserProfile(
      context, 
      widget.appData, 
      widget.userID, 
      widget.email,
      widget.selectedMenuItem,
      reload: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () => goToThisUsersProfile(),
            child: Container(
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
          ),
          new SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: (widget.email).split('@')[0],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        recognizer: TapGestureRecognizer()
                        ..onTap = () => goToThisUsersProfile()
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
          (widget.potentiallyEditable 
          && widget.appData.currentUserID == widget.userID)
          ? PopupMenuButton(
            onSelected: (val){
              if(val == "edit"){
                print("editing");
              }
              else{
                print("deleting");
              }
            },
            itemBuilder: (BuildContext context){
              return [
                PopupMenuItem<String>(
                  value: "edit",
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.edit,
                        size: 22,
                      ),
                      Text(" Edit"),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: "delete",
                  child: Row(
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.trashAlt,
                        size: 22,
                      ),
                      Text(" Delete"),
                    ],
                  ),
                ),
              ];
            },
          )
          : Container(),
        ],
      ),
    );
  }
}