
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:http/http.dart' as http;

enum apiCall{posts, postsID, myPosts}

class Ret{
  dynamic value;
}

dynamic callAPI(BuildContext context, String token, apiCall api, Ret ret, {String id: "-1"}){
  String url = "http://sleepy-stream-87265.herokuapp.com/api/v1/";

  Map<String, String> tokenToID = {
    "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.YR_ZJnBK5DLUVuk6-33KsWXYgp4x6GjC1Qro7flAIHE": "1",
    "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyfQ.kL35TGZ3l1B6q41HgHX6afMuahfqbhuBa3Elu-oRG-c": "2",
  };

  //switch case
  if(api == apiCall.posts) url = url + "posts";
  else if(api == apiCall.myPosts) url = url + "posts/" + tokenToID[token]; //TODO... my posts doesn't work
  else url = url + "posts/" + id;

  print("using url " + url);

  http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer " + token}).then((response){
    print("---Authentication Attempt");
    print("url " + url);
    print("status " + response.statusCode.toString());

    //switch case
    if(api == apiCall.posts) _posts(context, token, response, ret);
    else if(api == apiCall.postsID) _postsID(context, token, response, ret);
    else _myPosts(context, token, response, ret);
  });
}

dynamic _posts(BuildContext context, String token, dynamic response, Ret ret){
  print("---getting all posts");
  if(response.statusCode == 200){
    ret.value = jsonDecode(response.body);
  }
  else backToHome(context);
}

dynamic _postsID(BuildContext context, String token, dynamic response, Ret ret){
  print("---getting posts of a particular ID");
  if(response.statusCode == 200){
    ret.value = jsonDecode(response.body);
  }
  else if(response.statusCode == 404) return "Post Not Found"; //TODO... work properly with this
  else backToHome(context);
}

dynamic _myPosts(BuildContext context, String token, dynamic response, Ret ret){
  print("---getting my posts");
  if(response.statusCode == 200){
    ret.value = jsonDecode(response.body);
  }
  else if(response.statusCode == 404) return "Post Not Found"; //TODO... work properly with this
  else backToHome(context);
}

void backToHome(BuildContext context){
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MyApp(),
    ),
  );
}

String getPrettyJSONString(jsonObject){
  var encoder = new JsonEncoder.withIndent("     ");
  return encoder.convert(jsonObject);
}