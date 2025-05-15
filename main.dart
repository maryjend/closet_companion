import 'package:flutter/material.dart';
import 'auth_gate.dart'; // still used, but it now always returns HomePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Closet Companion',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const AuthGate(),
    );
  }
}
