import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:camera/camera.dart';
import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:dhatnoon/constants.dart';
import 'package:dhatnoon/locationpage.dart';
import 'package:dhatnoon/locationprovider.dart';
import 'package:dhatnoon/loginpage.dart';
import 'package:dhatnoon/navigationpage.dart';
import 'package:dhatnoon/notification_service.dart';
import 'package:dhatnoon/providers/approved_requests.dart';
import 'package:dhatnoon/providers/request_select.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'Design/res.dart';
import 'Design/utils/DarkThemeProvider.dart';
import 'Design/utils/animators/shake_transition.dart';
import 'Design/utils/theme.dart';
import 'Design/widgets/home_boxes.dart';
import 'Design/widgets/home_main.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background/flutter_background.dart';
import 'dart:async';
//Camera Imports
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

class NewMain extends StatefulWidget {
  @override
  _NewMainState createState() => _NewMainState();
}

class _NewMainState extends State<NewMain> with SingleTickerProviderStateMixin {
  //
  // Home page variables
  //

  late AnimationController animationController;
  var icons = [Res.Fetch, Res.Allow];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  late Animation<double> animation;
  bool cirAn = false;
  bool _switch = false;

  int selectedCard = 0;

  //
  // home page index
  //

  int _currentPage = 0;
  late PageController _pageController;
  late List<Widget> _children;
  String? userName = "";

  //
  // Request Dialog Variable
  //
  // phone number entry form
  TextEditingController userPhnoController = new TextEditingController();
  FocusNode myFocusNode = new FocusNode();

  //first time variable
  String? _time1_hour;
  String? _time1_min;
  String? _time1_ampm;

  //second time variable
  String? _time2_hour;
  String? _time2_min;
  String? _time2_ampm;

  //option selectors
  List<String> _options = [
    'Live Geo Location.',
    'Front Camera Pic.',
    'Back Camera Pic.',
    'Front Camera Streaming.',
    'Back Camera Streaming.',
    'Front Camera 10 Second Video.',
    'Back camera 10 Second Video.',
    'Audio Live Streaming.',
    '10 Second Audio Recording.'
  ];
  String? _selectedOption;
  // List<String> _hour = [for (var i = 1; i <= 12; i++) i.toString()];
  // List<String> _minute = [for (var i = 0; i <= 60; i++) i.toString()];

