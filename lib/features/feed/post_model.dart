class PostModel {
  final String id;
  final String authorName;
  final String content;
  final int likes;
  final int dislikes;
  final DateTime timestamp;

  PostModel({
    required this.id,
    required this.authorName,
    required this.content,
    this.likes = 0,
    this.dislikes = 0,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorName': authorName,
      'content': content,
      'likes': likes,
      'dislikes': dislikes,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
