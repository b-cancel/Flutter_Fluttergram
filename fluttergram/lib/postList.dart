import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttergram/comments.dart';
import 'package:fluttergram/main.dart';
import 'package:fluttergram/shared.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dart:convert';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;

//NOTE: the force to refresh here only works for POSTS
//for PROFILE its own refresh indicator will override this one

class PostList extends StatefulWidget {
  final Data appData;
  final int selectedMenuItem;

  PostList({
    Key key,
    this.appData,
    @required this.selectedMenuItem,
  }) : super(key: key);

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  bool forceFetch = false;

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

    return await http.get(
      urlMod, 
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
    ).then((response){
        if(response.statusCode == 200){
          forceFetch = false; //in case this was triggered by it
          return jsonDecode(response.body);
        }
        else{ 
          print(urlMod + " get posts fail");
          //TODO... trigger some visual error
        }
    });
  }

  Future forceReload(){
    forceFetch = true;
    setState(() {});
    return new Future<bool>.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: (forceFetch) ? getData() : fetchData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        print("future running again");
        if(snapshot.connectionState == ConnectionState.done){
          List list = snapshot.data;
          return RefreshIndicator(
            onRefresh: () => forceReload(),
            child: ListView.builder(
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
                startLiked: list[index]["liked"],
                selectedMenuItem: widget.selectedMenuItem,
              ),
            ),
          );
        }
        else return CustomLoading();
      },
    );
  }
}

class Post extends StatefulWidget {
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
  final bool startLiked;
  final int selectedMenuItem;
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
    this.startLiked,
    @required this.selectedMenuItem,
  });

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  final showOptions = false;
  final showShare = false;
  final showBookmark = false;

  bool liked;
  
  @override
  void initState() { 
    super.initState();
    liked = widget.startLiked;
  }

  Widget heartButton(){
    if(liked){
      return Icon(
        FontAwesomeIcons.solidHeart,
        color: Colors.red,
      );
    }
    else{
      return Icon(
        FontAwesomeIcons.heart,
      );
    }
  }

  Widget likeCount(){
    //adjust for client side changes without reloading
    int actualLikes = widget.likeCount;
    if(widget.startLiked != liked){
      if(liked) actualLikes += 1;
      else actualLikes -= 1;
    }

    //display actual likes
    return Text(
      actualLikes.toString() + ((actualLikes == 1) ? " like" : " likes"), 
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;

    void goToComments(){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Comments(
            postID: widget.postID,
            postOwnerImageUrl: widget.postOwnerImageUrl, 
            postOwnerEmail: widget.postOwnerEmail, 
            postOwnerID: widget.postOwnerID,
            postCaption: widget.caption,
            postTimeStamp: widget.timeStamp,
            appData: widget.appData,
            selectedMenuItem: widget.selectedMenuItem,
          ),
        ),
      );
    }

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
              newOrReload(
                context, 
                widget.postOwnerEmail,
                widget.selectedMenuItem, 
                reload: widget.appData.whoOwnsPostsID == widget.postOwnerID,
              ),
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
          onDoubleTap: () => like(widget.postID, true),
          child: Container(
            height: size,
            width: size,
            child: new Image.network(
              widget.imageUrl,
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
                    onTap: () => like(widget.postID, !liked),
                    child: heartButton(),
                  ),
                  Row(
                    children: <Widget>[
                      new SizedBox(
                        width: 16.0,
                      ),
                      GestureDetector(
                        onTap: () => goToComments(),
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
          child: likeCount(),
        ),
        GestureDetector(
          onTap: () => goToComments(),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Container(
                  alignment: Alignment.topLeft,
                  child: RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: (widget.postOwnerEmail).split('@')[0],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: " " + widget.caption,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ]
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                alignment: Alignment.topLeft,
                child: Text(
                  "View " + ((widget.commentCount == 1) ? "1 comment" : widget.commentCount.toString() + " comments"), 
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.topLeft,
                child: Text(
                  "posted on " + widget.timeStamp.toString(), 
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
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
    if(doWeLike){
      //make url
      var urlMod = widget.appData.url + "/api/v1/posts/" + postID.toString() + "/likes";

      //use server
      http.post(
        urlMod, 
        headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
      ).then((response){
        //process data
        if(response.statusCode == 200){ 
          print("liking succeed");
          liked = doWeLike;
          setState(() {
            
          });
          //TODO... get the count of user posts... user likes... and user comments
        }
        else{ 
          print(urlMod + " liking fail");
          //TODO... trigger some visual error
        }
      });
    }
    else{
      //make url
      var urlMod = widget.appData.url + "/api/v1/posts/" + postID.toString() + "/likes";

      //use server
      http.delete(
        urlMod, 
        headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
      ).then((response){
        //process data
        if(response.statusCode == 200){ 
          print("UN liking succeed");
          liked = doWeLike;
          setState(() {
            
          });
          //TODO... get the count of user posts... user likes... and user comments
        }
        else{ 
          print(urlMod + " UN liking fail");
          //TODO... trigger some visual error
        }
      });
    }
  }

  Widget newOrReload(BuildContext context, String email, int selectedMenuItem, {bool reload}) {
    return GestureDetector(
      onTap: () => goToUserProfile(
        context, 
        widget.appData, 
        widget.postOwnerID, 
        email,
        selectedMenuItem, 
        reload: reload,
      ),
      child: new ProfileLink(
        postOwnerImageUrl: widget.postOwnerImageUrl, 
        postOwnerEmail: widget.postOwnerEmail,
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