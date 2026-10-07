import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/feed/post_model.dart';

class CloudDatabaseService {
  final CollectionReference _postsCollection = FirebaseFirestore.instance
      .collection('posts');

  Future<void> createPost(PostModel post) async {
    await _postsCollection.doc(post.id).set(post.toMap());
  }

  PostModel _postFromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    Map<String, String> parsedReactions = {};
    if (data['reactions'] != null && data['reactions'] is Map) {
      final reactionsMap = data['reactions'] as Map;
      for (var key in reactionsMap.keys) {
        if (reactionsMap[key] is String) {
          parsedReactions[key.toString()] = reactionsMap[key].toString();
        }
      }
    }

    List<CommentModel> parsedComments = [];
    if (data['comments'] != null && data['comments'] is List) {
      for (var c in (data['comments'] as List)) {
        if (c is Map) {
          parsedComments.add(
            CommentModel.fromMap(Map<String, dynamic>.from(c)),
          );
        }
      }
    }

    return PostModel(
      id: data['id']?.toString() ?? doc.id,
      authorName: data['authorName']?.toString() ?? 'ไม่ระบุชื่อ',
      authorEmail: data['authorEmail']?.toString() ?? '',
      authorPhotoUrl: data['authorPhotoUrl']
          ?.toString(), // แปลงลิงก์รูปตอนดึงข้อมูล
      content: data['content']?.toString() ?? '',
      reactions: parsedReactions,
      comments: parsedComments,
      timestamp: data['timestamp'] != null
          ? DateTime.tryParse(data['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Stream<List<PostModel>> getPosts() {
    return _postsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => _postFromSnapshot(doc)).toList();
        });
  }

  Stream<PostModel> getPostStream(String postId) {
    return _postsCollection
        .doc(postId)
        .snapshots()
        .map((doc) => _postFromSnapshot(doc));
  }

  Future<void> updatePost(String id, String newContent) async {
    await _postsCollection.doc(id).update({'content': newContent});
  }

  Future<void> deletePost(String id) async {
    await _postsCollection.doc(id).delete();
  }

  Future<void> toggleReaction(String postId, String email, String emoji) async {
    final safeEmail = email.replaceAll('.', '_');
    final docRef = _postsCollection.doc(postId);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> currentReactions = data['reactions'] != null
          ? Map<String, dynamic>.from(data['reactions'])
          : {};

      if (currentReactions[safeEmail] == emoji) {
        await docRef.update({'reactions.$safeEmail': FieldValue.delete()});
      } else {
        await docRef.update({'reactions.$safeEmail': emoji});
      }
    }
  }

  Future<void> addComment(String postId, CommentModel comment) async {
    await _postsCollection.doc(postId).update({
      'comments': FieldValue.arrayUnion([comment.toMap()]),
    });
  }

  Future<void> deleteComment(String postId, CommentModel comment) async {
    await _postsCollection.doc(postId).update({
      'comments': FieldValue.arrayRemove([comment.toMap()]),
    });
  }
}
