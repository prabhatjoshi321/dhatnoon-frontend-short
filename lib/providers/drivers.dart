import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'driver.dart';

class Drivers with ChangeNotifier {
  List<Driver> _items = [
    Driver(id: '2', name: 'asdf', email: 'adsf@asdf.com', usertype: '1')
  ];
}
