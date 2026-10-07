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

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  // ตัวแปรสำหรับเช็คเงื่อนไขรหัสผ่านแบบ Real-time
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ฟังก์ชันอัปเดตสถานะ Checklist ทันทีที่พิมพ์ข้อความ
  void _onPasswordChanged(String value) {
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
      _hasLowercase = RegExp(r'[a-z]').hasMatch(value);
      _hasNumber = RegExp(r'[0-9]').hasMatch(value);
      _hasSpecialChar = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value);
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isLogin) {
          await _authService.signInWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
        } else {
          await _authService.signUpWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
        }

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

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      // ล้างค่า Checklist เมื่อสลับหน้า
      _hasMinLength = false;
      _hasUppercase = false;
      _hasLowercase = false;
      _hasNumber = false;
      _hasSpecialChar = false;
    });
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _formKey.currentState?.reset();
  }

  // วิดเจ็ตสำหรับสร้างแถว Checklist แต่ละข้อ
  Widget _buildConditionRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : Colors.grey.shade400,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            _isLogin ? 'ล็อกอิน' : 'สร้างบัญชีใหม่',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (!_isLogin)
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: 'ชื่อผู้ใช้ (Username)',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'กรุณากรอกชื่อผู้ใช้'
                                : null,
                          ),
                        if (!_isLogin) const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'อีเมล (Email)',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')
                              ? 'กรุณากรอกอีเมลให้ถูกต้อง'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          onChanged: _onPasswordChanged, // เรียกฟังก์ชันเช็คเงื่อนไขทันทีที่พิมพ์
                          decoration: InputDecoration(
                            hintText: 'รหัสผ่าน (Password)',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'กรุณากรอกรหัสผ่าน';
                            // ถ้าหน้าสมัครสมาชิก แล้วเงื่อนไขยังไม่ครบ ให้แจ้งเตือน
                            if (!_isLogin) {
                              if (!_hasMinLength ||
                                  !_hasUppercase ||
                                  !_hasLowercase ||
                                  !_hasNumber ||
                                  !_hasSpecialChar) {
                                return 'กรุณาตั้งรหัสผ่านให้ครบตามเงื่อนไขด้านล่าง';
                              }
                            }
                            return null;
                          },
                        ),

                        // แสดง Checklist เฉพาะหน้าสมัครสมาชิก
                        if (!_isLogin) ...[
                          const SizedBox(height: 16),
                          _buildConditionRow(
                            'ความยาวอย่างน้อย 8 ตัวอักษร',
                            _hasMinLength,
                          ),
                          _buildConditionRow(
                            'มีตัวอักษรพิมพ์ใหญ่ (A-Z)',
                            _hasUppercase,
                          ),
                          _buildConditionRow(
                            'มีตัวอักษรพิมพ์เล็ก (a-z)',
                            _hasLowercase,
                          ),
                          _buildConditionRow('มีตัวเลข (0-9)', _hasNumber),
                          _buildConditionRow(
                            'มีอักขระพิเศษ (เช่น @, #, !)',
                            _hasSpecialChar,
                          ),
                        ],

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1877F2),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: const Color(0xFF1877F2)
                                  .withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    _isLogin ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin
                                  ? 'ยังไม่มีบัญชีใช่ไหม? '
                                  : 'มีบัญชีอยู่แล้ว? ',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: _toggleMode,
                              child: Text(
                                _isLogin ? 'สมัครเลย' : 'เข้าสู่ระบบ',
                                style: const TextStyle(
                                  color: Color(0xFF1877F2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
