import 'package:flutter/material.dart';

import 'post_model.dart';
import '../../core/services/cloud_database_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // เรียกใช้งาน Service ที่เชื่อมกับ Firebase
  final CloudDatabaseService _dbService = CloudDatabaseService();

  // กล่องข้อความสำหรับ Create (สร้าง) และ Update (แก้ไข)
  void _showPostDialog({PostModel? existingPost}) {
    final isEdit = existingPost != null;
    final TextEditingController contentController = TextEditingController(
      text: isEdit ? existingPost.content : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isEdit ? 'แก้ไขโพสต์' : 'สร้างโพสต์ใหม่',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: contentController,
            decoration: const InputDecoration(
              hintText: 'คุณกำลังคิดอะไรอยู่?',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (contentController.text.trim().isEmpty)
                  return; // Error Handling

                if (isEdit) {
                  // U - Update (ส่งข้อมูลแก้ไขขึ้น Cloud)
                  await _dbService.updatePost(
                    existingPost.id,
                    contentController.text,
                  );
                } else {
                  // C - Create (ส่งโพสต์ใหม่ขึ้น Cloud)
                  final newPost = PostModel(
                    id: DateTime.now().millisecondsSinceEpoch
                        .toString(), // สร้าง ID ไม่ซ้ำ
                    authorName: 'นักศึกษา (Me)', // เดี๋ยวเราค่อยดึงชื่อจริงจากระบบ Login ทีหลัง
                    content: contentController.text,
                    timestamp: DateTime.now(),
                  );
                  await _dbService.createPost(newPost);
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(isEdit ? 'บันทึก' : 'โพสต์'),
            ),
          ],
        );
      },
    );
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
        automaticallyImplyLeading: false,
      ),
      // R - Read (ใช้ StreamBuilder เพื่อดึงข้อมูลจาก Cloud แบบ Real-time)
      body: StreamBuilder<List<PostModel>>(
        stream: _dbService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            ); // แสดงวงกลมโหลดตอนดึงข้อมูล
          }
          if (snapshot.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('ยังไม่มีโพสต์ เริ่มต้นโพสต์แรกเลย!'),
            );
          }

          final posts = snapshot.data!;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            post.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_horiz,
                              color: Colors.grey,
                            ),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                _showPostDialog(existingPost: post);
                              } else if (value == 'delete') {
                                // D - Delete (ลบโพสต์ออกจาก Cloud)
                                await _dbService.deletePost(post.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('แก้ไขโพสต์'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'ลบโพสต์',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPostDialog(),
        backgroundColor: const Color(0xFF1877F2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
