import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/outfit.dart';
import 'screens/outfit_detail_page.dart';
class OutfitLogPage extends StatefulWidget {
  const OutfitLogPage({super.key});

  @override
  State<OutfitLogPage> createState() => _OutfitLogPageState();
}

class _OutfitLogPageState extends State<OutfitLogPage> {
  List<Outfit> outfits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadOutfits();
  }

  Future<void> loadOutfits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('outfits');
    if (data != null) {
      final List decoded = jsonDecode(data);
      outfits = decoded.map((item) => Outfit.fromJson(item)).toList();
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("⭐ Outfit Log"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : outfits.isEmpty
              ? const Center(
                  child: Text(
                    "No outfits saved yet 🌙",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Raleway',
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: outfits.length,
                  itemBuilder: (context, index) {
                    final outfit = outfits[index];
                    final file = File(outfit.imagePath);
                    final imageExists = file.existsSync();

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageExists
                              ? Image.file(
                                  file,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                        ),
                        title: Text(
                          "${outfit.category} ⭐",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Raleway',
                          ),
                        ),
                        subtitle: Text(
                          "${outfit.notes}\n📅 ${outfit.date.split('T').first}",
                          style: const TextStyle(fontFamily: 'Raleway'),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OutfitDetailPage(outfit: outfit),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
