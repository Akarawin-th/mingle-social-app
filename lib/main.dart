import 'package:flutter/material.dart';

import 'features/auth/auth_screen.dart';

void main() {
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