  List<String> _ampm = ['am', 'pm'];
  List<String> _hour = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12'
  ];
  List<String> _minute = [
    '00',
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44',
    '45',
    '46',
    '47',
    '48',
    '49',
    '50',
    '51',
    '52',
    '53',
    '54',
    '55',
    '56',
    '57',
    '58',
    '59',
    '60'
  ];

  //
  // Requester Variables
  //
  //
  // Image Post feature variable
  // Camera initialise vars
  late CameraController _cameracontroller;
  Future<void>? _initializeControllerFuture;
  bool isCameraReady = false;
  String optionCam = '';
  //
  // Location feature variables
  Position? _currentPosition;

  // pic send vars
  var ImagePath;
  late List<CameraDescription> cameras;

  // Video Stream feature variable
  // camera and initializers
  final _users = <int>[];
  final _infoStrings = <String>[];
  late RtcEngine _engine;
  bool muted = false;
  bool isStreamStart = false;

  // Display demand request variables
  // Requested image view Variables
  String imgUrl = '';

  String videourl = "http://34.131.126.69:8080/hls/mystream.m3u8";

  // requested stream variables
  String channelName = '';
  String token = '';
  String rtmToken = '';
  bool isBroadcaster = true;
  bool isFront = true;

  //
  //
  @override
  void initState() {
    super.initState();

    //
    // functionality controllers
    //
    checkLoginStatus();

    // Location initialise
    Provider.of<LocationProvider>(context, listen: false).initialization();

    // background permission initialise
    initBackgroundPermissions();

    // user name fetcher initialise
    userNameFetcher();

    // 5 second timer for various background tasks
    Timer timer =
        Timer.periodic(Duration(seconds: 3), (Timer t) => requestExecuter());

    //
    // page animation controllers
    //
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );
    animationController.forward();

    _children = [
      HomeMain(
        index: 0,
      ),
      HomeMain(
        index: 1,
      ),
    ];
    _pageController = PageController();
  }

  //
  //login Status checker
  //
  checkLoginStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print(sharedPreferences.getString('token'));
    if (sharedPreferences.getString('token') == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  //
  //  Username fetcher
  //
  userNameFetcher() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userName = sharedPreferences.getString('user_data_phone_number');
    setState(() {});
  }

  //
  //
  //

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);

    var _size = MediaQuery.of(context).size;
    return cirAn
        ? CircularRevealAnimation(
            centerOffset: Offset(_size.width - (Styles.horzPadding + 25),
                80 + MediaQuery.of(context).padding.top),
            animation: animation,
            child: homeBody(
              themeProvider,
            ),
          )
        : homeBody(themeProvider);
  }

  //
  // Main body scaffold
  //

  Widget homeBody(DarkThemeProvider themeProvider) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          drawer: NavPage(),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 25,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: Styles.horzPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShakeTransition(
                        child: Text(
                      "Hi User $userName",
                      style: TextStyle(fontSize: 24),
                    )),
                    TextButton(
                        onPressed: () {
                          _makeRequest();
                        },
                        child: Icon(
                          Icons.send_and_archive_outlined,
                          color: Styles.blackColor,
                        )),
                    TextButton(
                        onPressed: () {
                          setState(() {});
                          _scaffoldKey.currentState!.openDrawer();
                        },
                        child: Icon(
                          Icons.menu_outlined,
                          color: Styles.blackColor,
                        )),
                    // _blackWhite(themeProvider),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              _categories(),
              SizedBox(
                height: 15,
              ),
              Expanded(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: PageView(
                    controller: _pageController,
                    physics: new NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: _children,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).backgroundColor,
        ),
      ),
    );
  }

  _categories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Styles.horzPadding),
      child: SizedBox(
        height: 130,
        width: Get.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
              2,
              (index) => HomeBoxes(
                    gradient: LinearGradient(colors: []),
                    image: icons[index],
                    index: index,
                    darkMode: !_switch,
                    selectedCard: index == selectedCard,
                    onPressed: () {
                      setState(() {
                        selectedCard = index;
                        _pageController.animateToPage(selectedCard,
                            duration: Duration(seconds: 1),
                            curve: Curves.easeInOut);
                      });
                    },
                  )),
        ),
      ),
    );
  }

  //
  // Request Exxecuter
  //

  requestExecuter() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    setState(() {});

    var notif =
        await http.get(Uri.parse(url + '/notif_check'), headers: header);
    var notifData = json.decode(notif.body);
    if (notifData['message'] != 'No Notifications') {
      NotificationService()
          .postNotification("Dhatnoon", notifData['message'], "payload");
    }

    var response =
        await http.get(Uri.parse(url + '/request_check'), headers: header);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      if (jsonData['feature_id'] == 10) {
        if (jsonData['fcam_stream'] == 0) {
          if (jsonData['bcam_stream'] == 0) {
            if (jsonData['fcam10_vid'] == 0) {
              if (jsonData['bcam10_vid'] == 0) {
                if (jsonData['aud_stream'] == 0) {
                  if (jsonData['aud_10sec'] == 0) {
                    if (isStreamStart == true) {
                      videoStreamStop();
                      isStreamStart = false;
                    }
                  }
                }
              }
            }
          }
        }
      } else if (jsonData['feature_id'] == 1) {
        Constants.snackBar(
            "${Constants.capital(jsonData['requester'])}${jsonData['message']}",
            context);
        locationUpdateOnCall();
      } else if (jsonData['feature_id'] == 2) {
        Constants.snackBar(
            "${Constants.capital(jsonData['requester'])}${jsonData['message']}",
            context);
        _getAvailableCameras();
        Timer(Duration(seconds: 1), () {
          if (isCameraReady == true) {
            _lensSelectSender('front');
          }
        });
      } else if (jsonData['feature_id'] == 3) {
        Constants.snackBar(
            "${Constants.capital(jsonData['requester'])}${jsonData['message']}",
            context);
        _getAvailableCameras();
        Timer(Duration(seconds: 1), () {
          if (isCameraReady == true) {
            _lensSelectSender('rear');
          }
        });
      } else if (jsonData['feature_id'] == 4) {
        if (isStreamStart == false) {
          isStreamStart = true;
          Constants.snackBar(
              "${Constants.capital(jsonData['requester'])}${jsonData['message']}",
              context);
          streamTokenGenVideo();
          Timer(Duration(seconds: 2), () {
            _setupVideo();
            if (isFront != true) {
              isFront = true;
              _onSwitchCamera();
            }
            // });
            Timer(Duration(seconds: 3), () {
              postVideo('front');
            });
          });
        }
      } else if (jsonData['feature_id'] == 5) {
        if (isStreamStart == false) {
          isStreamStart = true;
          Constants.snackBar(
              "${Constants.capital(jsonData['requester'])}${jsonData['message']}",
              context);
          streamTokenGenVideo();
          Timer(Duration(seconds: 2), () {
            _setupVideo();
            if (isFront != false) {
              isFront = false;
              _onSwitchCamera();
            }
            Timer(Duration(seconds: 3), () {
              postVideo('rear');
            });
            // });
          });
        }
      } else if (jsonData['feature_id'] == 6) {
        if (isStreamStart == false) {
          isStreamStart = true;
          Constants.snackBar(
              "${Constants.capital(jsonData['requester'])}${jsonData['message']}",
              context);
          streamTokenGenVideo();
          Timer(Duration(seconds: 2), () {
            _setupVideo();
            Timer(Duration(seconds: 1), () {
              if (isFront != true) {
                isFront = true;
                _onSwitchCamera();
              }
            });
            Timer(Duration(seconds: 3), () {
              postVideo('front');
              Timer(Duration(seconds: 15), () {
                if (isStreamStart == true) {
                  videoStreamStop();
                  isStreamStart = false;
                }
              });
            });
          });
        }
      } else if (jsonData['feature_id'] == 7) {
        if (isStreamStart == false) {
          isStreamStart = true;
          Constants.snackBar(
              "${Constants.capital(jsonData['requester'])}${jsonData['message']}",
              context);
          streamTokenGenVideo();
          Timer(Duration(seconds: 2), () {
            _setupVideo();
            Timer(Duration(seconds: 3), () {
              if (isFront != false) {
                isFront = false;
                _onSwitchCamera();
              }
              Timer(Duration(seconds: 3), () {
                postVideo('rear');
                Timer(Duration(seconds: 15), () {
                  if (isStreamStart == true) {
                    videoStreamStop();
                    isStreamStart = false;
                  }
                });
              });
            });
          });
        }
      } else if (jsonData['feature_id'] == 8) {
        if (isStreamStart == false) {
          isStreamStart = true;
          Constants.snackBar(
              "${Constants.capital(jsonData['requester'])}${jsonData['message']}",
              context);
          streamTokenGenAudio();
          Timer(Duration(seconds: 2), () {
            _setupVideo();
            if (isFront != false) {
              isFront = false;
              _onSwitchCamera();
            }
            Timer(Duration(seconds: 3), () {
              postVideo('front');
            });
            // });
          });
        }
      } else if (jsonData['feature_id'] == 9) {
        if (isStreamStart == false) {
          isStreamStart = true;
          Constants.snackBar(
              "${Constants.capital(jsonData['requester'])}${jsonData['message']}",
              context);
          streamTokenGenAudio();
          Timer(Duration(seconds: 2), () {
            _setupVideo();
            Timer(Duration(seconds: 3), () {
              if (isFront != false) {
                isFront = false;
                _onSwitchCamera();
              }
              Timer(Duration(seconds: 3), () {
                postVideo('rear');
                Timer(Duration(seconds: 15), () {
                  if (isStreamStart == true) {
                    videoStreamStop();
                    isStreamStart = false;
                  }
                });
              });
            });
          });
        }
      }
    } else {
      print(response.body);
      Constants.snackBar("Something went wrong. Api errors", context);
    }
  }

  //Location Background
  locationUpdateOnCall() async {
    //Location Fetch Logic
    var checker = true;
    while (checker) {
      Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best,
              forceAndroidLocationManager: true)
          .then((Position position) {
        setState(() {
          _currentPosition = position;
        });
      }).catchError((e) {
        print(e);
      });
      Constants.snackBar("Location ran", context);
      if (_currentPosition!.latitude != null) {
        Constants.snackBar("Location updated", context);
        checker = false;
      }
    }
    // loop logic to redo everything

    //Api Logic
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    var lat = _currentPosition!.latitude;
    var long = _currentPosition!.longitude;

    Map<String, dynamic> data = {
      "lat": lat.toString(),
      "long": long.toString(),
    };
    var response = await http.post(Uri.parse(url + '/location_save'),
        body: data, headers: header);

    if (response.statusCode == 201) {
      Constants.snackBar("Location sent successfully.", context);
      print(response.body);
      print(data);
    } else {
      print(response.body);
    }
  }
  //
  // Requester functions
  //

