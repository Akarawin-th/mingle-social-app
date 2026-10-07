class CommentModel {
  final String id;
  final String authorName;
  final String authorEmail;
  final String? authorPhotoUrl; // เพิ่มช่องเก็บรูปคนคอมเมนต์
  final String text;
  final DateTime timestamp;

  CommentModel({
    required this.id,
    required this.authorName,
    required this.authorEmail,
    this.authorPhotoUrl,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'authorName': authorName,
    'authorEmail': authorEmail,
    'authorPhotoUrl': authorPhotoUrl,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
  };

  factory CommentModel.fromMap(Map<String, dynamic> map) => CommentModel(
    id: map['id'] ?? '',
    authorName: map['authorName'] ?? 'ไม่ระบุชื่อ',
    authorEmail: map['authorEmail'] ?? '',
    authorPhotoUrl: map['authorPhotoUrl'], // ดึงรูปกลับมา
    text: map['text'] ?? '',
    timestamp: map['timestamp'] != null
        ? DateTime.parse(map['timestamp'])
        : DateTime.now(),
  );
}

class PostModel {
  final String id;
  final String authorName;
  final String authorEmail;
  final String? authorPhotoUrl; // เพิ่มช่องเก็บรูปคนโพสต์
  final String content;
  final Map<String, String> reactions;
  final List<CommentModel> comments;
  final DateTime timestamp;

  PostModel({
    required this.id,
    required this.authorName,
    required this.authorEmail,
    this.authorPhotoUrl,
    required this.content,
    this.reactions = const {},
    this.comments = const [],
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorName': authorName,
      'authorEmail': authorEmail,
      'authorPhotoUrl': authorPhotoUrl, // ส่งรูปลงฐานข้อมูล
      'content': content,
      'reactions': reactions,
      'comments': comments.map((c) => c.toMap()).toList(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
