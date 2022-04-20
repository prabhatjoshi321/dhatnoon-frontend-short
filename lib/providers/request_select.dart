class RequestSelect {
  final String permission_id;
  final String feature;
  final String feature_id;
  final String requester_id;
  final String? requester_name;
  final String requester_phno;
  final String start_time;
  final String end_time;
  final String day_access;

  RequestSelect({
    required this.permission_id,
    required this.feature,
    required this.feature_id,
    required this.requester_id,
    required this.requester_name,
    required this.requester_phno,
    required this.start_time,
    required this.end_time,
    required this.day_access,
  });

  factory RequestSelect.fromJson(Map<String, dynamic> json) {
    return RequestSelect(
      permission_id: json['permission_id'].toString(),
      feature: json['feature'].toString(),
      feature_id: json['feature_id'].toString(),
      requester_id: json['requester_id'].toString(),
      requester_name: json['requester_name'].toString(),
      requester_phno: json['requester_phno'].toString(),
      start_time: json['start_time'].toString(),
      end_time: json['end_time'].toString(),
      day_access: json['day_access'].toString(),
    );
  }
}
