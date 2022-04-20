import 'dart:math';

import 'package:dhatnoon/MainArrange.dart';
import 'package:dhatnoon/Mainpage/Design/widgets/home_main.dart';
import 'package:dhatnoon/camerapage.dart';
import 'package:dhatnoon/datetime.dart';
import 'package:dhatnoon/loginpage.dart';
import 'package:dhatnoon/navigationpage.dart';
import 'package:dhatnoon/locationpage.dart';
import 'package:dhatnoon/providers/approved_requests.dart';
// import 'package:dhatnoon/services/notification_service.dart';
import 'package:dhatnoon/videopage.dart';
import 'package:dhatnoon/audiopage.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'package:dhatnoon/locationprovider.dart';
import 'providers/userlist.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';
import 'providers/request_select.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:async';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
//Camera Imports
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

//notification
import 'notification_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  //
  // Scaffold Drawer draw essentials
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //
  // Body animation features variable
  bool _isLoading = false;
  bool _isShowRequested = false;
  bool _isLogin = false;
  String? userName = "";
  late Size _size;
  late AnimationController _animationController;
  late Animation<double> _animationTextRotate;

  //
  //Post request variables s
  //phone number entry form
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

  //hour minute lists
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
  List<String> _ampm = ['am', 'pm'];

  //
  // Requests page variables
  late List<dynamic> requestSelect;
  late List<dynamic> requestList;

  //
  // Requested page variable
  late List<dynamic> userData;
  late List<dynamic> requestedList;

  //
  // Location feature variables
  Position? _currentPosition;

  //
  // Image Post feature variable
  // Camera initialise vars
  late CameraController _cameracontroller;
  Future<void>? _initializeControllerFuture;
  bool isCameraReady = false;
  String optionCam = '';

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
  //
  //
  //
  //
  //
  //

  // main page initialiser
  @override
  void initState() {
    checkLoginStatus();
    // animation initialise
    setUpAnimation();

    // Location initialise
    Provider.of<LocationProvider>(context, listen: false).initialization();

    // background permission initialise
    initBackgroundPermissions();

    // body initialiser
    super.initState();

    // user name fetcher initialise
    userNameFetcher();

    // 5 second timer for various background tasks
    Timer timer =
        Timer.periodic(Duration(seconds: 3), (Timer t) => requestExecuter());
  }

  checkLoginStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print(sharedPreferences.getString('token'));
    if (sharedPreferences.getString('token') == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  // main page disposer
  @override
  void dispose() {
    // animation controller disposer
    _animationController.dispose();
    super.dispose();
  }

  // animation setter
  void setUpAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: defaultDuration);
    _animationTextRotate =
        Tween<double>(begin: 0, end: 90).animate(_animationController);
  }

  void updateView() {
    setState(() {
      _isShowRequested = !_isShowRequested;
    });
    _isShowRequested
        ? _animationController.forward()
        : _animationController.reverse();
  }

  // Body part
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
          splashColor: _isShowRequested ? signup_bg_lignt : login_bg_light,
          child: new Icon(
            Icons.menu,
            size: 24,
            color: _isShowRequested ? signup_bg : login_bg,
          ),
        ),
        backgroundColor: Colors.white,
        title: _isShowRequested
            ? Text("Hello $userName",
                style:
                    TextStyle(color: _isShowRequested ? signup_bg : login_bg))
            : Text("Hello $userName",
                style:
                    TextStyle(color: _isShowRequested ? signup_bg : login_bg)),
        elevation: 0,
        actions: [
          Row(
            children: [
              // TextButton(
              //     onPressed: () {
              //       NotificationService()
              //           .postNotification("aasdf", "gfds", "sdfg");
              //     },
              //     child: Icon(Icons.camera_front)),

              TextButton(
                  onPressed: () {
                    setState(() {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MainArrange()));
                    });
                  },
                  child: Icon(Icons.camera_rear_outlined)),
              // TextButton(
              //     onPressed: () {}, child: Icon(Icons.camera_rear_outlined)),
            ],
          ),
        ],
      ),
      body: Container(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(login_bg)))
            : bodyContent(),
      ),
      bottomNavigationBar: bottomNav(),
    );
  }

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
    print("object");
    initCameraPermissions();
  }

  Future<void> initCameraPermissions() async {
    await Permission.camera.request();
    print(await Permission.camera.status);
    if (await Permission.camera.status == PermissionStatus.denied) {
      snackBar("Camera is not enabled");
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
      snackBar("Microphone is not enabled");
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
      snackBar("Location is not enabled");
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
      snackBar("Storage is not enabled");
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
      snackBar("Ignore Battery Optimizations is not enabled");
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

  // User Data Fetch
  userNameFetcher() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userName = sharedPreferences.getString('user_data_phone_number');
    setState(() {});
  }

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
        snackBar(
            "${intl.toBeginningOfSentenceCase(jsonData['requester'])}${jsonData['message']}");
        locationUpdateOnCall();
      } else if (jsonData['feature_id'] == 2) {
        snackBar(
            "${intl.toBeginningOfSentenceCase(jsonData['requester'])}${jsonData['message']}");
        _getAvailableCameras();
        Timer(Duration(seconds: 1), () {
          if (isCameraReady == true) {
            _lensSelectSender('front');
          }
        });
      } else if (jsonData['feature_id'] == 3) {
        snackBar(
            "${intl.toBeginningOfSentenceCase(jsonData['requester'])}${jsonData['message']}");
        _getAvailableCameras();
        Timer(Duration(seconds: 1), () {
          if (isCameraReady == true) {
            _lensSelectSender('rear');
          }
        });
      } else if (jsonData['feature_id'] == 4) {
        if (isStreamStart == false) {
          isStreamStart = true;
          snackBar(
              "${intl.toBeginningOfSentenceCase(jsonData['requester'])}${jsonData['message']}");
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
          snackBar(
              "${intl.toBeginningOfSentenceCase(jsonData['requester'])}${jsonData['message']}");
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
          snackBar(
              "${intl.toBeginningOfSentenceCase(jsonData['requester'])}${jsonData['message']}");
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
          snackBar(
              "${intl.toBeginningOfSentenceCase(jsonData['requester'])}${jsonData['message']}");
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
          snackBar(
              "${intl.toBeginningOfSentenceCase(jsonData['requester'])}${jsonData['message']}");
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
          snackBar(
              "${intl.toBeginningOfSentenceCase(jsonData['requester'])}${jsonData['message']}");
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
      snackBar("Something went wrong. Api errors");
    }
  }

  //Location Background
  locationUpdateOnCall() async {
    //Location Fetch Logic
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
      snackBar("Location sent successfully.");
    } else {
      print(response.body);
    }
  }
  //End Location Background

  //Video token generation and sharing with the requester
  videoScreen(String option, String user_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    Map<String, String> data = {"user_id": user_id};
    var call;
    if (option == 'front') {
      call = await http.post(Uri.parse(url + '/call_user_frontstream'),
          body: data, headers: header);
    } else {
      call = await http.post(Uri.parse(url + '/call_user_rearstream'),
          body: data, headers: header);
    }
    var response;
    Timer(Duration(seconds: 7), () async {
      if (option == 'front') {
        response = await http.post(Uri.parse(url + '/start_user_frontstream'),
            body: data, headers: header);
      } else {
        response = await http.post(Uri.parse(url + '/start_user_rearstream'),
            body: data, headers: header);
      }
      var jsonData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoPage(
                    channelName: jsonData['channel_name'],
                    token: jsonData['token'],
                    rtmToken: jsonData['rtm_token'],
                    option: option,
                    sec10: false)),
          );
        });
      } else {
        print(response.body);
        snackBar("Something went wrong. Streams not passing through");
      }
    });
  }

  videoScreen10(String option, String user_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    Map<String, String> data = {"user_id": user_id};
    var call;
    if (option == 'front') {
      call = await http.post(Uri.parse(url + '/call_user_frontstream10'),
          body: data, headers: header);
    } else {
      call = await http.post(Uri.parse(url + '/call_user_rearstream10'),
          body: data, headers: header);
    }
    var response;
    Timer(Duration(seconds: 7), () async {
      if (option == 'front') {
        response = await http.post(Uri.parse(url + '/start_user_frontstream10'),
            body: data, headers: header);
      } else {
        response = await http.post(Uri.parse(url + '/start_user_rearstream10'),
            body: data, headers: header);
      }
      var jsonData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoPage(
                    channelName: jsonData['channel_name'],
                    token: jsonData['token'],
                    rtmToken: jsonData['rtm_token'],
                    option: option,
                    sec10: true)),
          );
        });
      } else {
        print(response.body);
        snackBar("Something went wrong. Streams not passing through");
      }
    });
  }

  audioScreen(String user_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    Map<String, String> data = {"user_id": user_id};
    var call = await http.post(Uri.parse(url + '/call_user_audio'),
        body: data, headers: header);

    var response;
    Timer(Duration(seconds: 7), () async {
      response = await http.post(Uri.parse(url + '/start_user_audio'),
          body: data, headers: header);
      var jsonData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AudioPage(
                    channelName: jsonData['channel_name'],
                    token: jsonData['token'],
                    rtmToken: jsonData['rtm_token'],
                    sec10: false)),
          );
        });
      } else {
        print(response.body);
        snackBar("Something went wrong. Streams not passing through");
      }
    });
  }

  audioScreen10(String user_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    Map<String, String> data = {"user_id": user_id};
    var call = await http.post(Uri.parse(url + '/call_user_audio10'),
        body: data, headers: header);

    var response;
    Timer(Duration(seconds: 7), () async {
      response = await http.post(Uri.parse(url + '/start_user_audio10'),
          body: data, headers: header);
      var jsonData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AudioPage(
                    channelName: jsonData['channel_name'],
                    token: jsonData['token'],
                    rtmToken: jsonData['rtm_token'],
                    sec10: true)),
          );
        });
      } else {
        print(response.body);
        snackBar("Something went wrong. Streams not passing through");
      }
    });
  }

  //Audio token generation and sharing with the requester
  // audioStream(String user_id) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   var tokenCode = sharedPreferences.getString('token');
  //   Map<String, String> header = {
  //     "Accept": "application/json",
  //     "Authorization": "Bearer $tokenCode"
  //   };
  //   Map<String, String> data = {"user_id": user_id};

  //   var response;
  //   response = await http.post(Uri.parse(url + '/get_user_audiostream_start'),
  //       body: data, headers: header);

  //   var jsonData = json.decode(response.body);
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       _cameracontroller.dispose();
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => VideoPage(
  //                   channelName: jsonData['channel_name'],
  //                   token: jsonData['token'],
  //                   rtmToken: jsonData['rtm_token'],
  //                 )),
  //       );
  //     });
  //   } else {
  //     print(response.body);
  //     snackBar("Something went wrong. Streams not passing through");
  //   }
  // }

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
      snackBar("done");
      _cameracontroller.dispose();
    } else {
      snackBar("error");
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
          snackBar(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
          snackBar(info);
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          snackBar('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          snackBar(info);
          _users.add(uid);
        });
      },
      userOffline: (uid, elapsed) {
        setState(() {
          final info = 'userOffline: $uid';
          _infoStrings.add(info);
          snackBar(info);
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
        snackBar("Frontcam accessed");
        _lensSelectSender('front');
      }
      if (jsonData['rearcam_req'] == 1) {
        snackBar("rearcam accessed");
        _lensSelectSender('rear');
      }
    } else {
      print(response.body);
      snackBar("Something went wrong. Camera api not passing through");
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
      snackBar("Something went wrong. Stream api not passing through");
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
      snackBar("Something went wrong. Stream api not passing through");
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
        snackBar("Frontcam Streaming");
        postVideo('front');
      }
    } else {
      print(response.body);
      snackBar("Something went wrong. Stream api not passing through");
    }
  }
  //End Audio Request Checker

