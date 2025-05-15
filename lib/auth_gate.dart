import 'package:flutter/material.dart';
import 'home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Skip auth — always go to HomePage for now
    return const HomePage();
  }
}
