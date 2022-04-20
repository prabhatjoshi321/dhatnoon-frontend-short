import 'package:flutter/foundation.dart';

class Location with ChangeNotifier {
  final String id;
  final String user_id;
  final String lat;
  final String long;
  // final String start_time;
  // final String end_time;
  // final String day_access;
  // final String created_at;
  // final String updated_at;

  Location({
    required this.id,
    required this.user_id,
    required this.lat,
    required this.long,
  });
}
