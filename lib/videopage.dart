import 'dart:async';
import 'package:dhatnoon/Mainpage/Design/utils/theme.dart';
import 'package:dhatnoon/constants.dart';
import 'package:dhatnoon/navigationpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'dart:convert';

class VideoPage extends StatefulWidget {
  final String channelName;
  final String token;
  final String rtmToken;
  final String option;
  final bool sec10;

  const VideoPage({
    Key? key,
    required this.channelName,
    required this.token,
    required this.rtmToken,
    required this.option,
    required this.sec10,
  }) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState(
      this.channelName, this.token, this.rtmToken, this.option, this.sec10);
}

class _VideoPageState extends State<VideoPage> {
  final String channelName;
  final String token;
  final String rtmToken;
  final String option;
  final bool sec10;
  _VideoPageState(
      this.channelName, this.token, this.rtmToken, this.option, this.sec10);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _users = <int>[];
  final _infoStrings = <String>[];
  late RtcEngine _engine;
  bool muted = false;
  bool isBroadcaster = false;

  @override
  void dispose() {
    _users.clear();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initialize();
    sec10timer();
  }

  sec10timer() {
    if (sec10) {
      Timer(Duration(seconds: 10), () async {
        _stopStream10();
      });
    }
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: sec10 ? _stopStream10 : _stopStream,
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        drawer: NavPage(),
        appBar: AppBar(
          leading: InkWell(
            customBorder: new RoundedRectangleBorder(),
            onTap: () => _scaffoldKey.currentState!.openDrawer(),
            // splashColor: login_bg_light,
            child: new Icon(
              Icons.menu,
              size: 24,
              color: Styles.darkblueColor,
            ),
          ),
          backgroundColor: Colors.white,
          title: Text("Video Feed", style: TextStyle(color: Styles.blackColor)),
          elevation: 0,
        ),
        body: Stack(
          children: <Widget>[
            _viewRows(),
          ],
        ),
      ),
    );
  }

  //Functions

//Stop stream
  Future<bool> _stopStream() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var user_id = sharedPreferences.getString('approved_user_id');
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    Map<String, dynamic> data = {
      "user_id": user_id.toString(),
    };

    var response;

    if (option == 'front') {
      response = await http.post(Uri.parse(url + '/stop_user_frontstream'),
          body: data, headers: headers);
    } else {
      response = await http.post(Uri.parse(url + '/stop_user_rearstream'),
          body: data, headers: headers);
    }
    var jsonData = jsonDecode(response.body);
    print(jsonData);
    if (response.statusCode == 200) {
      snackBar(jsonData['message']);
      setState(() {
        _users.clear();
        _engine.destroy();
        Navigator.of(context).pop(true);
      });
    } else {
      snackBar(jsonData['message']);
    }
    return true;
  }

  Future<bool> _stopStream10() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var user_id = sharedPreferences.getString('approved_user_id');
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    Map<String, dynamic> data = {
      "user_id": user_id.toString(),
    };

    var response;

    if (option == 'front') {
      response = await http.post(Uri.parse(url + '/stop_user_frontstream10'),
          body: data, headers: headers);
    } else {
      response = await http.post(Uri.parse(url + '/stop_user_rearstream10'),
          body: data, headers: headers);
    }
    var jsonData = jsonDecode(response.body);
    print(jsonData);
    if (response.statusCode == 200) {
      snackBar(jsonData['message']);
      setState(() {
        _users.clear();
        _engine.destroy();
        Navigator.of(context).pop(true);
      });
    } else {
      snackBar(jsonData['message']);
    }
    return true;
  }

  Future<void> initialize() async {
    print('Client Role: $isBroadcaster');
    if (AGORA_APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.joinChannel(token, this.channelName, null, 0);
    _engine.muteLocalAudioStream(true);
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(AGORA_APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Audience);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
        });
      },
      userOffline: (uid, elapsed) {
        setState(() {
          final info = 'userOffline: $uid';
          _infoStrings.add(info);
          _users.remove(uid);
        });
      },
    ));
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (isBroadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  snackBar(string) {
    final snackBar = SnackBar(content: Text(string));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //End Function
}
