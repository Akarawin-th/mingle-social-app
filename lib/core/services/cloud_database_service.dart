import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/feed/post_model.dart';

class CloudDatabaseService {
  // สร้างตารางเก็บข้อมูล (Collection) ชื่อ 'posts'
  final CollectionReference _postsCollection = FirebaseFirestore.instance
      .collection('posts');

  // C - Create (บันทึกโพสต์ใหม่ลง Cloud)
  Future<void> createPost(PostModel post) async {
    await _postsCollection.doc(post.id).set(post.toMap());
  }

  // R - Read (ดึงข้อมูลโพสต์ทั้งหมดแบบ Real-time)
  Stream<List<PostModel>> getPosts() {
    return _postsCollection
        .orderBy('timestamp', descending: true) // เรียงจากโพสต์ล่าสุดไปเก่า
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PostModel(
              id: doc['id'],
              authorName: doc['authorName'],
              content: doc['content'],
              likes: doc['likes'] ?? 0,
              dislikes: doc['dislikes'] ?? 0,
              timestamp: DateTime.parse(doc['timestamp']),
            );
          }).toList();
        });
  }

  // U - Update (อัปเดตแก้ไขข้อความในโพสต์เดิม)
  Future<void> updatePost(String id, String newContent) async {
    await _postsCollection.doc(id).update({'content': newContent});
  }

  // D - Delete (ลบโพสต์ออกจาก Cloud)
  Future<void> deletePost(String id) async {
    await _postsCollection.doc(id).delete();
  }
}
