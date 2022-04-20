import 'package:flutter/foundation.dart';

class Driver with ChangeNotifier {
  final String id;
  final String name;
  final String email;
  final String usertype;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.usertype,
  });
}
