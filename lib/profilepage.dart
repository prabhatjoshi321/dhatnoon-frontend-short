// import 'dart:ffi';

import 'package:dhatnoon/Loadingpage/loadingpage.dart';
import 'package:dhatnoon/loginpage.dart';
import 'package:dhatnoon/navigationpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'Mainpage/Design/utils/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  String? username = '';
  String? email = '';
  String? userphno = '';

  late Size _size;

  @override
  void initState() {
    userDataGetter();
    super.initState();
  }

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
          onTap: () => _scaffoldKey.currentState!.openDrawer(),
          // splashColor: Theme.of(context).primaryColor,
          child: new Icon(
            Icons.menu,
            size: 24,
            color: Styles.darkblueColor,
          ),
        ),
        backgroundColor: Colors.white,
        title: Text("Profile", style: TextStyle(color: Styles.blackColor)),
        elevation: 0,
      ),
      body: Container(
          child: _isLoading
              ? Center(
                  child: RotatingWaves(
                  centered: true,
                ))
              : bodyContent()),
    );
  }

//Body builder content

  bodyContent() {
    return Container(
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              height: 100,
              child: Container(
                alignment: Alignment(0.0, 2.5),
                child: CircleAvatar(
                  backgroundImage: Image.asset('assets/bg.jpg').image,
                  radius: 60.0,
                ),
              ),
            ),
            SizedBox(
              height: 80,
            ),
            Text(
              "$username",
              style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.blueGrey,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "$email",
              style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black45,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w300),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "$userphno",
              style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black45,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w300),
            ),
            SizedBox(
              height: 100,
            ),
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    width: 2.0,
                    color: Theme.of(context).primaryColor,
                    style: BorderStyle.solid,
                  ),
                ),
                onPressed: () {
                  logOut();
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: Text(
                    'LogOut',
                    style: TextStyle(fontSize: 20, color: Styles.darkblueColor),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  //User data getter
  userDataGetter() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };

    var response = await http.get(Uri.parse(url + '/user'), headers: header);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        sharedPreferences.setString('user_data_name', jsonData['name']);
        sharedPreferences.setString('user_data_email', jsonData['email']);
        sharedPreferences.setString(
            'user_data_phone_number', jsonData['phone_number']);
        username = sharedPreferences.getString('user_data_name');
        email = sharedPreferences.getString('user_data_email');
        userphno = sharedPreferences.getString('user_data_phone_number');
      });
    } else {
      print(response.body);
      Constants.snackBar("Something went wrong", context);
    }
  }
  //End User Data Fetch

  //Logout function
  logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
        (Route<dynamic> route) => false);
  }
}
