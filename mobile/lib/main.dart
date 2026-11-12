import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const PawRescueApp());
}

class PawRescueApp extends StatelessWidget {
  const PawRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawRescue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
