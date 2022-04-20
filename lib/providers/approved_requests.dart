class ApprovedRequests {
  final String user_id;
  final String feature;
  final String feature_id;
  final String user_name;
  final String user_phno;
  final String start_time;
  final String end_time;

  ApprovedRequests({
    required this.user_id,
    required this.feature,
    required this.feature_id,
    required this.user_name,
    required this.user_phno,
    required this.start_time,
    required this.end_time,
  });

  factory ApprovedRequests.fromJson(Map<String, dynamic> json) {
    return ApprovedRequests(
      user_id: json['user_id'].toString(),
      feature: json['feature'].toString(),
      feature_id: json['feature_id'].toString(),
      user_name: json['user_name'].toString(),
      user_phno: json['user_phno'].toString(),
      start_time: json['start_time'].toString(),
      end_time: json['end_time'].toString(),
    );
  }
}
