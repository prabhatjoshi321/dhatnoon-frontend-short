// import 'dart:ffi';
import 'dart:math';

import 'package:dhatnoon/Loadingpage/loadingpage.dart';
import 'package:dhatnoon/Mainpage/Design/utils/DarkThemeProvider.dart';
import 'package:dhatnoon/loginpage.dart';
import 'package:dhatnoon/navigationpage.dart';
import 'package:dhatnoon/videopage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'constants.dart';
import 'providers/userlist.dart';
import 'Mainpage/Design/utils/theme.dart';
import 'Mainpage/Design/utils/DarkThemeProvider.dart';
import 'package:provider/provider.dart';

import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  bool _isLoadBar = false;

  bool _isShowCamera = false;
  bool _isLogin = false;
  //Location Variables
  double lat = 0;
  double long = 0;
  Position? _currentPosition;
  GoogleMapController? mapController;
  final Map<String, Marker> _markers = {};

  late Size _size;
  late AnimationController _animationController;
  late Animation<double> _animationTextRotate;

  void setUpAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: defaultDuration);
    _animationTextRotate =
        Tween<double>(begin: 0, end: 90).animate(_animationController);
  }

  void updateView() {
    setState(() {
      _isShowCamera = !_isShowCamera;
    });
    _isShowCamera
        ? _animationController.forward()
        : _animationController.reverse();
  }

  @override
  void initState() {
    setUpAnimation();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    mapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);

    _size = MediaQuery.of(context).size;
    return Center(child: locationBody(themeProvider));
  }

  Widget locationBody(DarkThemeProvider themeProvider) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
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
            title: Text("Live Location",
                style: TextStyle(color: Styles.blackColor)),
            elevation: 0,
            actions: [
              OutlinedButton(
                  onPressed: () {
                    mapRefresher();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      width: 0.0,
                      color: Colors.white,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                    child: Column(
                      children: [
                        Icon(
                          Icons.refresh,
                          color: Theme.of(context).disabledColor,
                          size: 30.0,
                        ),
                      ],
                    ),
                  ))
            ],
          ),
          body: Container(
              child: _isLoading
                  ? RotatingWaves(
                      centered: true,
                    )
                  : bodyContent()),
        ),
      ),
    );
  }

//Body builder content

  bodyContent() {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return Stack(
            children: [
              AnimatedPositioned(
                duration: defaultDuration,
                width: _size.width * 1,
                height: _size.height * 0.9,
                top: _size.height * 0.0001,
                left: _isShowCamera ? -_size.width * 1 : _size.width * 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: updateView,
                  child: Container(
                    color: Colors.white,
                    child: !_isShowCamera ? map() : Column(),
                  ),
                ),
              ),
              AnimatedPositioned(
                  duration: defaultDuration,
                  width: _size.width * 1,
                  height: _size.height,
                  left: _isShowCamera ? _size.width * 0 : _size.width * 1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: updateView,
                    child: Container(
                      color: Colors.white,
                      child: Column(),
                    ),
                  )),
              Positioned(
                  // duration: defaultDuration,
                  bottom: _isShowCamera ? 0 : _size.height * 0.45,
                  left: _isShowCamera ? 0 : _size.width * 0.45,
                  child: _isLoadBar
                      ? Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Styles.darkblueColor)))
                      : Column()),
            ],
          );
        });
  }

  mapRefresher() async {
    updateView();
    Timer(Duration(milliseconds: 50), () {
      updateView();
    });
  }

//Location section

  Container map() {
    return Container(
      height: MediaQuery.of(context).size.height / 1.5,
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 2,
        ),
        markers: _markers.values.toSet(),
      ),
    );
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _isLoadBar = true;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    var approved_user_id = sharedPreferences.getString('approved_user_id');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    };

    Map<String, dynamic> data = {
      "user_id": approved_user_id,
    };

    var erer = await http.post(Uri.parse(url + '/call_user_location'),
        body: data, headers: header);

    print(erer.body);
    Timer(Duration(seconds: 10), () async {
      setState(() {
        _isLoadBar = false;
      });
      var response = await http.post(Uri.parse(url + '/get_user_location'),
          body: data, headers: header);

      var jsonData = jsonDecode(response.body);
      lat = double.parse(jsonData['lat']);
      long = double.parse(jsonData['long']);
      print(lat);
      print(long);
      setState(() {
        mapController = controller;
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 270.0,
              target: LatLng(lat, long),
              tilt: 30.0,
              zoom: 10.0,
            ),
          ),
        );
        _markers.clear();
        final marker = Marker(
          markerId: MarkerId("User"),
          position: LatLng(lat, long),
          infoWindow: InfoWindow(
            title: "Location",
            snippet: "office.address",
          ),
        );
        _markers["User"] = marker;
      });
    });
  }
}
