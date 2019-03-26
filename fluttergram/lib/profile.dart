//bryan.cancel01@utrgv.edu
//20266067
//CHUNK OF CODE TAKEN FROM:
//https://slcoderlk.blogspot.com/2019/01/beautiful-user-profile-material-ui-with.html

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:fluttergram/main.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; 
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
    print("getting data");

    //retreive data from server
    var urlMod = widget.appData.url + "/api/v1/my_account";

    return await http.get(
      urlMod, 
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
    ).then((response){
        if(response.statusCode == 200){ 
          return jsonDecode(response.body);
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
            appData: widget.appData,
            email: snapshot.data["email"],
            bio: snapshot.data["bio"],
            imageUrl: snapshot.data["profile_image_url"],
            spawnTime:snapshot.data["created_at"],
          );
        }
        else{
          return CircularProgressIndicator();
        }
      },
    );
  }
}

//-------------------------VISUAL DATA DISPLAY-------------------------

class UserProfilePage extends StatefulWidget {
  final Data appData;
  final String email;
  final String imageUrl;
  final String bio;
  final String spawnTime;

  UserProfilePage({
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

    bioNode.addListener((){
      editing.value = bioNode.hasFocus;
    });

    bioController.text = widget.bio;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          backgroundColor: new Color(0xfff8faf8),
          elevation: 1.0,
          leading: Container(),
          centerTitle: false,
          title: Transform.translate(
            offset: Offset(-60, 0),
            child: Container(
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: new Text(
                      (widget.email).split('@')[0],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  new Icon(
                    FontAwesomeIcons.chevronDown,
                    size: 8,
                  ),
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
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        height: 100,
                        width: 100,
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
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          new ProfileData(
                            posts: 12,
                            comments: 35,
                            likes: 1283,
                          ),
                          Padding(
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
                Container(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0),
                  child: TextFormField(
                    focusNode: bioNode,
                    controller: bioController,
                    style: bioTextStyle,
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
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

  void editDoneButtonFunction(){
    //save our value
    if(bioNode.hasFocus) updateBio();

    print("has focus? " + bioNode.hasFocus.toString());

    //focus on the right thing
    var nodeToFocus;
    if(bioNode.hasFocus) nodeToFocus = new FocusNode();
    else nodeToFocus = bioNode;
    FocusScope.of(context).requestFocus(nodeToFocus);
  }
}

class ProfileData extends StatelessWidget {
  final int posts;
  final int comments;
  final int likes;

  const ProfileData({
    this.posts,
    this.comments,
    this.likes,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, right: 16),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Stat(number: posts.toString(), text: "Posts"),
          Stat(number: comments.toString(), text: "Comments"),
          Stat(number: likes.toString(), text: "Likes"),
        ],
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