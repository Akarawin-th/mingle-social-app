import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'post_model.dart';
import '../../core/services/cloud_database_service.dart';
import '../../core/services/auth_service.dart';
import '../auth/auth_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final CloudDatabaseService _dbService = CloudDatabaseService();
  final AuthService _authService = AuthService();

  User? get currentUser => FirebaseAuth.instance.currentUser;

  String _getUserEmail() {
    return currentUser?.email ?? 'ไม่มีอีเมล';
  }

  String _getDisplayName() {
    return currentUser?.displayName ?? _getUserEmail().split('@')[0];
  }

  void _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'เมื่อสักครู่';
    if (diff.inHours < 1) return '${diff.inMinutes} นาทีที่แล้ว';
    if (diff.inDays < 1) return '${diff.inHours} ชั่วโมงที่แล้ว';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: _getDisplayName());
    final photoController = TextEditingController(
      text: currentUser?.photoURL ?? '',
    );
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'แก้ไขโปรไฟล์',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF1877F2).withOpacity(0.1),
                  backgroundImage: photoController.text.isNotEmpty
                      ? NetworkImage(photoController.text)
                      : null,
                  child: photoController.text.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: Color(0xFF1877F2),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'ชื่อแสดงผล',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: photoController,
                  onChanged: (val) => setStateDialog(() {}),
                  decoration: InputDecoration(
                    labelText: 'ลิงก์รูปโปรไฟล์ (URL)',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text(
                  'ยกเลิก',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        setStateDialog(() => isSaving = true);
                        await currentUser?.updateDisplayName(
                          nameController.text.trim(),
                        );
                        await currentUser?.updatePhotoURL(
                          photoController.text.trim().isNotEmpty
                              ? photoController.text.trim()
                              : null,
                        );
                        await currentUser?.reload();
                        setState(() {});
                        if (context.mounted) Navigator.pop(context);
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('บันทึก'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPostDialog({PostModel? existingPost}) {
    final isEdit = existingPost != null;
    final TextEditingController contentController = TextEditingController(
      text: isEdit ? existingPost.content : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            isEdit ? 'แก้ไขโพสต์' : 'สร้างโพสต์ใหม่',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: TextField(
            controller: contentController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'คุณกำลังคิดอะไรอยู่?',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'ยกเลิก',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                if (contentController.text.trim().isEmpty) return;

                if (isEdit) {
                  await _dbService.updatePost(
                    existingPost.id,
                    contentController.text,
                  );
                } else {
                  final newPost = PostModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    authorName: _getDisplayName(),
                    authorEmail: _getUserEmail(),
                    authorPhotoUrl:
                        currentUser?.photoURL, // <-- ส่งรูปลงฐานข้อมูลตรงนี้
                    content: contentController.text,
                    timestamp: DateTime.now(),
                  );
                  await _dbService.createPost(newPost);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(
                isEdit ? 'บันทึก' : 'โพสต์',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReactionMenu(BuildContext context, String postId, String myEmail) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => AlertDialog(
        elevation: 12,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEmojiBtn('👍', postId, context, myEmail),
            _buildEmojiBtn('❤️', postId, context, myEmail),
            _buildEmojiBtn('😂', postId, context, myEmail),
            _buildEmojiBtn('😮', postId, context, myEmail),
            _buildEmojiBtn('😢', postId, context, myEmail),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiBtn(
    String emoji,
    String postId,
    BuildContext context,
    String myEmail,
  ) {
    return InkWell(
      onTap: () {
        _dbService.toggleReaction(postId, myEmail, emoji);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }

  void _showCommentsSheet(BuildContext context, PostModel initialPost) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                'ความคิดเห็น',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: StreamBuilder<PostModel>(
                  stream: _dbService.getPostStream(initialPost.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData)
                      return const Center(child: Text('ไม่พบโพสต์'));

                    final comments = snapshot.data!.comments;
                    if (comments.isEmpty)
                      return Center(
                        child: Text(
                          'ยังไม่มีความคิดเห็น\nเป็นคนแรกที่แสดงความคิดเห็นสิ!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      );

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final isMyComment =
                            comment.authorEmail == _getUserEmail();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ดึงรูปโปรไฟล์ของคนคอมเมนต์มาแสดง
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFF1877F2)
                                    .withOpacity(0.1),
                                backgroundImage:
                                    comment.authorPhotoUrl != null &&
                                        comment.authorPhotoUrl!.isNotEmpty
                                    ? NetworkImage(comment.authorPhotoUrl!)
                                    : null,
                                child:
                                    comment.authorPhotoUrl == null ||
                                        comment.authorPhotoUrl!.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Color(0xFF1877F2),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment.authorName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            comment.text,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        top: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            _getTimeAgo(comment.timestamp),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          if (isMyComment) ...[
                                            const SizedBox(width: 16),
                                            InkWell(
                                              onTap: () =>
                                                  _dbService.deleteComment(
                                                    initialPost.id,
                                                    comment,
                                                  ),
                                              child: Text(
                                                'ลบ',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade800,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'เขียนความคิดเห็น...',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF1877F2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () async {
                          if (commentController.text.trim().isEmpty) return;
                          final newComment = CommentModel(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            authorName: _getDisplayName(),
                            authorEmail: _getUserEmail(),
                            authorPhotoUrl: currentUser
                                ?.photoURL, // <-- ส่งรูปลงคอมเมนต์ด้วย
                            text: commentController.text.trim(),
                            timestamp: DateTime.now(),
                          );
                          commentController.clear();
                          FocusScope.of(context).unfocus();
                          await _dbService.addComment(
                            initialPost.id,
                            newComment,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F9),
      appBar: AppBar(
        title: const Text(
          'Mingle',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF1877F2),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Stack(
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF1877F2)),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: currentUser?.photoURL != null
                        ? NetworkImage(currentUser!.photoURL!)
                        : null,
                    child: currentUser?.photoURL == null
                        ? const Icon(
                            Icons.person,
                            color: Color(0xFF1877F2),
                            size: 40,
                          )
                        : null,
                  ),
                  accountName: Text(
                    _getDisplayName(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  accountEmail: Text(
                    _getUserEmail(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditProfileDialog(context);
                    },
                  ),
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'ออกจากระบบ',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(
              top: 12,
              left: 16,
              right: 16,
              bottom: 4,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF1877F2).withOpacity(0.1),
                  backgroundImage: currentUser?.photoURL != null
                      ? NetworkImage(currentUser!.photoURL!)
                      : null,
                  child: currentUser?.photoURL == null
                      ? const Icon(Icons.person, color: Color(0xFF1877F2))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _showPostDialog(),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'คุณกำลังคิดอะไรอยู่?',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<PostModel>>(
              stream: _dbService.getPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1877F2)),
                  );
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return Center(
                    child: Text(
                      'ยังไม่มีโพสต์เลย!',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );

                final posts = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 40),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final isMyPost = post.authorEmail == _getUserEmail();

                    final allReactions = post.reactions.values.toList();
                    final totalReactions = allReactions.length;
                    final uniqueEmojis = allReactions
                        .where((e) => e != '👍')
                        .toSet()
                        .toList();

                    final safeEmail = _getUserEmail().replaceAll('.', '_');
                    final myReaction = post.reactions[safeEmail];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // ดึงรูปโปรไฟล์ของคนโพสต์มาแสดง
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFF1877F2)
                                    .withOpacity(0.1),
                                backgroundImage:
                                    post.authorPhotoUrl != null &&
                                        post.authorPhotoUrl!.isNotEmpty
                                    ? NetworkImage(post.authorPhotoUrl!)
                                    : null,
                                child:
                                    post.authorPhotoUrl == null ||
                                        post.authorPhotoUrl!.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        color: Color(0xFF1877F2),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.authorName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      _getTimeAgo(post.timestamp),
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isMyPost)
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_horiz,
                                    color: Colors.grey.shade600,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onSelected: (value) async {
                                    if (value == 'edit')
                                      _showPostDialog(existingPost: post);
                                    else if (value == 'delete')
                                      await _dbService.deletePost(post.id);
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('แก้ไข'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'ลบ',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              else
                                const SizedBox(width: 48, height: 48),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            post.content,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (totalReactions > 0 || post.comments.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (totalReactions > 0 &&
                                        allReactions.contains('👍'))
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF1877F2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.thumb_up,
                                          size: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    if (uniqueEmojis.isNotEmpty) ...[
                                      if (allReactions.contains('👍'))
                                        const SizedBox(width: 4),
                                      Text(
                                        uniqueEmojis.join(''),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                    if (totalReactions > 0) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '$totalReactions',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (post.comments.isNotEmpty)
                                  InkWell(
                                    onTap: () =>
                                        _showCommentsSheet(context, post),
                                    child: Text(
                                      '${post.comments.length} ความคิดเห็น',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                          if (totalReactions > 0 || post.comments.isNotEmpty)
                            const SizedBox(height: 8),

                          Divider(
                            color: Colors.grey.shade200,
                            height: 1,
                            thickness: 1,
                          ),
                          const SizedBox(height: 4),

                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _dbService.toggleReaction(
                                    post.id,
                                    _getUserEmail(),
                                    '👍',
                                  ),
                                  onLongPress: () => _showReactionMenu(
                                    context,
                                    post.id,
                                    _getUserEmail(),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    color: Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (myReaction == null ||
                                            myReaction == '👍')
                                          Icon(
                                            myReaction == '👍'
                                                ? Icons.thumb_up
                                                : Icons.thumb_up_alt_outlined,
                                            color: myReaction == '👍'
                                                ? const Color(0xFF1877F2)
                                                : Colors.grey.shade600,
                                            size: 20,
                                          )
                                        else
                                          Text(
                                            myReaction,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),

                                        const SizedBox(width: 8),
                                        Text(
                                          myReaction != null &&
                                                  myReaction != '👍'
                                              ? 'ความรู้สึก'
                                              : 'ถูกใจ',
                                          style: TextStyle(
                                            color: myReaction != null
                                                ? const Color(0xFF1877F2)
                                                : Colors.grey.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      _showCommentsSheet(context, post),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          color: Colors.grey.shade600,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'ความคิดเห็น',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
