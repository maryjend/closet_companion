import 'package:flutter/material.dart';
import 'screens/add_outfit_page.dart';
import 'outfit_log_page.dart'; // 👈 Make sure this file exists

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Closet Companion'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⭐ Welcome to your Outfit Tracker! ⭐'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OutfitLogPage()),
                );
              },
              child: const Text("View Outfit Log"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddOutfitPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
