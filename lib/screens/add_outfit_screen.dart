import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/outfit.dart';

class AddOutfitScreen extends StatefulWidget {
  const AddOutfitScreen({Key? key}) : super(key: key);

  @override
  State<AddOutfitScreen> createState() => _AddOutfitScreenState();
}

class _AddOutfitScreenState extends State<AddOutfitScreen> {
  File? _image;
  final picker = ImagePicker();

  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();

  List<String> categories = ['athletic', 'professional', 'casual', 'warm', 'cold'];
  String? selectedCategory;

  List<String> allTags = ['comfy', 'cute', 'fitness'];
  List<String> selectedTags = [];

  @override
  void initState() {
    super.initState();
    loadSavedTags();
  }

  Future<void> loadSavedTags() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('all_tags');
    if (saved != null) {
      setState(() {
        allTags = saved;
      });
    }
  }

  Future<void> saveTags() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('all_tags', allTags);
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveOutfit() {
    if (_image == null || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    final outfit = Outfit(
      imagePath: _image!.path,
      category: selectedCategory!,
      date: DateFormat('MMM d, y – h:mm a').format(DateTime.now()),
      notes: _notesController.text.trim(),
      tags: selectedTags,
    );

    print('Outfit saved: ${outfit.toJson()}');

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⭐ Add Outfit ⭐')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _image == null
                  ? Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.add_a_photo, size: 50),
                    )
                  : Image.file(_image!, height: 200),
            ),
            const SizedBox(height: 16),

            /// Category Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Category"),
              value: selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            /// Add New Category
            TextField(
              controller: _newCategoryController,
              decoration: const InputDecoration(
                labelText: "Add New Category",
                suffixIcon: Icon(Icons.add),
              ),
              onSubmitted: (value) {
                final newCat = value.trim();
                if (newCat.isNotEmpty && !categories.contains(newCat)) {
                  setState(() {
                    categories.add(newCat);
                    selectedCategory = newCat;
                    _newCategoryController.clear();
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            /// Tags Selection
            const Text("Tags", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: allTags.map((tag) {
                final isSelected = selectedTags.contains(tag);
                return FilterChip(
                  label: Text('#$tag'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      isSelected
                          ? selectedTags.remove(tag)
                          : selectedTags.add(tag);
                    });
                  },
                );
              }).toList(),
            ),

            /// Add New Tag
            TextField(
              controller: _newTagController,
              decoration: const InputDecoration(
                labelText: 'Add New Tag',
                suffixIcon: Icon(Icons.add),
              ),
              onSubmitted: (value) {
                final newTag = value.trim();
                if (newTag.isNotEmpty && !allTags.contains(newTag)) {
                  setState(() {
                    allTags.add(newTag);
                    selectedTags.add(newTag);
                    _newTagController.clear();
                  });
                  saveTags();
                }
              },
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveOutfit,
              child: const Text('Save Outfit'),
            ),
          ],
        ),
      ),
    );
  }
}
