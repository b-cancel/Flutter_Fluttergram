import 'package:flutter/material.dart';
import 'package:fluttergram/main.dart';

import 'posts.dart';
import 'profile.dart';
import 'new.dart';

class Home extends StatefulWidget {
  final Data appData;
  Home({
    Key key, 
    this.appData,
  }) : super(key: key);
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  Data modForMyPosts(appData){
    appData.whoOwnsPostsID = appData.currentUserID;
    return appData;
  }

  @override
  Widget build(BuildContext context) {
    var _widgetOptions = [
      Posts(
        appData: widget.appData,
      ),
      NewPost(),
      Profile(
        appData: modForMyPosts(widget.appData),
        callback: () => print("call back not needed, NO BACK BUTTON"),
      ),
    ];

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: new Container(
        color: Colors.white,
        height: 45.0,
        alignment: Alignment.center,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            new BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              title: new Text(
                "Home",
                style: TextStyle(
                  fontSize: 0,
                ),
              ),
            ),
            new BottomNavigationBarItem(
              icon: Icon(
                Icons.add_box,
              ),
              title: new Text(
                "New Post",
                style: TextStyle(
                  fontSize: 0,
                ),
              ),
            ),
            new BottomNavigationBarItem(
              icon: Icon(
                Icons.account_box,
              ),
              title: new Text(
                "Profile",
                style: TextStyle(
                  fontSize: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}