import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/outfit.dart';
import 'package:intl/intl.dart';

class AddOutfitPage extends StatefulWidget {
  const AddOutfitPage({super.key});

  @override
  State<AddOutfitPage> createState() => _AddOutfitPageState();
}

class _AddOutfitPageState extends State<AddOutfitPage> {
  File? _image;
  final picker = ImagePicker();

  final TextEditingController tagController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController newCategoryController = TextEditingController();

  List<String> categories = ['athletic', 'professional', 'casual', 'warm', 'cold'];
  String? selectedCategory;

  Future<void> pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> saveOutfitLocally(Outfit outfit) async {
    final prefs = await SharedPreferences.getInstance();
    final String? existing = prefs.getString('outfits');
    List<dynamic> outfitList = existing != null ? jsonDecode(existing) : [];

    outfitList.add(outfit.toJson());
    await prefs.setString('outfits', jsonEncode(outfitList));
  }

  void saveOutfit() {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please pick an image")),
      );
      return;
    }

    final outfit = Outfit(
      imagePath: _image!.path,
      date: DateFormat('MMM d, y – h:mm a').format(DateTime.now()),
      category: selectedCategory ?? '',
      notes: notesController.text.trim(),
    );

    saveOutfitLocally(outfit).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Outfit saved locally!")),
      );
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Outfit")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : const Text("No image selected"),
            ElevatedButton(onPressed: pickImage, child: const Text("Pick Image")),
            TextField(
              controller: tagController,
              decoration: const InputDecoration(labelText: "Tags"),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 8),
            TextField(
              controller: newCategoryController,
              decoration: const InputDecoration(
                labelText: "Add New Category",
                suffixIcon: Icon(Icons.add),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty && !categories.contains(value)) {
                  setState(() {
                    categories.add(value.trim());
                    selectedCategory = value.trim();
                    newCategoryController.clear();
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: "Notes"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: saveOutfit, child: const Text("Save Outfit")),
          ],
        ),
      ),
    );
  }
}
