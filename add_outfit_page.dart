import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddOutfitPage extends StatefulWidget {
  const AddOutfitPage({super.key});

  @override
  State<AddOutfitPage> createState() => _AddOutfitPageState();
}

class _AddOutfitPageState extends State<AddOutfitPage> {
  File? _image;
  final picker = ImagePicker();

  final TextEditingController tagController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Change to ImageSource.camera if needed
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void saveOutfit() {
    // TODO: Upload to Firebase Storage and Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Outfit saved (functionality coming soon)")),
    );
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
            TextField(controller: tagController, decoration: const InputDecoration(labelText: "Tags")),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: "Category")),
            TextField(controller: notesController, decoration: const InputDecoration(labelText: "Notes")),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: saveOutfit, child: const Text("Save Outfit")),
          ],
        ),
      ),
    );
  }
}
