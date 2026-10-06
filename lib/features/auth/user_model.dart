class UserModel {
  final String id;
  final String username;
  final String email;

  UserModel({required this.id, required this.username, required this.email});

  // แปลงข้อมูลเป็น Map เพื่อส่งขึ้น Local DB หรือ Cloud (เช่น Firebase)
  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'email': email};
  }

  // รับข้อมูลจาก Database มาแปลงเป็น Object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