//Body builder content

  topBar() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
                width: _size.width / 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: login_bg,
                    border: Border(
                      bottom: BorderSide(width: 3, color: Colors.white),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      _isShowRequested = true;
                      updateView();
                    },
                    child: Text(
                      'Fetch',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )),
            SizedBox(
                width: _size.width / 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: signup_bg,
                    border: Border(
                      bottom: BorderSide(width: 3, color: Colors.white),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      _isShowRequested = false;
                      updateView();
                    },
                    child: Text(
                      'Allow',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: !_isShowRequested
              ? SizedBox(
                  width: _size.width,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                            width: 3,
                            color: _isShowRequested ? signup_bg : login_bg),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        _makeRequest();
                      },
                      child: Text(
                        'Make a Request',
                        style: TextStyle(
                            color: _isShowRequested ? signup_bg : login_bg),
                      ),
                    ),
                  ))
              : SizedBox(
                  width: _size.width,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _isShowRequested ? signup_bg : login_bg,
                      border: Border(
                        bottom: BorderSide(width: 3, color: login_bg),
                      ),
                    ),
                    child: TextButton(
                      onPressed: null,
                      child: _isShowRequested
                          ? Text(
                              'Requests sent to you.',
                              style: TextStyle(
                                  color: _isShowRequested
                                      ? Colors.white
                                      : signup_bg),
                            )
                          : Text(
                              'Approved Requests',
                              style: TextStyle(
                                  color: _isShowRequested
                                      ? signup_bg
                                      : Colors.white),
                            ),
                    ),
                  )),
        ),
      ],
    );
  }

  bodyContent() {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return Stack(
            children: [
              AnimatedPositioned(
                  duration: defaultDuration,
                  width: _size.width * 1,
                  // height: 100,
                  top: _size.height * 0,
                  child: topBar()),
              AnimatedPositioned(
                duration: defaultDuration,
                top: _size.height * .14,
                width: _size.width * 1,
                height: _size.height / 1.65,
                left: _isShowRequested ? -_size.width * 1 : _size.width * 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: null,
                  child: Container(
                    color: login_bg,
                    child: requested(),
                  ),
                ),
              ),
              AnimatedPositioned(
                  duration: defaultDuration,
                  top: _size.height * .14,
                  width: _size.width * 1,
                  height: _size.height / 1.65,
                  left: _isShowRequested ? _size.width * 0 : _size.width * 1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: null,
                    child: Container(
                      color: signup_bg,
                      child: requests(),
                    ),
                  )),
            ],
          );
        });
  }

