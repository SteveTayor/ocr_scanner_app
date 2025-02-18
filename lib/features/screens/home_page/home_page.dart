import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../added_new_screens/extraction_page.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniVault - Admin Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Welcome to UniVault',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Digitize and securely manage academic documents',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to ExtractionScreen for camera scanning
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExtractionScreen(source: ImageSource.camera),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Document (Camera)'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to ExtractionScreen for local file selection
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExtractionScreen(source: ImageSource.gallery),
                  ),
                );
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('Select Document (Local Storage)'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                // Future: Navigate to a screen that displays saved documents.
              },
              icon: const Icon(Icons.history),
              label: const Text('View Saved Documents'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
