import 'dart:async';
import 'package:dhatnoon/constants.dart';
import 'package:dhatnoon/navigationpage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

class AudioPage extends StatefulWidget {
  final String channelName;
  final String token;
  final String rtmToken;

  const AudioPage({
    Key? key,
    required this.channelName,
    required this.token,
    required this.rtmToken,
  }) : super(key: key);

  @override
  _AudioPageState createState() =>
      _AudioPageState(this.channelName, this.token, this.rtmToken);
}

class _AudioPageState extends State<AudioPage> {
  final String channelName;
  final String token;
  final String rtmToken;
  _AudioPageState(this.channelName, this.token, this.rtmToken);

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
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        drawer: NavPage(),
        appBar: AppBar(
          leading: InkWell(
            customBorder: new RoundedRectangleBorder(),
            onTap: () => _scaffoldKey.currentState!.openDrawer(),
            splashColor: login_bg_light,
            child: new Icon(
              Icons.menu,
              size: 24,
              color: login_bg,
            ),
          ),
          backgroundColor: Colors.white,
          title: Text("Audio Feed", style: TextStyle(color: login_bg)),
          elevation: 0,
        ),
        body: Center(
          child: Icon(Icons.speaker_group_outlined),
        )
        // Stack(
        //   children: <Widget>[
        //     _viewRows(),
        //   ],
        // ),
        );
  }

  //Functions

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
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(AGORA_APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    if (isBroadcaster) {
      await _engine.setClientRole(ClientRole.Broadcaster);
    } else {
      await _engine.setClientRole(ClientRole.Audience);
    }
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

  //End Function
}
