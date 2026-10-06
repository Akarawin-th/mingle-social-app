import 'package:flutter/material.dart';

import 'post_model.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // จำลอง Database ใน Local สำหรับทำ CRUD (ส่วน Read)
  List<PostModel> posts = [
    PostModel(
      id: '1',
      authorName: 'อาจารย์ ผู้ตรวจงาน',
      content: 'ยินดีต้อนรับสู่แอป Mingle! พื้นที่โซเชียลแบบไม่มีโฆษณา',
      timestamp: DateTime.now(),
    ),
  ];

  // จำลองฟังก์ชันเพิ่มโพสต์ (ส่วน Create)
  void _addNewPost() {
    setState(() {
      posts.insert(
        0,
        PostModel(
          id: DateTime.now().toString(),
          authorName: 'นักศึกษา (Me)',
          content: 'นี่คือโพสต์ใหม่ ทดสอบระบบ CRUD การโพสต์ข้อความ!',
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mingle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1877F2),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.authorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(post.content, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.thumb_up_alt_outlined),
                        onPressed: () {},
                      ),
                      Text('${post.likes}'),
                      const SizedBox(width: 16),
                      // ปุ่ม Dislike ตามที่คุณออกแบบไว้แก้ Pain Point!
                      IconButton(
                        icon: const Icon(Icons.thumb_down_alt_outlined),
                        onPressed: () {},
                      ),
                      Text('${post.dislikes}'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.comment_outlined),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPost,
        backgroundColor: const Color(0xFF1877F2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
