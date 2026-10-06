import 'package:flutter/material.dart';

import '../feed/feed_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;

  String _email = '';
  String _password = '';
  String _username = '';

  void _submit() {
    // ระบบ Error Handling: ตรวจสอบความถูกต้องของฟอร์มก่อนทำงาน
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLogin ? 'กำลังเข้าสู่ระบบ...' : 'กำลังสร้างบัญชี...',
          ),
          backgroundColor: const Color(0xFF1877F2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FeedScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Mingle',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1877F2),
                  ),
                ),
                const SizedBox(height: 40),
                if (!_isLogin)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'ชื่อผู้ใช้ (Username)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกชื่อผู้ใช้'; // Error Handling
                      }
                      return null;
                    },
                    onSaved: (value) => _username = value!,
                  ),
                if (!_isLogin) const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'อีเมล (Email)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        !value.contains('@')) {
                      return 'กรุณากรอกอีเมลให้ถูกต้อง'; // Error Handling
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'รหัสผ่าน (Password)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร'; // Error Handling
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value!,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _submit,
                    child: Text(
                      _isLogin ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'ยังไม่มีบัญชีใช่ไหม? สมัครสมาชิกเลย'
                        : 'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ',
                    style: const TextStyle(color: Color(0xFF1877F2)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
