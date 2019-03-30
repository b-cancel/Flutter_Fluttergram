import 'package:flutter/material.dart';
import 'package:fluttergram/home.dart';
import 'package:fluttergram/newOrEdit.dart';
import 'package:fluttergram/profile.dart';

import 'package:outline_material_icons/outline_material_icons.dart';

class BottomNav extends StatelessWidget {
  final Data appData;
  final int selectedMenuItem;

  BottomNav({
    @required this.appData,
    @required this.selectedMenuItem,
  });

  @override
  Widget build(BuildContext context) {
    print("hero rebuild");

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Hero(
        tag: 'bottomNav',
        //NOTE: this material widget is required so during our transition to another page we dont get an error
        //even if every page technically has a material ancestor because of the scaffold
        //also also technically doesnt while its transition to the other page
        child: Material(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
            ),
            child: new Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              //NOTE: you CANT have this set to stretch
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                MenuItem(
                  appData: appData,
                  thisMenuItem: 0,
                  selectedMenuItem: selectedMenuItem,
                  menuIcon: (selectedMenuItem == 0) ? Icons.home : OMIcons.home,
                ),
                MenuItem(
                  appData: appData,
                  thisMenuItem: 1,
                  selectedMenuItem: selectedMenuItem,
                  menuIcon: (selectedMenuItem == 1) ? Icons.add_box : OMIcons.addBox,
                ),
                MenuItem(
                  appData: appData,
                  thisMenuItem: 2,
                  selectedMenuItem: selectedMenuItem,
                  menuIcon: (selectedMenuItem == 2) ? Icons.account_box : OMIcons.accountBox,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final Data appData;
  final int thisMenuItem;
  final int selectedMenuItem;
  final IconData menuIcon;

  const MenuItem({
    this.appData,
    this.thisMenuItem,
    this.selectedMenuItem,
    this.menuIcon,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: (){
        if(thisMenuItem != selectedMenuItem){
          print("navigating to new page");
          Navigator.push(
            context,
            MaterialPageRoute(
              //NOTE: this MUST be like this
              builder: (context) => navFunc(appData, thisMenuItem),
            ),
          );
        }
        else{
          print("refreshing current page");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              //NOTE: this MUST be like this
              builder: (context) => navFunc(appData, thisMenuItem),
            ),
          );
        }
      },
      icon: Icon(menuIcon),
    );
  }
}

Widget navFunc(Data appData, int thisMenuItem){
  switch(thisMenuItem){
    case 0:
      //selectedMenuItem always 0
      return Home(appData: appData); 
    break;
    case 1:
      //selectedMenuItem always 1
      return NewOrEditPost(appData: appData, isNew: true);
    break;
    default:
      //selectedMenuItem FROM HERE is always 2
      return Profile(
        email: "", //it will be read in soon
        appData: modForUser(appData, appData.currentUserID),
        selectedMenuItem: 2,
      );
    break;
  }
}

class Data {
  String url = "https://serene-beach-48273.herokuapp.com";
  String token = "";
  int currentUserID;
  int whoOwnsPostsID;
}

Data modForUser(Data appData, int id){
  appData.whoOwnsPostsID = id;
  return appData;
}

Data modForAllPosts(Data appData){
  appData.whoOwnsPostsID = -1; //the secret code for all posts
  return appData;
}

void goToUserProfile(BuildContext context, Data appData, int profileUserID, String profileUserEmail, int selectedMenuItem, {bool reload}){
  if(reload){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          email: profileUserEmail,
          appData: modForUser(appData, profileUserID),
          selectedMenuItem: selectedMenuItem,
        ),
      ),
    );
  }
  else{
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          email: profileUserEmail,
          appData: modForUser(appData, profileUserID),
          selectedMenuItem: selectedMenuItem,
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget trailing;

  TopBar({
    this.leading,
    @required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(45),
      child: Hero(
        tag: 'topBar',
        child: AppBar(
          backgroundColor: new Color(0xfff8faf8),
          elevation: 1.0,
          centerTitle: false,
          leading: (leading != null) ? leading : BackButton(),
          title: title,
          actions: <Widget>[
            (trailing != null) ? trailing : Container(),
          ],
        ),
      ),
    );
  }
}

      /*
      PreferredSize(
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
      */

      /*
      PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          backgroundColor: new Color(0xfff8faf8),
          elevation: 1.0,
          leading: (isEditable) 
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
            offset: Offset((isEditable) ? -60 : 0, 0),
            child: Container(
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: (isEditable)
                    ? EdgeInsets.only(right: 4.0)
                    : EdgeInsets.all(0),
                    child: new Text(
                      (email).split('@')[0],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  (isEditable == false) 
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
      */