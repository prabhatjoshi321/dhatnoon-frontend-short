// import 'dart:ffi';
import 'package:dhatnoon/navigationpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'navigationpage.dart';

class CameraPage extends StatefulWidget {
  final String videourl;
  const CameraPage({Key? key, required this.videourl}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState(this.videourl);
}

class _CameraPageState extends State<CameraPage> {
  final String videourl;
  _CameraPageState(this.videourl);
  late Size _size;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final double? playerWidth = 640;
  final double? playerHeight = 360;

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: NavPage(),
      appBar: AppBar(
        leading: InkWell(
          customBorder: new RoundedRectangleBorder(),
          onTap: () =>
              {setState(() {}), _scaffoldKey.currentState!.openDrawer()},
          splashColor: login_bg_light,
          child: new Icon(
            Icons.menu,
            size: 24,
            color: login_bg,
          ),
        ),
        backgroundColor: Colors.white,
        title: Text("Live Camera View", style: TextStyle(color: login_bg)),
        elevation: 0,
        actions: [
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    // setState(() {
                    //   Navigator.of(context).push(MaterialPageRoute(
                    //       builder: (context) => CameraPage()));
                    // });
                  },
                  child: Icon(Icons.camera_front)),
              // TextButton(
              //     onPressed: () {
              //       _lensSelectSender('rear');
              //     },
              //     child: Icon(Icons.camera_rear_outlined)),
            ],
          ),
        ],
      ),
      body: Center(
        child: Container(
          child: new VlcPlayer(
            aspectRatio: 16 / 9,
            controller: new VlcPlayerController.network(videourl),
            placeholder: Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
      // bottomNavigationBar: bottomNav(),
    );
  }
}
