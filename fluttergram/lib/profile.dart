//bryan.cancel01@utrgv.edu
//20266067
//CHUNK OF CODE TAKEN FROM:
//https://slcoderlk.blogspot.com/2019/01/beautiful-user-profile-material-ui-with.html

import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:fluttergram/main.dart';
import 'package:fluttergram/postList.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Dio dio = new Dio();

class Profile extends StatefulWidget {
  final Data appData;

  Profile({
    Key key,
    this.appData,
  }) : super(key: key);

  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  fetchData() {
    return this._memoizer.runOnce(() async {
      return await getData();
    });
  }

  Future getData() async{
    //retreive data from server
    var urlMod = widget.appData.url + "/api/v1/users/" + widget.appData.whoOwnsPostsID.toString();

    var oldOwner = widget.appData.whoOwnsPostsID;

    return await http.get(
      urlMod, 
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
    ).then((response){
      //restore old owner
      widget.appData.whoOwnsPostsID = oldOwner;

      //process data
      if(response.statusCode == 200){ 
        return jsonDecode(response.body);
        //TODO... get the count of user posts... user likes... and user comments
      }
      else{ 
        print(urlMod + " get profile fail");
        //TODO... trigger some visual error
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //show loading in the meantime
    return FutureBuilder(
      future: fetchData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.done){
          return UserProfilePage(
            //we only edit our own page
            editable: (widget.appData.whoOwnsPostsID == widget.appData.currentUserID),
            appData: widget.appData,
            email: snapshot.data["email"],
            bio: snapshot.data["bio"],
            imageUrl: snapshot.data["profile_image_url"],
            spawnTime: snapshot.data["created_at"],
          );
        }
        else return CustomLoading();
      },
    );
  }
}

//-------------------------VISUAL DATA DISPLAY-------------------------

class UserProfilePage extends StatefulWidget {
  final bool editable;
  final Data appData;
  final String email;
  final String imageUrl;
  final String bio;
  final String spawnTime;

  UserProfilePage({
    this.editable,
    this.appData,
    this.email,
    this.imageUrl,
    this.bio,
    this.spawnTime,
  });

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  ValueNotifier<String> imageUrl;
  ValueNotifier<bool> expandedField;

  TextStyle bioTextStyle = TextStyle(
    fontFamily: 'Spectral',
    fontWeight: FontWeight.w400,//try changing weight to w500 if not thin
    fontStyle: FontStyle.italic,
    color: Color(0xFF799497),
    fontSize: 16.0,
  );

  @override
  void initState(){
    imageUrl = new ValueNotifier(widget.imageUrl);
    expandedField = new ValueNotifier(false);

    bioNode.addListener((){
      bioNodeChange();
    });

    //set the initial value of our text field
    bioController.text = widget.bio;

    super.initState();
  }

