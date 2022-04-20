class Data {
  final String id;
  final String name;
  final String email;
  final String usertype;
  final String created_at;
  final String updated_at;

  Data({
    required this.id,
    required this.name,
    required this.email,
    required this.usertype,
    required this.created_at,
    required this.updated_at,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'].toString(),
      name: json['name'].toString(),
      email: json['email'].toString(),
      usertype: json['usertype'].toString(),
      created_at: json['created_at'].toString(),
      updated_at: json['updated_at'].toString(),
    );
  }
}
