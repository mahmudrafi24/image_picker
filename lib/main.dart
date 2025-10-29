import 'dart:io';
import 'package:flutter/material.dart';
import 'custom_image_picker.dart';
import 'custom_path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Picker Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ImagePickerScreen(),
    );
  }
}

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? _selectedImage;
  String? _saveStatus;

  Future<void> _pickAndSaveImage(ImageSource source) async {
    final File? image = await CustomImagePicker.pickImage(source: source);
    if (image != null) {
      // Use custom path provider to save to app docs
      final Directory? appDir =
          await CustomPathProvider.getApplicationDocumentsDirectory();
      if (appDir != null) {
        final String newPath = '${appDir.path}/picked_image.jpg';
        await image.copy(newPath);
        setState(() {
          _selectedImage = File(newPath); // Update to saved file
          _saveStatus = 'Saved to: $newPath';
        });
      } else {
        setState(() {
          _saveStatus = 'Failed to get app dir';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Image Picker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickAndSaveImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickAndSaveImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_saveStatus != null)
              Text(_saveStatus!, style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 32),
            Expanded(
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Pick an image to display',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
