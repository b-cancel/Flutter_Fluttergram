import 'package:flutter/material.dart';
import 'package:fluttergram/home.dart';
import 'package:fluttergram/new.dart';
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
                  active: (selectedMenuItem != 0),
                  selectedMenuItem: selectedMenuItem,
                  menuIcon: (selectedMenuItem == 0) ? Icons.home : OMIcons.home,
                ),
                MenuItem(
                  appData: appData,
                  active: (selectedMenuItem != 1),
                  selectedMenuItem: selectedMenuItem,
                  menuIcon: (selectedMenuItem == 1) ? Icons.add_box : OMIcons.addBox,
                ),
                MenuItem(
                  appData: appData,
                  active: (selectedMenuItem != 2),
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
  final bool active;
  final int selectedMenuItem;
  final IconData menuIcon;

  const MenuItem({
    this.appData,
    this.active,
    this.selectedMenuItem,
    this.menuIcon,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: (){
        if(active){
          print("navigating");
          Navigator.push(
            context,
            MaterialPageRoute(
              //NOTE: this MUST be like this
              builder: (context) => navFunc(appData, active, selectedMenuItem),
            ),
          );
        }
        else print("We Are Already There");
      },
      icon: Icon(menuIcon),
    );
  }
}

Widget navFunc(appData, active, currentIndex){
  if(active && currentIndex != 0){
    return Home(
      appData: appData,
    );
  }
  else if(active && currentIndex != 1){
    return NewPost(
      appData: appData,
    );
  }
  else{ //(active && currentIndex != 2)
    return Profile(
      appData: modForUser(appData, currentIndex),
      selectedMenuItem: currentIndex,
    );
  }
}

class Data {
  String url = "https://serene-beach-48273.herokuapp.com";
  String token = "";
  int currentUserID;
  int whoOwnsPostsID;
}

Data modForUser(appData, id){
  appData.whoOwnsPostsID = id;
  return appData;
}

void goToUserProfile(context, appData, profileUserID, selectedMenuItem){
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        appData: modForUser(appData, profileUserID),
        selectedMenuItem: selectedMenuItem,
      ),
    ),
  );
}

Data modForAllPosts(appData){
  appData.whoOwnsPostsID = -1; //the secret code for all posts
  return appData;
}