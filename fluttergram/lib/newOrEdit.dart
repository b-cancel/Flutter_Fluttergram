import 'package:flutter/material.dart';
import 'package:fluttergram/shared.dart';

class NewOrEditPost extends StatefulWidget {
  final Data appData;
  final bool isNew;

  NewOrEditPost({
    this.appData,
    this.isNew,
  });
  
  _NewOrEditPostState createState() => _NewOrEditPostState();
}

class _NewOrEditPostState extends State<NewOrEditPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        //The TopBar Widget will handel the size
        preferredSize: Size.fromHeight(45),
        child: TopBar(
          leading: (widget.isNew) ? BackButton() : CloseButton(),
          title: new Text((widget.isNew) ? "New Post" : "Edit Info"),
          trailing: (widget.isNew)
          ? new FlatButton(
            onPressed: () => print("finishing share"),
            child: new Text(
              "Share",
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          )
          : new IconButton(
            onPressed: () => print("finishing edit"),
            icon: Icon(
              Icons.check,
              color: Colors.blue
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Center(
              child: Container(
               child: new Text("New Post"),
            ),
          ),
          BottomNav(
            appData: widget.appData,
            selectedMenuItem: 1,
          ),
        ],
      ),
    );
  }
}