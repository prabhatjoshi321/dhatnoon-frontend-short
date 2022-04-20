import 'package:carousel_slider/carousel_slider.dart';
import 'package:dhatnoon/Loadingpage/loadingpage.dart';
import 'package:flutter/material.dart';
import '..//utils/theme.dart';
import '../widgets/cache_image_widget.dart';
import '../widgets/see_all_text.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'main_slide_tile.dart';
import 'main_slider.dart';

//dependencies to be shifted
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dhatnoon/constants.dart';
import 'package:dhatnoon/providers/approved_requests.dart';
import 'package:dhatnoon/providers/request_select.dart';
import 'dart:convert';
import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';

class HomeMain extends StatefulWidget {
  HomeMain({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  _HomeMainState createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  int slideIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Greeter flag
  bool greeter = true;

  late Size _size;
  // late List<dynamic> list;
  late List<dynamic> approved_requests;
  late List<dynamic> request_select;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: homeView(),
    );
  }

  Widget homeView() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 5,
      physics: ClampingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SeeAllText(
                      text: widget.index == 0
                          ? "Approved requests"
                          : "Requests sent to you",
                      callBack: () {
                        setState(() {});
                      }),
                  SizedBox(
                    width: _size.width * .05,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Center(
                      child: widget.index == 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // TODO list of pending/rejected REQUESTS
                                TextButton(
                                    onPressed: () {
                                      showModalBottomSheet<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    child: requests()));
                                          });
                                    },
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.pending_actions_outlined,
                                          color: Styles.blackColor,
                                        ),
                                        Text(
                                          '',
                                          style: TextStyle(
                                              color: Styles.blackColor),
                                        ),
                                      ],
                                    )),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // TODO REJECTED BY YPU
                                TextButton(
                                    onPressed: () {
                                      showModalBottomSheet<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    child: denied_list()));
                                          });
                                    },
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.block_outlined,
                                          color: Styles.blackColor,
                                        ),
                                        Text(
                                          '',
                                          style: TextStyle(
                                              color: Styles.blackColor),
                                        ),
                                      ],
                                    )),
                                // TODO ACCEPTED BY YOU
                                TextButton(
                                    onPressed: () {
                                      showModalBottomSheet<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    child: approved_list()));
                                          });
                                    },
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Styles.blackColor,
                                        ),
                                        Text(
                                          '',
                                          style: TextStyle(
                                              color: Styles.blackColor),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                    ),
                  ),
                ]);
          case 1:
            return SizedBox(
              height: 15,
            );
          case 2:
            return widget.index == 0 ? _mainSliderfetch() : _mainSliderallow();
          case 3:
            return SizedBox(
              height: 30,
            );

          default:
            return Container();
        }
      },
    );
  }

  Future<List<RequestSelect>> allow() async {
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
      request_select = map["data"];
      if (request_select.isEmpty) {
        greeter = true;
      } else {
        greeter = false;
      }
      // print(widget.index);
      // print("allow/deny $token");
      print(response.body);
    } catch (error) {
      print(error);
    }
    return request_select.map((e) => RequestSelect.fromJson(e)).toList();
  }

  Widget _mainSliderallow() {
    return Container(
      height: _size.height * 0.55,
      margin: EdgeInsets.only(top: 15),
      child: FutureBuilder(
          future: allow(),
          builder: (context, data) {
            if (data.hasError) {
              return Center(child: Text("${data.error}"));
              // return Center(child: Text("No Users"));
            }
            //  else if (greeter) {
            //   return Center(
            //       child: Image.asset(
            //     "assets/hi.gif",
            //     // width: 100,
            //     // height: 100,
            //     fit: BoxFit.fitWidth,
            //   ));
            // }
            else if (data.hasData) {
              var items = data.data as List<RequestSelect>;
              return MainSlider(
                items: List.generate(
                    request_select.length,
                    (index) => MainSlideTile(
                          index: index,
                          pageindex: widget.index,
                          list: request_select,
                        )),
                callbackFunction:
                    (int index, CarouselPageChangedReason reason) {
                  setState(() {
                    slideIndex = index;
                  });
                },
              );
            } else {
              return RotatingWaves(
                centered: true,
              );
            }
          }),
    );
  }

  Future<List<ApprovedRequests>> fetch() async {
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
      approved_requests = map["data"];
      if (approved_requests.isEmpty) {
        greeter = true;
      } else {
        greeter = false;
      }
      // print(widget.index);
      print(response.body);
      print("fetch");
    } catch (error) {
      print(error);
    }
    return approved_requests.map((e) => ApprovedRequests.fromJson(e)).toList();
  }

  Widget _mainSliderfetch() {
    return Container(
      height: _size.height * 0.55,
      margin: EdgeInsets.only(top: 15),
      child: FutureBuilder(
          future: fetch(),
          builder: (context, data) {
            if (data.hasError) {
              // return Center(child: Text("${data.error}"));
              return Center(child: Text("No Users"));
            } else if (greeter) {
              return Center(
                  child: Image.asset(
                "assets/hi.gif",
                // width: 100,
                // height: 100,
                fit: BoxFit.fitWidth,
              ));
            } else if (data.hasData) {
              var items = data.data as List<ApprovedRequests>;
              return MainSlider(
                items: List.generate(
                    approved_requests.length,
                    (index) => MainSlideTile(
                          index: index,
                          pageindex: widget.index,
                          list: approved_requests,
                        )),
                callbackFunction:
                    (int index, CarouselPageChangedReason reason) {
                  setState(() {
                    slideIndex = index;
                  });
                },
              );
            } else {
              return RotatingWaves(
                centered: true,
              );
            }
          }),
    );
  }

  Widget _sliderPos() {
    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 15.0),
        child: AnimatedSmoothIndicator(
          count: widget.index == 0
              ? approved_requests.length
              : request_select.length,
          activeIndex: slideIndex,
          effect: ExpandingDotsEffect(
            activeDotColor: Styles.purpleColor,
            dotHeight: 6,
            strokeWidth: 1,
            dotWidth: 9,
            dotColor: Styles.purpleColor.withOpacity(0.5),
            expansionFactor: 1.8,
          ),
        ));
  }

  // ICONS on the approved request section

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

  FutureBuilder denied_list() {
    return FutureBuilder(
      future: allow(),
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

  FutureBuilder approved_list() {
    return FutureBuilder(
      future: allow(),
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

  FutureBuilder requests() {
    return FutureBuilder(
      future: allow(),
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
}
