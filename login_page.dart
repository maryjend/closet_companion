import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void fakeSignIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fake login success")),
    );
    // You could also navigate to HomePage here if needed
  }

  void fakeSignUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fake signup success")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: fakeSignIn, child: const Text('Login')),
            TextButton(onPressed: fakeSignUp, child: const Text('Sign Up')),
          ],
        ),
      ),
    );
  }
}
