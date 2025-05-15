import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/outfit.dart';

class OutfitDetailPage extends StatelessWidget {
  final Outfit outfit;

  const OutfitDetailPage({super.key, required this.outfit});

  Future<void> _deleteOutfit(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('outfits');
    if (data != null) {
      final List decoded = jsonDecode(data);
      decoded.removeWhere((item) =>
          item['imagePath'] == outfit.imagePath &&
          item['date'] == outfit.date &&
          item['category'] == outfit.category &&
          item['notes'] == outfit.notes);

      await prefs.setString('outfits', jsonEncode(decoded));
      Navigator.pop(context); // Go back to log
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("⭐ Outfit Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Delete Outfit"),
                  content: const Text("Are you sure you want to delete this outfit?"),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    TextButton(
                      child: const Text("Delete"),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _deleteOutfit(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              outfit.imagePath,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
            ),
            const SizedBox(height: 16),
            Text(
              "⭐ ${outfit.category}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: outfit.tags
                  .map((tag) => Chip(label: Text('#$tag')))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text(
              outfit.notes.isNotEmpty ? outfit.notes : "No notes provided.",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text("📅 ${outfit.date}", style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