//Camera code
  Future<void> _getAvailableCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    _initializeCamera(cameras.first);
  }

  Future<void> _initializeCamera(CameraDescription description) async {
    _cameracontroller = CameraController(description, ResolutionPreset.high);
    _initializeControllerFuture = _cameracontroller.initialize();
    if (!mounted) {
      print("camera not mounted");
    }
    setState(() {
      isCameraReady = true;
    });
  }

  void _lensSelectSender(String option) {
    final lensDirection = _cameracontroller.description.lensDirection;
    CameraDescription newDescription;
    if (option == 'front') {
      newDescription = cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    } else {
      newDescription = cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    }
    print('object');
    if (newDescription != null) {
      _initializeCamera(newDescription);
      postImage(option);
    } else {
      print('Asked camera not available');
    }
  }

  Future postImage(String option) async {
    await _initializeControllerFuture;
    final image = await _cameracontroller.takePicture();
    print(image.path);
    String filepath = image.path;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> headers = {
      "Accept": "application/json",
      'Content-Type': 'multipart/form-data',
      "Authorization": "Bearer $tokenCode"
    };
    var request;
    if (option == 'front') {
      request =
          http.MultipartRequest('POST', Uri.parse(url + '/frontcam_pic_save'))
            ..headers.addAll(headers)
            ..files.add(await http.MultipartFile.fromPath('image', filepath));
    } else {
      request =
          http.MultipartRequest('POST', Uri.parse(url + '/rearcam_pic_save'))
            ..headers.addAll(headers)
            ..files.add(await http.MultipartFile.fromPath('image', filepath));
    }

    print("headers");
    var response = await request.send();
    if (response.statusCode == 201) {
      Constants.snackBar("done", context);
      _cameracontroller.dispose();
    } else {
      Constants.snackBar("error", context);
      _cameracontroller.dispose();
    }
  }

