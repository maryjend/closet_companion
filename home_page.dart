import 'package:flutter/material.dart';
import 'add_outfit_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Closet Companion'),
        // Removed logout button since we’re not using Firebase Auth
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to your Outfit Tracker!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddOutfitPage()),
                );
              },
              child: const Text("Add Outfit"),
            ),
          ],
        ),
      ),
    );
  }
}
