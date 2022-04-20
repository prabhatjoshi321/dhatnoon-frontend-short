import 'package:dhatnoon/audiopage.dart';
import 'package:dhatnoon/locationpage.dart';
import 'package:dhatnoon/videopage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dhatnoon/constants.dart';
import '../utils/theme.dart';
import 'package:get/get.dart';

import 'cache_image_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ItemView extends StatefulWidget {
  ItemView({
    Key? key,
    required this.list,
    required this.pageindex,
    required this.index,
    required this.allowdenyfunc,
    required this.onView,
  }) : super(key: key);

  final List<dynamic> list;

  ///[title] Item's pageindex
  final int pageindex;

  ///[title] Item's index
  final int index;

  ///[onView] Item's press callback
  final Function() onView;

  ///[favOnPress] Item's fav press callback
  final Function() allowdenyfunc;

  @override
  _ItemViewState createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  late Size _size;

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;

    return GestureDetector(
        onTap: widget.onView, child: widget.pageindex == 0 ? fetch() : allow());
  }

  Container allow() {
    return Container(
      height: _size.height,
      width: _size.width,
      margin: EdgeInsets.only(right: 5, left: 5),
      child: Stack(
        children: <Widget>[
          // The containers in the background
          Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  color: Theme.of(context).cardColor,
                ),
                height: _size.height * 0.55,
                width: _size.width,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              widget.list[widget.index]["feature"],
                              maxLines: 2,
                              overflow: TextOverflow.fade,
                              style: Get.textTheme.headline3!
                                  .copyWith(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "was requested by",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Get.textTheme.headline4!.copyWith(fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        widget.list[widget.index]["requester_name"],
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: Get.textTheme.headline6!.copyWith(fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "between",
                        maxLines: 4,
                        overflow: TextOverflow.fade,
                        style: Get.textTheme.headline4!.copyWith(fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${Constants.timeFormat(widget.list[widget.index]["start_time"])} to ${Constants.timeFormat(widget.list[widget.index]["end_time"])}",
                        maxLines: 4,
                        overflow: TextOverflow.fade,
                        style: Get.textTheme.headline5!.copyWith(fontSize: 16),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.all(0),
                        // child: cond(items[index].day_access)
                        child: Constants.condition(widget.list[widget.index]
                                    ["day_access"]
                                .toString())
                            ? Text(
                                "Allowed",
                                maxLines: 4,
                                overflow: TextOverflow.fade,
                                style: Get.textTheme.headline5!
                                    .copyWith(fontSize: 16),
                              )
                            : Text(
                                "Denied",
                                maxLines: 4,
                                overflow: TextOverflow.fade,
                                style: Get.textTheme.headline5!
                                    .copyWith(fontSize: 16),
                              ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              primary: Theme.of(context).hoverColor,
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              side: BorderSide(
                                  color: Styles.darkblueColor, width: 1),
                              shape: StadiumBorder(),
                            ),
                            onPressed: () {
                              allowDenyControlller(
                                  1,
                                  widget.list[widget.index]["requester_id"],
                                  widget.list[widget.index]["feature_id"]);
                            },
                            child: Icon(
                              Icons.check,
                              color: Styles.darkblueColor,
                              size: 30.0,
                            ),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              primary: Theme.of(context).hoverColor,
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              side: BorderSide(
                                  color: Styles.darkblueColor, width: 1),
                              shape: StadiumBorder(),
                            ),
                            onPressed: () {
                              allowDenyControlller(
                                  0,
                                  widget.list[widget.index]["requester_id"],
                                  widget.list[widget.index]["feature_id"]);
                            },
                            child: Icon(
                              Icons.block,
                              color: Styles.darkblueColor,
                              size: 30.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Container fetch() {
    return Container(
      height: _size.height,
      width: _size.width,
      margin: EdgeInsets.only(right: 5, left: 5),
      child: Stack(
        children: <Widget>[
          // The containers in the background
          Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  color: Theme.of(context).cardColor,
                ),
                height: _size.height * 0.55,
                width: _size.width,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "View",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Get.textTheme.headline4!.copyWith(fontSize: 16),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              widget.list[widget.index]["feature"],
                              maxLines: 2,
                              overflow: TextOverflow.fade,
                              style: Get.textTheme.headline3!
                                  .copyWith(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "of",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Get.textTheme.headline4!.copyWith(fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        widget.list[widget.index]["user_name"],
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: Get.textTheme.headline6!.copyWith(fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "allowed from",
                        maxLines: 4,
                        overflow: TextOverflow.fade,
                        style: Get.textTheme.headline4!.copyWith(fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${Constants.timeFormat(widget.list[widget.index]["start_time"])} to ${Constants.timeFormat(widget.list[widget.index]["end_time"])}",
                        maxLines: 4,
                        overflow: TextOverflow.fade,
                        style: Get.textTheme.headline5!.copyWith(fontSize: 16),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                primary: Theme.of(context).hoverColor,
                                backgroundColor:
                                    Theme.of(context).backgroundColor,
                                side: BorderSide(
                                    color: Styles.darkblueColor, width: 1),
                                shape: StadiumBorder(),
                              ),
                              onPressed: () => pageRedirector(
                                  widget.list[widget.index]["user_id"],
                                  widget.list[widget.index]["feature_id"]),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'View',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Styles.darkblueColor),
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  //
  //
  // allow/deny controller handler
  //
  //

  allowDenyControlller(int option, int requester_id, int feature_id) async {
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
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        print(response.body);
        Constants.snackBar(json['message'], context);
      });
    } else {
      setState(() {
        print(response.body);
        print(token);
        Constants.snackBar(json['message'], context);
      });
    }
  }

  //
  //
  // Page redirector
  //
  //

  pageRedirector(int user_id, feature_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("approved_user_id", user_id.toString());
    sharedPreferences.setString(
        "approved_user_feature_id", feature_id.toString());
    print(user_id + feature_id);
    if (feature_id == 1) {
      setState(() {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LocationPage()));
      });
    } else if (feature_id == 2) {
      print('Front Camera Pic.');
      fetchUserImage('front', user_id);
      setState(() {
        // _isLoading = true;
      });
    } else if (feature_id == 3) {
      print('Back Camera Pic.');
      fetchUserImage('rear', user_id);
      setState(() {
        // _isLoading = true;
      });
    } else if (feature_id == 4) {
      print('Front Camera Streaming.');
      videoScreen('front', user_id);
    } else if (feature_id == 5) {
      print('Back Camera Streaming.');
      videoScreen('rear', user_id);
    } else if (feature_id == 6) {
      print('Front Camera 10 Second Video.');
      videoScreen10('front', user_id);
    } else if (feature_id == 7) {
      print('Back camera 10 Second Video.');
      videoScreen10('rear', user_id);
    } else if (feature_id == 8) {
      Constants.snackBar('Audio Live Streaming.', context);
      audioScreen(user_id);
    } else if (feature_id == 9) {
      print('10 Second Audio Recording.');
      audioScreen10(user_id);
    }
  }

  //
  //
  //feature widgets
  //
  //

  //
  //
  // Image View Section
  //
  //

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
      Constants.snackBar("Fetching user Frontcam.", context);

      erer = await http.post(Uri.parse(url + '/call_user_frontcam'),
          body: data, headers: headers);
    } else {
      Constants.snackBar("Fetching user rearcam.", context);
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
        Constants.snackBar("done", context);
        print(jsonData['url']);
        var imgUrl = jsonData['url'];
        setState(() {
          // _isLoading = false;
          _showImageDialog(imgUrl);
        });
      } else {
        Constants.snackBar(jsonData["data"], context);
        // if (jsonData["error"] == "1") {
        Constants.snackBar("Trying again in 10 sec.", context);
        Timer(Duration(seconds: 10), () async {
          fetchUserImage(option, user_id);
        });
        // }
      }
    });
  }

  Future<void> _showImageDialog(String imgUrl) async {
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

  //
  //
  // Video View Section
  //
  //

  videoScreen(String option, int user_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    Map<String, String> data = {"user_id": user_id.toString()};
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
        Constants.snackBar(
            "Something went wrong. Streams not passing through", context);
      }
    });
  }

  //
  //
  // 10 second Video View Section
  //
  //

  videoScreen10(String option, int user_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    Map<String, String> data = {"user_id": user_id.toString()};
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
        Constants.snackBar(
            "Something went wrong. Streams not passing through", context);
      }
    });
  }

  //
  //
  // Audio View Section
  //
  //

  audioScreen(int user_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    Map<String, String> data = {"user_id": user_id.toString()};
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
        Constants.snackBar(
            "Something went wrong. Streams not passing through", context);
      }
    });
  }

  //
  //
  // 10 second Audio View Section
  //
  //

  audioScreen10(int user_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    Map<String, String> data = {"user_id": user_id.toString()};
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
        Constants.snackBar(
            "Something went wrong. Streams not passing through", context);
      }
    });
  }
}
