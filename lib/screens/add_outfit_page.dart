import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/outfit.dart';

class AddOutfitPage extends StatefulWidget {
  final Outfit? existingOutfit;
  final int? outfitIndex;

  const AddOutfitPage({super.key, this.existingOutfit, this.outfitIndex});

  @override
  State<AddOutfitPage> createState() => _AddOutfitPageState();
}

class _AddOutfitPageState extends State<AddOutfitPage> {
  File? _image;
  final picker = ImagePicker();

  final TextEditingController notesController = TextEditingController();
  final TextEditingController newCategoryController = TextEditingController();
  final TextEditingController newTagController = TextEditingController();

  List<String> categories = ['athletic', 'professional', 'casual', 'warm', 'cold'];
  String? selectedCategory;

  List<String> allTags = ['comfy', 'cute', 'fitness'];
  List<String> selectedTags = [];

  @override
  void initState() {
    super.initState();
    loadSavedTags();

    if (widget.existingOutfit != null) {
      final outfit = widget.existingOutfit!;
      _image = File(outfit.imagePath); // still used for preview before upload
      notesController.text = outfit.notes;
      selectedCategory = outfit.category;
      selectedTags = List<String>.from(outfit.tags);
    }
  }

  Future<void> loadSavedTags() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList('all_tags');
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

  Future<File> saveImageLocally(XFile pickedFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
    return savedImage;
  }

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
                    final savedImage = await saveImageLocally(pickedFile);
                    setState(() {
                      _image = savedImage;
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
                    final savedImage = await saveImageLocally(pickedFile);
                    setState(() {
                      _image = savedImage;
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

  Future<String> uploadImageToFirebase(File imageFile) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child('outfit_images/$fileName');
    final uploadTask = await ref.putFile(imageFile);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> saveOutfit() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please pick an image")),
      );
      return;
    }

    final imageUrl = await uploadImageToFirebase(_image!);

    final newOutfit = Outfit(
      imagePath: imageUrl,
      date: DateFormat('MMM d, y – h:mm a').format(DateTime.now()),
      category: selectedCategory ?? '',
      notes: notesController.text.trim(),
      tags: selectedTags,
    );

    final prefs = await SharedPreferences.getInstance();
    final String? existing = prefs.getString('outfits');
    List<dynamic> outfitList = existing != null ? jsonDecode(existing) : [];

    if (widget.outfitIndex != null) {
      outfitList[widget.outfitIndex!] = newOutfit.toJson();
    } else {
      outfitList.add(newOutfit.toJson());
    }

    await prefs.setString('outfits', jsonEncode(outfitList));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.outfitIndex != null ? "Outfit updated!" : "Outfit saved!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.outfitIndex != null ? "Edit Outfit" : "Add Outfit")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : const Text("No image selected"),
            ElevatedButton(onPressed: pickImage, child: const Text("Pick Image")),

            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Tags", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
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
            TextField(
              controller: newTagController,
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
                    newTagController.clear();
                  });
                  saveTags();
                }
              },
            ),

            const SizedBox(height: 16),
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
            ElevatedButton(
              onPressed: saveOutfit,
              child: Text(widget.outfitIndex != null ? "Update Outfit" : "Save Outfit"),
            ),
          ],
        ),
      ),
    );
  }
}