  Future<Null> refresh() {
    Completer<Null> completer = new Completer<Null>();
    new Timer(new Duration(seconds: 3), () {
      completer.complete();
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          backgroundColor: new Color(0xfff8faf8),
          elevation: 1.0,
          leading: (widget.editable) 
          ? Container() 
          : IconButton(
            icon: const BackButtonIcon(),
            color: Colors.black,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              Navigator.maybePop(context).then((value){
              });
            }
          ),
          centerTitle: false,
          title: Transform.translate(
            offset: Offset((widget.editable) ? -60 : 0, 0),
            child: Container(
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: (widget.editable)
                    ? EdgeInsets.only(right: 4.0)
                    : EdgeInsets.all(0),
                    child: new Text(
                      (widget.email).split('@')[0],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  (widget.editable == false) 
                  ? Container()
                  : new Icon(
                    FontAwesomeIcons.chevronDown,
                    size: 8,
                  ) ,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        height: (widget.editable) ? 100 : 75,
                        width: (widget.editable) ? 100 : 75,
                        child: Stack(
                          children: <Widget>[
                            AnimatedBuilder(
                              animation: imageUrl,
                              builder: (context, child){
                                return Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: new NetworkImage(imageUrl.value),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(100.0),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                );
                              },
                            ),
                            (widget.editable == false) 
                            ? Container()
                            : new Stack(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(80.0),
                                      color: Colors.blue,
                                      border: Border.all(
                                        color: Colors.blue,
                                        width: 4.0,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                FlatButton(
                                  shape: CircleBorder(),
                                  onPressed: () => imagePicker(),
                                  child: Container(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          new ProfileData(
                            appData: widget.appData,
                            userID: widget.appData.whoOwnsPostsID,
                            posts: 12,
                            comments: 35,
                            likes: 1283,
                          ),
                          (widget.editable == false)
                          ? Container()
                          : Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: AnimatedBuilder(
                              animation: editing,
                              builder: (BuildContext context, Widget child) {
                                return editDoneButton();
                              },
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                AnimatedBuilder(
                  animation: expandedField,
                  builder: (BuildContext context, Widget child) {
                    return Column(
                      children: <Widget>[
                        ClipRect(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: TextFormField(
                              focusNode: bioNode,
                              controller: bioController,
                              style: bioTextStyle,
                              maxLines: (expandedField.value) ? 7 : 1,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap:  () => fieldSizeToggle(),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: EdgeInsets.only(right: 16),
                            alignment: Alignment.bottomRight,
                            child: new Text(
                              (expandedField.value) ? "Show Less" : "Show More",
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                PostList(
                  appData: widget.appData,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //-------------------------IMAGE UPDATE CODE-------------------------

  void imagePicker(){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          contentPadding: EdgeInsets.all(8),
          content: new Row(
            children: <Widget>[
              bigIcon(true, Icons.camera_alt),
              bigIcon(false, FontAwesomeIcons.images),
            ],
          ),
        );
      }
    );
  }

  Widget bigIcon(bool fromCamera, dynamic icon){
    return Expanded(
      child: GestureDetector(
        onTap: () => changeImage(fromCamera),
        child: FittedBox(
          fit: BoxFit.fill,
          child: Container(
            padding: EdgeInsets.only(left: 4, right: 8, top: 4, bottom: 4),
            child: Icon(
              icon,
            ),
          ),
        ),
      ),
    );
  }

  Future changeImage(bool fromCamera) async {
    File image = await ImagePicker.pickImage(
      source: (fromCamera) ? ImageSource.camera : ImageSource.gallery,
    );

    Navigator.of(context).pop();

    var urlMod = widget.appData.url + "/api/v1/my_account/profile_image";

    FormData formData = new FormData.from({
      "token": widget.appData.token,
      "image": new UploadFileInfo(image, "profile.jpeg"),
    });

    var response = await dio.patch(
      urlMod, 
      options: Options(
        method: "PATCH",
        headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token},
      ),
      data: formData,
    );

    if (response.statusCode == 200){
      //retreive data from server
      var urlMod = widget.appData.url + "/api/v1/my_account";
      http.get(
        urlMod, 
        headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
      ).then((response){
          if(response.statusCode == 200){ 
            imageUrl.value = jsonDecode(response.body)["profile_image_url"];
          }
          else{ 
            print(urlMod + " get profile fail");
            //TODO... trigger some visual error
          }
      });
    }
    else print("Not Uploaded! " + response.toString());
  }

  //-------------------------BIO UPDATE CODE-------------------------

  TextEditingController bioController = new TextEditingController();
  ValueNotifier<bool> editing = new ValueNotifier(false);
  FocusNode bioNode = new FocusNode();

  Future updateBio(){
    var urlMod = widget.appData.url + "/api/v1/my_account" + "?bio=" + bioController.text;
    http.patch(
      urlMod, 
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
    ).then((response){
        if(response.statusCode != 200){ 
          print(urlMod + " update bio fail");
          //TODO... trigger some visual error
        }
        else print("update bio pass");
    });
  }

  Widget editDoneButton(){
    if(editing.value){
      return RaisedButton(
        onPressed: () => editDoneButtonFunction(),
        child: new Text("Done"),
      );
    }
    else{
      return OutlineButton(
        onPressed: () => editDoneButtonFunction(),
        child: new Text("Edit Profile"),
      );
    }
  }

  void fieldSizeToggle(){
    expandedField.value = !expandedField.value;
    if(expandedField.value == false){ //Collapsing Field
      if(editing.value){
        editing.value = false;
        updateBio();
      }
      FocusScope.of(context).requestFocus(new FocusNode());
    }
    //ELSE... Expanding Field
    //editing GUARANTEED false
    //focus GUARANTEED false
  }

  void editDoneButtonFunction(){
    editing.value = !editing.value;
    if(editing.value){
      //open the field if needed
      if(expandedField.value == false){
        expandedField.value = true;
      }

      //we should now be editing the field
      FocusScope.of(context).requestFocus(bioNode);
    }
    else{
      //save the value
      updateBio();

      //expanded GUARANTEED to be true

      //we are done editing the field
      FocusScope.of(context).requestFocus(new FocusNode());
    }
  }

  //-------------------------VERY DELICATE SYSTEM START-------------------------
  //NOTE: IF expandedField.value 
  //field may or may not have focus

  //NOTE: Because "SHOW MORE" doesn't change the focus of the edit field 
  //it isnt mentioned below

  //NOTE: IF expandedField.value == false && we don't have focus
  //then its possible "fieldSizeToggle" caused it [CASE 1]

  //NOTE: IF editing.value && expandedField.value = true && we have focus
  //then its possible EDIT BUTTON triggered it [CASE 2]

  //NOTE: If editing.value == false && we don't have focus
  //then its possible DONE BUTTON triggered it [CASE 3]

  //NOTE: If we gain focus but we are not editing
  //then we triggered by someone tapping the field when they should not have [CASE 4]

  //USED BY: only the bio node focus change listener
  void bioNodeChange(){
    if(bioNode.hasFocus == false){
      //WE LOST FOCUS
      if(expandedField.value){ 
        //[CASE 3] (focus lost & editing false) [expanded GUARANTEED to be true]
        if(editing.value){
          //ERROR: we NEED gain focus for editing TRUE
          print("---ERROR: We lost focus => expanded TRUE & editing TRUE");
        }
        else{
          //VALUE SAVED (guaranteed)
          print("DONE PRESS: We lost focus => expanded TRUE & editing FALSE");

          //OR this could have been triggerd by TOGGLE TAP starting with
          //lost focus, expanding EITHER, editing false
        }
      }
      else{ 
        //[CASE 1] (focus lost & expanded false)
        if(editing.value){
          //ERROR: editing TRUE would trigger expanded TRUE (so it being possible should not happen)
          print("---ERROR: We lost focus => expanded FALSE & editing TRUE"); 
        }
        else{
          //VALUE SAVED (if editing before)
          print("SHOW LESS: We lost focus => expanded FALSE & editing FALSE");

          //OR this could have been triggerd by TOGGLE TAP starting with
          //lost focus, expanding EITHER, editing false
        }
      }
    }
    else{
      //WE GAINED FOCUS 

      //2. Tapping on the field (which should be processed as a tap in all cases except)
      //  a. when editing = true

      if(editing.value){
        //[CASE 2] (focus gained & expanded true & editing true)
        if(expandedField.value){
          print("EDIT BUTTON: We gained focus => expanded TRUE & editing TRUE");
        }
        else{
          print("---ERROR: We gained focus => expanded FALSE & editing TRUE");
        }
      }
      else{
        //[CASE 4] (focus gained & editing false)
        print("TOGGLE TAP: We gained focus => expanded " 
        + expandedField.value.toString().toUpperCase() 
        + " editing false");

        //we want to toggle
        expandedField.value = !expandedField.value;
        
        //we want to process this as a tap
        FocusScope.of(context).requestFocus(new FocusNode());
      }
    }
  }

  //-------------------------VERY DELICATE SYSTEM END-------------------------
}

class ProfileData extends StatefulWidget {
  final Data appData;
  final int userID;
  final int posts;
  final int comments;
  final int likes;

  const ProfileData({
    @required this.appData,
    @required this.userID,
    this.posts,
    this.comments,
    this.likes,
    Key key,
  }) : super(key: key);

  @override
  _ProfileDataState createState() => _ProfileDataState();
}

class _ProfileDataState extends State<ProfileData> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  fetchData() {
    return this._memoizer.runOnce(() async {
      return await getData();
    });
  }

  Future getData() async{
    //get all the posts
    var urlMod = widget.appData.url + "/api/v1/posts";

    return await http.get(
      urlMod, 
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
    ).then((response) async{
        if(response.statusCode == 200){
          return await processPosts(jsonDecode(response.body));
        }
        else{ 
          print(urlMod + " get posts fail");
          //TODO... trigger some visual error
        }
    });
  }

  ValueNotifier<int> postCount = new ValueNotifier(0);
  ValueNotifier<int> commentCount = new ValueNotifier(0);
  ValueNotifier<int> likeCount = new ValueNotifier(0);

  Future processPosts(posts) async{
    List list = posts;
    for(int postID = 0; postID < list.length; postID+=1){
      //update postCount
      if(list[postID]["user_id"] == widget.userID){
        postCount.value += 1;
      }

      //get all comments from this userID from this particular post
      commentCount.value += await getComments(list[postID]["id"]);

      //get all the likes from this userID from this particular post
      likeCount.value += await getLikes(list[postID]["id"]);
    }

    //return so this thing stop running
    return "";
  }

  Future getComments(thisPostID) async{
    var urlMod = widget.appData.url + "/api/v1/posts/" + thisPostID.toString() + "/comments";

    return await http.get(
      urlMod, 
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
    ).then((response) async{
        if(response.statusCode == 200){
          List comments = jsonDecode(response.body);
          int commentCount = 0;
          for(int commentID = 0; commentID < comments.length; commentID += 1){
            if(comments[commentID]["user_id"] == widget.userID){
              commentCount += 1;
            }
          }
          return commentCount;
        }
        else{ 
          print(urlMod + " get comments fail");
          //TODO... trigger some visual error
        }
    });
  }

  Future getLikes(thisPostID) async{
    var urlMod = widget.appData.url + "/api/v1/posts/" + thisPostID.toString() + "/likes";

    return await http.get(
      urlMod, 
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
    ).then((response) async{
        if(response.statusCode == 200){
          List likes = jsonDecode(response.body);
          int likesCount = 0;
          for(int likeID = 0; likeID < likes.length; likeID += 1){
            if(likes[likeID]["user_id"] == widget.userID){
              likesCount += 1;
            }
          }
          return likesCount;
        }
        else{ 
          print(urlMod + " get like fail");
          //TODO... trigger some visual error
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, right: 16),
      child: FutureBuilder(
        future: fetchData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //NOTE: using animated builders here updates the values as they are updated by the server
          return AnimatedBuilder(
            animation: postCount,
            builder: (BuildContext context, Widget child) {
              return AnimatedBuilder(
                animation: commentCount,
                builder: (BuildContext context, Widget child) {
                  return AnimatedBuilder(
                    animation: likeCount,
                    builder: (BuildContext context, Widget child) {
                      return new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Stat(number: postCount.value.toString(), text: "Posts"),
                          Stat(number: commentCount.value.toString(), text: "Comments"),
                          Stat(number: likeCount.value.toString(), text: "Likes"),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class Stat extends StatelessWidget {
  final String number;
  final String text;

  const Stat({
    this.number,
    this.text,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: new Column(
        children: <Widget>[
          new Text(
            number,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          new Text(
            text,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}