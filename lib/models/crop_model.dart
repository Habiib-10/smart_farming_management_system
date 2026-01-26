class Crop {
  final int? id;
  final String name;
  final String status;
  final int? userId;

  Crop({this.id, required this.name, required this.status, this.userId});

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'],
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      userId: json['user_id'], // Database-ka wuxuu isticmaalaa user_id
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "status": status,
      "user_id": userId, // MAGACAAN WAA INUU LA MID YAHAY BACKEND-KA
    };
  }
}