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

class PostList extends StatefulWidget {
  final Data appData;

  PostList({
    Key key,
    this.appData,
  }) : super(key: key);

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
    final AsyncMemoizer _memoizer = AsyncMemoizer();

  fetchData() {
    return this._memoizer.runOnce(() async {
      return await getData();
    });
  }

  Future getData() async{
    //retreive data from server
    var urlMod = widget.appData.url;
    if(widget.appData.whoOwnsPostsID == -1) urlMod += "/api/v1/posts";
    else urlMod += "/api/v1/users/" + widget.appData.whoOwnsPostsID.toString() + "/posts";

    print("loading the posts for " + widget.appData.whoOwnsPostsID.toString());

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
    return FutureBuilder(
      future: fetchData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.done){
          List list = snapshot.data;
          return ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) => Post(
              appData: widget.appData,
              postID: list[index]["id"],
              caption: list[index]["caption"],
              imageUrl: list[index]["image_url"],
              timeStamp: list[index]["created_at"],
              postOwnerID: list[index]["user_id"],
              likeCount: list[index]["likes_count"],
              commentCount: list[index]["comments_count"],
              postOwnerEmail: list[index]["user_email"],
              postOwnerImageUrl: list[index]["user_profile_image_url"],
              likedByYou: list[index]["liked"],
            ),
          );
        }
        else{
          var size = MediaQuery.of(context).size.width;
          return Container(
            height: size,
            width: size,
            padding: EdgeInsets.all(32),
            alignment: Alignment.topCenter,
            child: Container(
              height: size/2,
              width: size/2,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class Post extends StatelessWidget {
  final showOptions = false;
  final showComent = false;
  final showShare = false;
  final showBookmark = false;

  final Data appData;
  final int postID;
  final String caption;
  final String imageUrl;
  final String timeStamp;
  final int postOwnerID;
  final int likeCount;
  final int commentCount;
  final String postOwnerEmail;
  final String postOwnerImageUrl;
  final bool likedByYou;
  Post({
    this.appData, //used to determine if we should have links to the other users
    this.postID,
    this.caption, //used to show the caption
    this.imageUrl, //used to show the image
    this.timeStamp, //used to indicate when the post was posted
    this.postOwnerID, //used to go to this users other posts
    this.likeCount, //display count of likes
    this.commentCount, //display count of comments
    this.postOwnerEmail, //diplays in front of the caption
    this.postOwnerImageUrl, //used to know who owns the post
    this.likedByYou
  });

  Data modForUser(appData, id){
    appData.whoOwnsPostsID = id;
    return appData;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var extractedEmail = (postOwnerEmail).split('@')[0];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              buildClickOrNoClick(context),
              (showOptions)
              ? Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                child: new IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: null,
                ),
              )
              : Container()
            ],
          ),
        ),
        GestureDetector(
          onDoubleTap: () => like(postID, true),
          child: Container(
            height: size,
            width: size,
            child: new Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => like(!likedByYou, postID),
                    child: (likedByYou)
                      ? new Icon(
                        FontAwesomeIcons.solidHeart,
                        color: Colors.red,
                      )
                      : new Icon(
                        FontAwesomeIcons.heart,
                      ),
                  ),
                  Row(
                    children: <Widget>[
                      new SizedBox(
                        width: 16.0,
                      ),
                      GestureDetector(
                        onTap: () => goToComments(postID),
                        child: new Icon(
                          FontAwesomeIcons.comment,
                        ),
                      ),
                    ],
                  ),
                  (showShare)
                  ? Row(
                    children: <Widget>[
                      new SizedBox(
                        width: 16.0,
                      ),
                      new Icon(
                        FontAwesomeIcons.paperPlane,
                      ),
                    ],
                  )
                  : Container(),
                ],
              ),
              (showBookmark)
              ? new Icon(
                FontAwesomeIcons.bookmark,
              )
              : Container(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Text(
            likeCount.toString() + ((likeCount == 1) ? " like" : " likes"), 
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: extractedEmail,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: " " + caption,
                  style: TextStyle(color: Colors.grey),
                ),
              ]
            ),
          ),
        ),
        (commentCount == 0 || commentCount == null)
        ? Container()
        : GestureDetector(
          onTap: () => goToComments(postID),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              "View all " + commentCount.toString() + ((commentCount == 1) ? " comment" : " comments"), 
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "posted on " + timeStamp.toString(), 
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Container(
          height: 16,
          child: Container(),
        ),
      ],
    );
  }

  void like(postID, doWeLike){
    print("post " + postID.toString() + " will now be liked is " + doWeLike.toString());
  }

  void goToComments(postID){
    print("going to comments for " + postID.toString());
  }

  Widget buildClickOrNoClick(BuildContext context) {
    if(appData.whoOwnsPostsID == postOwnerID){
      return ProfileLink(
        postOwnerImageUrl: postOwnerImageUrl, 
        postOwnerEmail: postOwnerEmail,
      );
    }
    else{
      return GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profile(
                appData: modForUser(appData, postOwnerID),
              ),
            ),
          );
        },
        child: new ProfileLink(
          postOwnerImageUrl: postOwnerImageUrl, 
          postOwnerEmail: postOwnerEmail,
        ),
      );
    }
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
                      "https://pbs.twimg.com/profile_images/916384996092448768/PF1TSFOE_400x400.jpg")),
            ),
          ),
          new SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: new TextField(
              decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: "Add a comment...",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileLink extends StatelessWidget {
  const ProfileLink({
    Key key,
    @required this.postOwnerImageUrl,
    @required this.postOwnerEmail,
  }) : super(key: key);

  final String postOwnerImageUrl;
  final String postOwnerEmail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          new Container(
            height: 40.0,
            width: 40.0,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                fit: BoxFit.fill,
                image: new NetworkImage(
                  postOwnerImageUrl,
                ),
              ),
            ),
          ),
          new SizedBox(
            width: 10.0,
          ),
          new Text(
            (postOwnerEmail).split('@')[0],
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}