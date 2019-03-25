import 'package:flutter/material.dart';
import 'posts.dart';
import 'profile.dart';
import 'new.dart';

class Home extends StatefulWidget {
  final Widget child;
  Home({Key key, this.child}) : super(key: key);
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final _widgetOptions = [
    Posts(),
    Profile(),
    NewPost(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text("Fluttergram"),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _selectedIndex,
        fixedColor: Colors.deepPurple,
        onTap: _onItemTapped,
        items: [
         new BottomNavigationBarItem(
           icon: Icon(Icons.home),
           title: new Text("Posts"),
         ),
         new BottomNavigationBarItem(
           icon: Icon(Icons.add_box),
           title: new Text("New Post"),
         ),
         new BottomNavigationBarItem(
           icon: Icon(Icons.person),
           title: new Text("Profile")
         )
       ],
     ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}