import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../providers/location.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class Locations with ChangeNotifier {
  // List<Location> _items = [];

  addLocation(Location location) async {
    const URL = 'http://10.10.10.1:8000/api/auth/location_save';
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    Map<String, String> data = {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    };
    http.post(Uri.parse(URL),
        body: json.encode({'lat': location.lat, 'long': location.long}),
        headers: data);
  }
}
