import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../feed/feed_screen.dart';
import '../../core/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLogin = true;
  bool _isLoading = false;

  String _email = '';
  String _password = '';
  String _username = '';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        if (_isLogin) {
          await _authService.signInWithEmailPassword(_email, _password);
        } else {
          await _authService.signUpWithEmailPassword(_email, _password);
        }

        // ล็อกอินสำเร็จ เปลี่ยนไปหน้า Feed
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FeedScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = 'เกิดข้อผิดพลาด กรุณาลองใหม่';
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          message = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
        } else if (e.code == 'email-already-in-use') {
          message = 'อีเมลนี้มีผู้ใช้งานในระบบแล้ว';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'M',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1877F2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        right: 2.0,
                        left: 2.0,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.chat_bubble,
                            color: Color(0xFF1877F2),
                            size: 36,
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 4.0),
                            child: const Text(
                              'i',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'ngle',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1877F2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                if (!_isLogin)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'ชื่อผู้ใช้ (Username)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'กรุณากรอกชื่อผู้ใช้'
                        : null,
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
                  validator: (value) =>
                      value == null ||
                          value.trim().isEmpty ||
                          !value.contains('@')
                      ? 'กรุณากรอกอีเมลให้ถูกต้อง'
                      : null,
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
                  validator: (value) => value == null || value.length < 6
                      ? 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร'
                      : null,
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
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isLogin ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก',
                            style: const TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
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
