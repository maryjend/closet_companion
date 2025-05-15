import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/outfit.dart';

class AddOutfitScreen extends StatefulWidget {
  const AddOutfitScreen({Key? key}) : super(key: key);

  @override
  State<AddOutfitScreen> createState() => _AddOutfitScreenState();
}

class _AddOutfitScreenState extends State<AddOutfitScreen> {
  File? _image;
  final picker = ImagePicker();

  final _categoryController = TextEditingController();
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveOutfit() {
    if (_image == null ||
        _categoryController.text.isEmpty ||
        _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    final outfit = Outfit(
      imagePath: _image!.path,
      category: _categoryController.text,
      date: _dateController.text,
      notes: _notesController.text,
    );

    // For now we just print it — later you can store it locally or in Firestore
    print('Outfit saved: ${outfit.toJson()}');

    Navigator.pop(context); // Return to previous screen
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
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Date'),
            ),
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
