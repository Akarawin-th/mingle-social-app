import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // สมัครสมาชิก
  Future<UserCredential?> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // เข้าสู่ระบบ
  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ออกจากระบบ
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
