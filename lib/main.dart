

import 'dart:io';
import 'services/audio.dart';

import 'routes/main-menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(ChessRoadApp());

  //只支持竖屏
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
  );
  //不显示状态栏
  if(Platform.isAndroid){
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }

  SystemChrome.setEnabledSystemUIOverlays([]);
}

class ChessRoadApp extends StatefulWidget{

  static const StatusBarHeight = 28.0;

  @override
  _ChessRoadAppState createState() => _ChessRoadAppState();
}

class _ChessRoadAppState extends State<ChessRoadApp>{
  @override
  void initState(){
    super.initState();
    //Audios.loopBgm('bg_music.mp3');
    //Player.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'QiTi',
      ),
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          Audios.release();
          return true;
        },
        child: MainMenu(),
      ),
    );
  }

}
