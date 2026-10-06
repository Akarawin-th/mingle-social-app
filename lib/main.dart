import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'features/auth/auth_screen.dart';

void main() async {
  // สำคัญมาก: ต้องบอกให้ Flutter เตรียมตัวก่อนเรียกใช้ Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // เริ่มต้นเชื่อมต่อ Firebase ตามค่าในไฟล์อัตโนมัติ
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MingleApp());
}

class MingleApp extends StatelessWidget {
  const MingleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mingle Social Network',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1877F2),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1877F2)),
      ),
      home: const AuthScreen(),
    );
  }
}
