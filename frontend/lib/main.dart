import 'package:flutter/material.dart';
import 'login/login_screen.dart';

void main() {
  runApp(const CoachConnectApp());
}

class CoachConnectApp extends StatelessWidget {
  const CoachConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}