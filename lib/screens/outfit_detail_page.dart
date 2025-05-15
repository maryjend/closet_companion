import 'dart:io';
import 'package:flutter/material.dart';
import '../models/outfit.dart';

class OutfitDetailPage extends StatelessWidget {
  final Outfit outfit;

  const OutfitDetailPage({super.key, required this.outfit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("⭐ Outfit Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(File(outfit.imagePath), height: 300),
            const SizedBox(height: 16),
            Text("📅 Date: ${outfit.date}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("🪐 Category: ${outfit.category}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("💬 Notes: ${outfit.notes}", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