//Requested Section

  Future<List<ApprovedRequests>> getUserRequested() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    Map<String, String> data = {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    };
    try {
      var response =
          await http.get(Uri.parse(url + '/approved_requests'), headers: data);
      Map<String, dynamic> map = json.decode(response.body);
      userData = map["data"];
    } catch (error) {}
    return userData.map((e) => ApprovedRequests.fromJson(e)).toList();
  }

  FutureBuilder requested() {
    return FutureBuilder(
      future: getUserRequested(),
      builder: (context, data) {
        if (data.hasError) {
          return Center(child: Text("${data.error}"));
        } else if (data.hasData) {
          var items = data.data as List<ApprovedRequests>;
          return ListView.builder(
              // reverse: true,
              itemCount: items == null ? 0 : items.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Text(
                                  items[index].feature.toString(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: signup_bg,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Text(
                                  "Of " +
                                      capital(
                                          items[index].user_name.toString()) +
                                      " between " +
                                      timeFormat(
                                          items[index].start_time.toString()) +
                                      " to " +
                                      timeFormat(
                                          items[index].end_time.toString()),
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          ),
                        )),
                        OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              primary: login_bg_light,
                              backgroundColor: login_bg_light,
                              side: BorderSide(color: login_bg, width: 1),
                            ),
                            onPressed: () => pageRedirector(
                                items[index].user_id, items[index].feature_id),
                            // onPressed: () => _showDialogperms(),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'View',
                                style: TextStyle(fontSize: 20, color: login_bg),
                              ),
                            )),
                      ],
                    ),
                  ),
                );
              });
        } else {
          return Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(signup_bg)),
          );
        }
      },
    );
  }

  //redirects page on press of view button
  pageRedirector(String user_id, feature_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("approved_user_id", user_id);
    sharedPreferences.setString("approved_user_feature_id", feature_id);

    if (feature_id == "1") {
      setState(() {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LocationPage()));
      });
    } else if (feature_id == "2") {
      print('Front Camera Pic.');
      fetchUserImage('front', user_id);
      setState(() {
        _isLoading = true;
      });
    } else if (feature_id == "3") {
      print('Back Camera Pic.');
      fetchUserImage('rear', user_id);
      setState(() {
        _isLoading = true;
      });
    } else if (feature_id == "4") {
      print('Front Camera Streaming.');
      videoScreen('front', user_id);
    } else if (feature_id == "5") {
      print('Back Camera Streaming.');
      videoScreen('rear', user_id);
    } else if (feature_id == "6") {
      print('Front Camera 10 Second Video.');
      videoScreen10('front', user_id);
    } else if (feature_id == "7") {
      print('Back camera 10 Second Video.');
      videoScreen10('rear', user_id);
    } else if (feature_id == "8") {
      snackBar('Audio Live Streaming.');
      audioScreen(user_id);
    } else if (feature_id == "9") {
      print('10 Second Audio Recording.');
      audioScreen10(user_id);
    }
  }

  Future fetchUserImage(String option, user_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    Map<String, dynamic> data = {
      "user_id": user_id.toString(),
    };

    var erer;

    if (option == 'front') {
      erer = await http.post(Uri.parse(url + '/call_user_frontcam'),
          body: data, headers: headers);
    } else {
      erer = await http.post(Uri.parse(url + '/call_user_rearcam'),
          body: data, headers: headers);
    }

    Timer(Duration(seconds: 10), () async {
      var response;
      if (option == 'front') {
        response = await http.post(Uri.parse(url + '/get_user_frontcam'),
            body: data, headers: headers);
      } else {
        response = await http.post(Uri.parse(url + '/get_user_rearcam'),
            body: data, headers: headers);
      }
      var jsonData = jsonDecode(response.body);
      print(jsonData);
      if (response.statusCode == 200) {
        snackBar("done");
        print(jsonData['url']);
        imgUrl = jsonData['url'];
        setState(() {
          _isLoading = false;
          _showImageDialog();
        });
      } else {
        snackBar("error");
      }
    });
  }

  Future<void> _showImageDialog() async {
    return showDialog<void>(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill, image: NetworkImage(ftp + imgUrl))),
              child: Stack(children: <Widget>[]));
        }));
      },
    );
  }

  Future<void> _makeRequest() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(content: StatefulBuilder(
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
                              color: login_bg,
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
                          style: TextStyle(color: login_bg),
                        ),
                        DropdownButton(
                          hint: Text(
                              'Select your option'), // Not necessary for Option 1
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
                          style: TextStyle(color: login_bg),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            DropdownButton(
                              hint: Text('HH'), // Not necessary for Option 1
                              value: _time1_hour,
                              onChanged: (newValue) {
                                setState(() {
                                  _time1_hour = newValue.toString();
                                });
                              },
                              items: _hour.map((option) {
                                return DropdownMenuItem(
                                  child: new Text(option),
                                  value: option,
                                );
                              }).toList(),
                            ),
                            DropdownButton(
                              hint: Text('MM'), // Not necessary for Option 1
                              value: _time1_min,
                              onChanged: (newValue) {
                                setState(() {
                                  _time1_min = newValue.toString();
                                });
                              },
                              items: _minute.map((option) {
                                return DropdownMenuItem(
                                  child: new Text(option),
                                  value: option,
                                );
                              }).toList(),
                            ),
                            DropdownButton(
                              hint: Text('am/pm'), // Not necessary for Option 1
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
                          style: TextStyle(color: login_bg),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            DropdownButton(
                              hint: Text('HH'), // Not necessary for Option 1
                              value: _time2_hour,
                              onChanged: (newValue) {
                                setState(() {
                                  _time2_hour = newValue.toString();
                                });
                              },
                              items: _hour.map((option) {
                                return DropdownMenuItem(
                                  child: new Text(option),
                                  value: option,
                                );
                              }).toList(),
                            ),
                            DropdownButton(
                              hint: Text('MM'), // Not necessary for Option 1
                              value: _time2_min,
                              onChanged: (newValue) {
                                setState(() {
                                  _time2_min = newValue.toString();
                                });
                              },
                              items: _minute.map((option) {
                                return DropdownMenuItem(
                                  child: new Text(option),
                                  value: option,
                                );
                              }).toList(),
                            ),
                            DropdownButton(
                              hint: Text('am/pm'), // Not necessary for Option 1
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
                          backgroundColor: MaterialStateProperty.all(login_bg)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        makeRequests();
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                        child: Text(
                          'Send',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      )),
                  Padding(padding: EdgeInsets.only(top: 30.0)),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Back',
                        style: TextStyle(color: login_bg, fontSize: 18.0),
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
        cursorColor: login_bg,
        style: TextStyle(color: login_bg),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: login_bg, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: login_bg, width: 2.0),
          ),
          labelText: title,
          labelStyle:
              TextStyle(color: myFocusNode.hasFocus ? Colors.black : login_bg),
          hintText: "Enter valid Phone Number",
          hintStyle:
              TextStyle(color: myFocusNode.hasFocus ? Colors.grey : login_bg),
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
      snackBar(message);
      setState(() {});
    } else {
      print(response.body);
      var jsonData = json.decode(response.body);
      var message = jsonData["message"];
      snackBar(message);
      setState(() {});
    }
  }
  //End Make Requests Api

  snackBar(string) {
    final snackBar = SnackBar(content: Text(string));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Dialog content end

//Requeests section

  Future<List<RequestSelect>> getUserRequests() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    Map<String, String> data = {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    };
    try {
      var response =
          await http.get(Uri.parse(url + '/request_select'), headers: data);
      Map<String, dynamic> map = json.decode(response.body);
      requestSelect = map["data"];
      // print(token);
    } catch (error) {}
    return requestSelect.map((e) => RequestSelect.fromJson(e)).toList();
  }

  FutureBuilder requests() {
    return FutureBuilder(
      future: getUserRequests(),
      builder: (context, data) {
        if (data.hasError) {
          return Center(child: Text("${data.error}"));
        } else if (data.hasData) {
          var items = data.data as List<RequestSelect>;
          return ListView.builder(
              // reverse: true,
              itemCount: items == null ? 0 : items.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Text(
                                  items[index].feature.toString(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Text(
                                  // items[index].email.toString(),
                                  "To " +
                                      capital(items[index]
                                          .requester_name
                                          .toString()) +
                                      " between " +
                                      timeFormat(
                                          items[index].start_time.toString()) +
                                      " to " +
                                      timeFormat(
                                          items[index].end_time.toString()),
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: cond(items[index].day_access)
                                    ? Text(
                                        // items[index].email.toString(),
                                        "Allowed",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: login_bg,
                                            fontWeight: FontWeight.normal),
                                      )
                                    : Text(
                                        // items[index].email.toString(),
                                        "Denied",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.red,
                                            fontWeight: FontWeight.normal),
                                      ),
                              )
                            ],
                          ),
                        )),
                        Wrap(
                          spacing:
                              25, // to apply margin in the main axis of the wrap
                          runSpacing: 25,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                primary: login_bg,
                                backgroundColor: login_bg_light,
                                side: BorderSide(color: login_bg, width: 1),
                                shape: StadiumBorder(),
                              ),
                              onPressed: () {
                                allowDenyControlller(
                                    1,
                                    items[index].requester_id,
                                    items[index].feature_id);
                              },
                              child: Icon(
                                Icons.check,
                                color: login_bg,
                                size: 30.0,
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                primary: login_bg,
                                backgroundColor: Colors.red[50],
                                side: BorderSide(color: Colors.red, width: 1),
                                shape: StadiumBorder(),
                              ),
                              onPressed: () {
                                allowDenyControlller(
                                    0,
                                    items[index].requester_id,
                                    items[index].feature_id);
                              },
                              child: Icon(
                                Icons.block,
                                color: Colors.red[600],
                                size: 30.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              });
        } else {
          return Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(login_bg)),
          );
        }
      },
    );
  }

  allowDenyControlller(
      int option, String requester_id, String feature_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    };

    Map<String, dynamic> data = {
      "option": option.toString(),
      "requester_id": requester_id.toString(),
      "feature_id": feature_id.toString(),
    };

    print(data);
    var response = await http.post(Uri.parse(url + '/allow_deny_controller'),
        body: data, headers: header);
    var json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        print(response.body);
        snackBar(json['message']);
      });
    } else {
      setState(() {
        print(response.body);
        print(token);
        snackBar(json['message']);
      });
    }
  }

  // Bottom Nav Section

  bottomNav() {
    return _isShowRequested
        ? Container(
            height: _size.height / 6.5,
            color: Colors.white,
            child: InkWell(
              onTap: () => print('tap on close'),
              child: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                        width: _size.width,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                  width: 3,
                                  color:
                                      _isShowRequested ? signup_bg : login_bg),
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              showModalBottomSheet<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                        child: Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: denied_list()));
                                  });
                            },
                            child: Text(
                              'Rejected By You',
                              style: TextStyle(
                                  color:
                                      _isShowRequested ? signup_bg : login_bg),
                            ),
                          ),
                        )),
                    SizedBox(
                        width: _size.width,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                  width: 3,
                                  color:
                                      _isShowRequested ? signup_bg : login_bg),
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              showModalBottomSheet<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                        child: Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: approved_list()));
                                  });
                            },
                            child: Text(
                              'Approved By You',
                              style: TextStyle(
                                  color:
                                      _isShowRequested ? signup_bg : login_bg),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          )
        : Container(
            height: _size.height / 6.5,
            color: Colors.white,
            child: InkWell(
              onTap: () => print('tap on close'),
              child: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                        width: _size.width,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _isShowRequested ? signup_bg : login_bg,
                            border: Border(
                              bottom: BorderSide(width: 3, color: login_bg),
                            ),
                          ),
                          child: TextButton(
                            onPressed: null,
                            child: _isShowRequested
                                ? Text(
                                    'Requests sent to you.',
                                    style: TextStyle(
                                        color: _isShowRequested
                                            ? Colors.white
                                            : signup_bg),
                                  )
                                : Text(
                                    'Approved Requests',
                                    style: TextStyle(
                                        color: _isShowRequested
                                            ? signup_bg
                                            : Colors.white),
                                  ),
                          ),
                        )),
                    SizedBox(
                        width: _size.width,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                  width: 3,
                                  color:
                                      _isShowRequested ? signup_bg : login_bg),
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              showModalBottomSheet<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                        child: Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: requests()));
                                  });
                            },
                            child: Text(
                              'List of Pending or rejected Request',
                              style: TextStyle(
                                  color:
                                      _isShowRequested ? signup_bg : login_bg),
                            ),
                          ),
                        )),
                    // SizedBox(
                    //     width: _size.width,
                    //     child: DecoratedBox(
                    //       decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         border: Border(
                    //           bottom: BorderSide(
                    //               width: 3,
                    //               color:
                    //                   _isShowRequested ? signup_bg : login_bg),
                    //         ),
                    //       ),
                    //       child: TextButton(
                    //         onPressed: () {
                    //           _makeRequest();
                    //         },
                    //         child: Text(
                    //           'Make a Request',
                    //           style: TextStyle(
                    //               color:
                    //                   _isShowRequested ? signup_bg : login_bg),
                    //         ),
                    //       ),
                    //     )),
                  ],
                ),
              ),
            ),
          );
  }

  //Approved By you rejected by you section
  // Future<List<RequestSelect>> getUserRequests() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   var token = sharedPreferences.getString('token');
  //   Map<String, String> data = {
  //     "Accept": "application/json",
  //     "Authorization": "Bearer $token"
  //   };
  //   try {
  //     var response =
  //         await http.get(Uri.parse(url + '/request_select'), headers: data);
  //     Map<String, dynamic> map = json.decode(response.body);
  //     requestSelect = map["data"];
  //     // print(token);
  //   } catch (error) {}
  //   return requestSelect.map((e) => RequestSelect.fromJson(e)).toList();
  // }

  FutureBuilder approved_list() {
    return FutureBuilder(
      future: getUserRequests(),
      builder: (context, data) {
        if (data.hasError) {
          return Center(child: Text("${data.error}"));
        } else if (data.hasData) {
          var items = data.data as List<RequestSelect>;
          return ListView.builder(
              // reverse: true,
              itemCount: items == null ? 0 : items.length,
              itemBuilder: (context, index) {
                return cond(items[index].day_access)
                    ? Card(
                        elevation: 5,
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Container(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 8, right: 8),
                                      child: Text(
                                        items[index].feature.toString(),
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 8, right: 8),
                                      child: Text(
                                        // items[index].email.toString(),
                                        "To " +
                                            capital(items[index]
                                                .requester_name
                                                .toString()) +
                                            " between " +
                                            timeFormat(items[index]
                                                .start_time
                                                .toString()) +
                                            " to " +
                                            timeFormat(items[index]
                                                .end_time
                                                .toString()),
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 8, right: 8),
                                      child: cond(items[index].day_access)
                                          ? Text(
                                              // items[index].email.toString(),
                                              "Allowed",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: login_bg,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            )
                                          : Text(
                                              // items[index].email.toString(),
                                              "Denied",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.red,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                    )
                                  ],
                                ),
                              )),
                              Wrap(
                                spacing:
                                    25, // to apply margin in the main axis of the wrap
                                runSpacing: 25,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      primary: login_bg,
                                      backgroundColor: login_bg_light,
                                      side:
                                          BorderSide(color: login_bg, width: 1),
                                      shape: StadiumBorder(),
                                    ),
                                    onPressed: () {
                                      allowDenyControlller(
                                          1,
                                          items[index].requester_id,
                                          items[index].feature_id);
                                    },
                                    child: Icon(
                                      Icons.check,
                                      color: login_bg,
                                      size: 30.0,
                                    ),
                                  ),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      primary: login_bg,
                                      backgroundColor: Colors.red[50],
                                      side: BorderSide(
                                          color: Colors.red, width: 1),
                                      shape: StadiumBorder(),
                                    ),
                                    onPressed: () {
                                      allowDenyControlller(
                                          0,
                                          items[index].requester_id,
                                          items[index].feature_id);
                                    },
                                    child: Icon(
                                      Icons.block,
                                      color: Colors.red[600],
                                      size: 30.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : Card();
              });
        } else {
          return Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(login_bg)),
          );
        }
      },
    );
  }

  FutureBuilder denied_list() {
    return FutureBuilder(
      future: getUserRequests(),
      builder: (context, data) {
        if (data.hasError) {
          return Center(child: Text("${data.error}"));
        } else if (data.hasData) {
          var items = data.data as List<RequestSelect>;
          return ListView.builder(
              // reverse: true,
              itemCount: items == null ? 0 : items.length,
              itemBuilder: (context, index) {
                return !cond(items[index].day_access)
                    ? Card(
                        elevation: 5,
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Container(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 8, right: 8),
                                      child: Text(
                                        items[index].feature.toString(),
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 8, right: 8),
                                      child: Text(
                                        // items[index].email.toString(),
                                        "To " +
                                            capital(items[index]
                                                .requester_name
                                                .toString()) +
                                            " between " +
                                            timeFormat(items[index]
                                                .start_time
                                                .toString()) +
                                            " to " +
                                            timeFormat(items[index]
                                                .end_time
                                                .toString()),
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 8, right: 8),
                                      child: cond(items[index].day_access)
                                          ? Text(
                                              // items[index].email.toString(),
                                              "Allowed",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: login_bg,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            )
                                          : Text(
                                              // items[index].email.toString(),
                                              "Denied",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.red,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                    )
                                  ],
                                ),
                              )),
                              Wrap(
                                spacing:
                                    25, // to apply margin in the main axis of the wrap
                                runSpacing: 25,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      primary: login_bg,
                                      backgroundColor: login_bg_light,
                                      side:
                                          BorderSide(color: login_bg, width: 1),
                                      shape: StadiumBorder(),
                                    ),
                                    onPressed: () {
                                      allowDenyControlller(
                                          1,
                                          items[index].requester_id,
                                          items[index].feature_id);
                                    },
                                    child: Icon(
                                      Icons.check,
                                      color: login_bg,
                                      size: 30.0,
                                    ),
                                  ),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      primary: login_bg,
                                      backgroundColor: Colors.red[50],
                                      side: BorderSide(
                                          color: Colors.red, width: 1),
                                      shape: StadiumBorder(),
                                    ),
                                    onPressed: () {
                                      allowDenyControlller(
                                          0,
                                          items[index].requester_id,
                                          items[index].feature_id);
                                    },
                                    child: Icon(
                                      Icons.block,
                                      color: Colors.red[600],
                                      size: 30.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : Card();
              });
        } else {
          return Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(login_bg)),
          );
        }
      },
    );
  }

  //Time Formatter
  timeFormat(String string) {
    DateTime dateTime = DateTime.parse(string);
    return DateFormat('hh:mm a').format(dateTime);
  }

  //Allowed/Denied Condition Operator
  bool cond(String data) {
    if (data == '1') {
      return true;
    } else {
      return false;
    }
  }

  //First letter Capital
  capital(String string) {
    return intl.toBeginningOfSentenceCase(string);
  }

  //Logout function
  logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
        (Route<dynamic> route) => false);
  }
}