//End Camera code
//Video Code

  Future<void> _setupVideo() async {
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
    await _engine.joinChannel(token, channelName, null, 0);
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(AGORA_APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
          Constants.snackBar(info, context);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
          Constants.snackBar(info, context);
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          Constants.snackBar('onLeaveChannel', context);
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          Constants.snackBar(info, context);
          _users.add(uid);
        });
      },
      userOffline: (uid, elapsed) {
        setState(() {
          final info = 'userOffline: $uid';
          _infoStrings.add(info);
          Constants.snackBar(info, context);
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

  Future<bool> postVideo(String option) async {
    var response;
    var jsonData;
    _engine.muteLocalAudioStream(false);

    if (option == 'front') {
      if (isFront != true) {
        isFront = true;
        _onSwitchCamera();
      }
    } else {
      if (isFront != false) {
        isFront = false;
        _onSwitchCamera();
      }
    }
    return true;
  }

  videoStreamStop() async {
    _users.clear();
    _engine.destroy();
  }
//End Video Code

  //CameraRequest Checker
  getCameraReqCheck() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };

    var response =
        await http.get(Uri.parse(url + '/cam_request_check'), headers: header);
    var jsonData = json.decode(response.body);
    // print(jsonData);
    if (response.statusCode == 200) {
      if (jsonData['frontcam_req'] == 1) {
        Constants.snackBar("Frontcam accessed", context);
        _lensSelectSender('front');
      }
      if (jsonData['rearcam_req'] == 1) {
        Constants.snackBar("rearcam accessed", context);
        _lensSelectSender('rear');
      }
    } else {
      print(response.body);
      Constants.snackBar(
          "Something went wrong. Camera api not passing through", context);
    }
  }

  //End Camera Request Checker
  //Video Request Checker
  streamTokenGenVideo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };

    var response = await http.get(Uri.parse(url + '/token_generate_save_video'),
        headers: header);
    var jsonData = json.decode(response.body);
    // print(jsonData);
    if (response.statusCode == 200) {
      print("Token Generated");
      channelName = jsonData['channel_name'];
      token = jsonData['token'];
      rtmToken = jsonData['rtm_token'];
    } else {
      print(response.body);
      Constants.snackBar(
          "Something went wrong. Stream api not passing through", context);
    }
  }

  streamTokenGenAudio() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };

    var response = await http.get(Uri.parse(url + '/token_generate_save_audio'),
        headers: header);
    var jsonData = json.decode(response.body);
    // print(jsonData);
    if (response.statusCode == 200) {
      print("Token Generated");
      channelName = jsonData['channel_name'];
      token = jsonData['token'];
      rtmToken = jsonData['rtm_token'];
    } else {
      print(response.body);
      Constants.snackBar(
          "Something went wrong. Stream api not passing through", context);
    }
  }

  //End Video Request Checker
  //Audio Request Checker
  getAudioReqCheck() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };

    var response =
        await http.get(Uri.parse(url + '/stream_check_audio'), headers: header);
    var jsonData = json.decode(response.body);
    // print(jsonData);
    if (response.statusCode == 200) {
      if (jsonData['request_audiostream_notifier'] == 1) {
        channelName = jsonData['agora_channel_name'];
        token = jsonData['agora_token'];
        rtmToken = jsonData['agora_rtm_token'];
        Constants.snackBar("Frontcam Streaming", context);
        postVideo('front');
      }
    } else {
      print(response.body);
      Constants.snackBar(
          "Something went wrong. Stream api not passing through", context);
    }
  }

  //
  // Send Request Dialog
  //

  Future<void> _makeRequest() async {
    var _size = MediaQuery.of(context).size;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Container(
                  height: _size.height / 1.5,
                  width: _size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                          child: Container(
                        child: Column(
                          children: [
                            Text(
                              'Request',
                              style: TextStyle(
                                  color: Styles.blackColor,
                                  fontSize: 30,
                                  fontWeight: FontWeight.normal),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.01),
                              child: userPhno("Phone Number"),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Select your choice.",
                              style: TextStyle(color: Styles.blackColor),
                            ),
                            DropdownButton(
                              hint: Text(
                                'Select your option',
                                style: TextStyle(
                                    color: Theme.of(context).disabledColor),
                              ), // Not necessary for Option 1
                              value: _selectedOption,
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedOption = newValue.toString();
                                });
                              },
                              items: _options.map((option) {
                                return DropdownMenuItem(
                                  child: new Text(option),
                                  value: option,
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Select Start time",
                              style: TextStyle(color: Styles.blackColor),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                DropdownButton(
                                  hint: Text(
                                    'HH',
                                    style: TextStyle(
                                        color: Theme.of(context).disabledColor),
                                  ), // Not necessary for Option 1
                                  value: _time1_hour,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _time1_hour = newValue.toString();
                                    });
                                  },
                                  items: _hour.map((option) {
                                    return DropdownMenuItem(
                                      child: new Text(option.toString()),
                                      value: option,
                                    );
                                  }).toList(),
                                ),
                                DropdownButton(
                                  hint: Text(
                                    'MM',
                                    style: TextStyle(
                                        color: Theme.of(context).disabledColor),
                                  ), // Not necessary for Option 1
                                  value: _time1_min,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _time1_min = newValue.toString();
                                    });
                                  },
                                  items: _minute.map((option) {
                                    return DropdownMenuItem(
                                      child: new Text(option.toString()),
                                      value: option,
                                    );
                                  }).toList(),
                                ),
                                DropdownButton(
                                  hint: Text(
                                    'am/pm',
                                    style: TextStyle(
                                        color: Theme.of(context).disabledColor),
                                  ), // Not necessary for Option 1
                                  value: _time1_ampm,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _time1_ampm = newValue.toString();
                                    });
                                  },
                                  items: _ampm.map((option) {
                                    return DropdownMenuItem(
                                      child: new Text(option),
                                      value: option,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Select End time",
                              style: TextStyle(color: Styles.blackColor),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                DropdownButton(
                                  hint: Text(
                                    'HH',
                                    style: TextStyle(
                                        color: Theme.of(context).disabledColor),
                                  ), // Not necessary for Option 1
                                  value: _time2_hour,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _time2_hour = newValue.toString();
                                    });
                                  },
                                  items: _hour.map((option) {
                                    return DropdownMenuItem(
                                      child: new Text(option.toString()),
                                      value: option,
                                    );
                                  }).toList(),
                                ),
                                DropdownButton(
                                  hint: Text(
                                    'MM',
                                    style: TextStyle(
                                        color: Theme.of(context).disabledColor),
                                  ), // Not necessary for Option 1
                                  value: _time2_min,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _time2_min = newValue.toString();
                                    });
                                  },
                                  items: _minute.map((option) {
                                    return DropdownMenuItem(
                                      child: new Text(option.toString()),
                                      value: option,
                                    );
                                  }).toList(),
                                ),
                                DropdownButton(
                                  hint: Text(
                                    'am/pm',
                                    style: TextStyle(
                                        color: Theme.of(context).disabledColor),
                                  ), // Not necessary for Option 1
                                  value: _time2_ampm,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _time2_ampm = newValue.toString();
                                    });
                                  },
                                  items: _ampm.map((option) {
                                    return DropdownMenuItem(
                                      child: new Text(option),
                                      value: option,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      )),
                      Padding(padding: EdgeInsets.only(top: 30.0)),
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Styles.darkblueColor)),
                          onPressed: () {
                            Navigator.of(context).pop();
                            makeRequests();
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                            child: Text(
                              'Send',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          )),
                      Padding(padding: EdgeInsets.only(top: 30.0)),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Back',
                            style: TextStyle(
                                color: Styles.blackColor, fontSize: 18.0),
                          ))
                    ],
                  ),
                ),
              );
            }));
      },
    );
  }

  Container phNoForm() {
    return Container(
        child: Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.13),
      child: Form(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: userPhno("Phone Number"),
            ),
            Spacer(),
          ],
        ),
      ),
    ));
  }

  TextFormField userPhno(String title) {
    return TextFormField(
        controller: userPhnoController,
        cursorColor: Styles.blackColor,
        style: TextStyle(color: Styles.blackColor),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Styles.blackColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Styles.blackColor, width: 2.0),
          ),
          labelText: title,
          labelStyle: TextStyle(
              color: myFocusNode.hasFocus ? Colors.black : Colors.blue[300]),
          hintText: "Enter valid Phone Number",
          hintStyle: TextStyle(
              color: myFocusNode.hasFocus
                  ? Colors.grey
                  : Theme.of(context).disabledColor),
        ));
  }

  //Make Requests Api
  makeRequests() async {
    //Api Logic
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };

    String time1String =
        '$_time1_hour' + ':' + '$_time1_min' + ' ' + '$_time1_ampm';
    String time2String =
        '$_time2_hour' + ':' + '$_time2_min' + ' ' + '$_time2_ampm';

    Map<String, dynamic> data = {
      "phone_number": userPhnoController.text,
      "selected_option": _selectedOption,
      "start_time": time1String,
      "end_time": time2String,
    };

    print(data);
    var response = await http.post(Uri.parse(url + '/make_request'),
        body: data, headers: header);

    if (response.statusCode == 201) {
      var jsonData = json.decode(response.body);
      var message = jsonData["message"];
      Constants.snackBar(message, context);
      setState(() {});
    } else {
      print(response.body);
      var jsonData = json.decode(response.body);
      var message = jsonData["message"];
      Constants.snackBar(message, context);
      setState(() {});
    }
  }

  //
  // Dark mode enabler
  //

  // _blackWhite(DarkThemeProvider themeProvider) {
  //   return InkWell(
  //     child: RotatedBox(
  //       quarterTurns: 2,
  //       child: SizedBox(
  //         child: !_switch ? Image.asset(Res.on_) : Image.asset(Res.off_),
  //         width: 45,
  //         height: 45,
  //       ),
  //     ),
  //     onTap: () {
  //       setState(() {
  //         cirAn = true;
  //         _switch = !_switch;
  //       });
  //       themeProvider.darkTheme = !themeProvider.darkTheme;

  //       if (animationController.status == AnimationStatus.forward ||
  //           animationController.status == AnimationStatus.completed) {
  //         animationController.reset();
  //         animationController.forward();
  //       } else {
  //         animationController.forward();
  //       }
  //     },
  //   );
  // }

  //
  //
  // Permission functions
  //
  //

  //
  //
  // Permission controller

  Future<void> initBackgroundPermissions() async {
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Dhatnoon",
      notificationText: "Running in Background",
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(
          name: 'background_icon',
          defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);
    await FlutterBackground.enableBackgroundExecution();
    print("object");
    initCameraPermissions();
  }

  Future<void> initCameraPermissions() async {
    await Permission.camera.request();
    print(await Permission.camera.status);
    if (await Permission.camera.status == PermissionStatus.denied) {
      // Constants.snackBar("Camera is not enabled", context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text('Camera Permission'),
                content: Text(
                    'This app needs camera access in order to function properly.'),
                actions: <Widget>[
                  TextButton(
                      child: Text('Deny'),
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                        initCameraPermissions();
                      }),
                  TextButton(
                    child: Text('Settings'),
                    onPressed: () => openAppSettings(),
                  ),
                  TextButton(
                    child: Text('Done'),
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                      initCameraPermissions();
                    },
                  ),
                ],
              ));
        },
      );
    } else {
      initMicrophonePermissions();
    }
  }

  Future<void> initMicrophonePermissions() async {
    await Permission.microphone.request();
    print(await Permission.microphone.status);
    if (await Permission.microphone.status == PermissionStatus.denied) {
      Constants.snackBar("Microphone is not enabled", context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text('Microphone Permission'),
                content: Text(
                    'This app needs microphone access in order to function properly.'),
                actions: <Widget>[
                  TextButton(
                      child: Text('Deny'),
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                        initMicrophonePermissions();
                      }),
                  TextButton(
                    child: Text('Settings'),
                    onPressed: () => openAppSettings(),
                  ),
                  TextButton(
                    child: Text('Done'),
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                      initMicrophonePermissions();
                    },
                  ),
                ],
              ));
        },
      );
    } else {
      initLocationPermissions();
    }
  }

  Future<void> initLocationPermissions() async {
    await Permission.locationAlways.request();
    print(await Permission.locationAlways.status);
    if (await Permission.locationAlways.status == PermissionStatus.denied) {
      Constants.snackBar("Location is not enabled", context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text('Location Permission'),
                content: Text(
                    'This app needs Location access in order to function properly.'),
                actions: <Widget>[
                  TextButton(
                      child: Text('Deny'),
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                        initLocationPermissions();
                      }),
                  TextButton(
                    child: Text('Settings'),
                    onPressed: () => openAppSettings(),
                  ),
                  TextButton(
                    child: Text('Done'),
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                      initLocationPermissions();
                    },
                  ),
                ],
              ));
        },
      );
    } else {
      initStoragePermissions();
    }
  }

  Future<void> initStoragePermissions() async {
    await Permission.storage.request();
    print(await Permission.storage.status);
    if (await Permission.storage.status == PermissionStatus.denied) {
      Constants.snackBar("Storage is not enabled", context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text('Storage Permission'),
                content: Text(
                    'This app needs storage access in order to function properly.'),
                actions: <Widget>[
                  TextButton(
                      child: Text('Deny'),
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                        initStoragePermissions();
                      }),
                  TextButton(
                    child: Text('Settings'),
                    onPressed: () => openAppSettings(),
                  ),
                  TextButton(
                    child: Text('Done'),
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                      initStoragePermissions();
                    },
                  ),
                ],
              ));
        },
      );
    } else {
      initBatOptPermissions();
    }
  }

  Future<void> initBatOptPermissions() async {
    await Permission.ignoreBatteryOptimizations.request();
    print(await Permission.ignoreBatteryOptimizations.status);
    if (await Permission.ignoreBatteryOptimizations.status ==
        PermissionStatus.denied) {
      Constants.snackBar(
          "Ignore Battery Optimizations is not enabled", context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text('Ignore Battery Optimizations Permission'),
                content: Text(
                    'This app needs Ignore Battery Optimizations access in order to function properly.'),
                actions: <Widget>[
                  TextButton(
                      child: Text('Deny'),
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                        initBatOptPermissions();
                      }),
                  TextButton(
                    child: Text('Settings'),
                    onPressed: () => openAppSettings(),
                  ),
                  TextButton(
                    child: Text('Done'),
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                      initBatOptPermissions();
                    },
                  ),
                ],
              ));
        },
      );
    }
  }
}
