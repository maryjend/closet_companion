import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/outfit.dart';
import 'outfit_detail_page.dart';

class OutfitLogPage extends StatefulWidget {
  const OutfitLogPage({super.key});

  @override
  State<OutfitLogPage> createState() => _OutfitLogPageState();
}

class _OutfitLogPageState extends State<OutfitLogPage> {
  List<Outfit> outfits = [];
  List<Outfit> filteredOutfits = [];

  String searchQuery = '';
  String sortOption = 'Newest';
  String? categoryFilter;

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
      applyFilters();
    }
  }

  void applyFilters() {
    setState(() {
      filteredOutfits = outfits.where((outfit) {
        final query = searchQuery.toLowerCase();

        final matchesSearch = outfit.notes.toLowerCase().contains(query) ||
            outfit.category.toLowerCase().contains(query) ||
            outfit.tags.any((tag) => tag.toLowerCase().contains(query));

        final matchesCategory = categoryFilter == null || outfit.category == categoryFilter;

        return matchesSearch && matchesCategory;
      }).toList();

      if (sortOption == 'Newest') {
        filteredOutfits.sort((a, b) => b.date.compareTo(a.date));
      } else if (sortOption == 'Oldest') {
        filteredOutfits.sort((a, b) => a.date.compareTo(b.date));
      } else if (sortOption == 'Category A-Z') {
        filteredOutfits.sort((a, b) => a.category.compareTo(b.category));
      }
    });
  }

  void showFilterDialog() {
    String tempSearch = searchQuery;
    String tempSort = sortOption;
    String? tempCategoryFilter = categoryFilter;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              runSpacing: 12,
              children: [
                const Text("🔍 Filter & Sort", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

                TextField(
                  decoration: const InputDecoration(
                    labelText: "Search tags, notes, or category",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setModalState(() => tempSearch = val),
                ),

                DropdownButtonFormField<String>(
                  value: tempSort,
                  items: ['Newest', 'Oldest', 'Category A-Z']
                      .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ))
                      .toList(),
                  onChanged: (val) => setModalState(() => tempSort = val!),
                  decoration: const InputDecoration(
                    labelText: "Sort By",
                    border: OutlineInputBorder(),
                  ),
                ),

                DropdownButtonFormField<String>(
                  value: tempCategoryFilter,
                  items: ['All', 'athletic', 'professional', 'casual', 'warm', 'cold']
                      .map((option) => DropdownMenuItem(
                            value: option == 'All' ? null : option,
                            child: Text(option),
                          ))
                      .toList(),
                  onChanged: (val) => setModalState(() => tempCategoryFilter = val),
                  decoration: const InputDecoration(
                    labelText: "Filter by Category",
                    border: OutlineInputBorder(),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          searchQuery = '';
                          sortOption = 'Newest';
                          categoryFilter = null;
                        });
                        applyFilters();
                      },
                      child: const Text("Clear Filters"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          searchQuery = tempSearch;
                          sortOption = tempSort;
                          categoryFilter = tempCategoryFilter;
                        });
                        applyFilters();
                      },
                      child: const Text("Apply"),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("⭐ Outfit Log"),
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showFilterDialog,
        child: const Icon(Icons.filter_alt),
      ),
      body: filteredOutfits.isEmpty
          ? const Center(
              child: Text(
                "No outfits match your filters 🌙",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Raleway',
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: filteredOutfits.length,
              itemBuilder: (context, index) {
                final outfit = filteredOutfits[index];
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
                      child: Image.file(
                        File(outfit.imagePath),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          outfit.notes,
                          style: const TextStyle(fontFamily: 'Raleway'),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: outfit.tags
                              .map((tag) => Chip(
                                    label: Text('#$tag',
                                        style: const TextStyle(fontSize: 12)),
                                    visualDensity: VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "📅 ${outfit.date.split('T').first}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OutfitDetailPage(outfit: outfit),
                        ),
                      ).then((_) => loadOutfits());
                    },
                  ),
                );
              },
            ),
    );
  }
}
