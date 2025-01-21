import 'package:flutter/material.dart';
import 'preview_document_screen.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// class ScanDocumentScreen extends StatelessWidget {
//   const ScanDocumentScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("OCR Scanner")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             // Simulate scanned text for now
//             const scannedText = "Scanned text goes here.";
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) =>
//                     PreviewDocumentScreen(scannedText: scannedText),
//               ),
//             );
//           },
//           child: const Text("Scan Document"),
//         ),
//       ),
//     );
//   }
// }
// class ScanDocumentScreen extends StatefulWidget {
//   const ScanDocumentScreen({super.key});

//   @override
//   State<ScanDocumentScreen> createState() => _ScanDocumentScreenState();
// }

// class _ScanDocumentScreenState extends State<ScanDocumentScreen> {
//   final ImagePicker _picker = ImagePicker();
//   File? _selectedImage;
//   String? _scannedText;
//   bool _isLoading = false;

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(source: source);
//       if (pickedFile == null) return;

//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });

//       await _performOCR();
//     } catch (e) {
//       _showError("Error picking image: $e");
//     }
//   }

//   Future<void> _performOCR() async {
//     try {
//       if (_selectedImage == null) return;

//       setState(() {
//         _isLoading = true;
//       });

//       final inputImage = InputImage.fromFile(_selectedImage!);
//       final textRecognizer = TextRecognizer();
//       final recognizedText = await textRecognizer.processImage(inputImage);

//       setState(() {
//         _scannedText = recognizedText.text;
//       });

//       textRecognizer.close();
//     } catch (e) {
//       _showError("Error performing OCR: $e");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   void _navigateToPreview() {
//     if (_scannedText == null || _selectedImage == null) {
//       _showError("No document scanned.");
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PreviewDocumentScreen(
//             imageFile: _selectedImage!, scannedText: _scannedText!),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("OCR Scanner")),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (_selectedImage != null)
//                   Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () => _pickImage(ImageSource.camera),
//                   child: const Text("Scan Document (Camera)"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                   child: const Text("Select Document (Gallery)"),
//                 ),
//                 if (_scannedText != null)
//                   ElevatedButton(
//                     onPressed: _navigateToPreview,
//                     child: const Text("Preview & Save"),
//                   ),
//               ],
//             ),
//     );
//   }
// }
class ScanDocumentScreen extends StatefulWidget {
  const ScanDocumentScreen({Key? key}) : super(key: key);

  @override
  State<ScanDocumentScreen> createState() => _OCRScannerScreenState();
}

class _OCRScannerScreenState extends State<ScanDocumentScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _scannedText;
  bool _isLoading = false;

  /// Function to pick an image from the camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      await _performOCR();
    } catch (e) {
      _showSnackBar("Error picking image: $e", isError: true);
    }
  }

  /// Perform OCR on the selected image
  Future<void> _performOCR() async {
    try {
      if (_selectedImage == null) return;

      setState(() {
        _isLoading = true;
      });

      final inputImage = InputImage.fromFile(_selectedImage!);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        _scannedText = recognizedText.text;
      });

      textRecognizer.close();
    } catch (e) {
      _showSnackBar("Error performing OCR: $e", isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show a snack bar with a message
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green.shade700,
      ),
    );
  }

  /// Navigate to the Preview Screen
  void _navigateToPreview() {
    if (_scannedText == null || _selectedImage == null) {
      _showSnackBar("No document scanned.", isError: true);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewDocumentScreen(
          imageFile: _selectedImage!,
          scannedText: _scannedText!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OCR Scanner"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedImage != null)
                  Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera),
                  label: const Text("Scan Document (Camera)"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text("Select Document (Gallery)"),
                ),
                const SizedBox(height: 20),
                if (_scannedText != null)
                  ElevatedButton.icon(
                    onPressed: _navigateToPreview,
                    icon: const Icon(Icons.preview),
                    label: const Text("Preview & Save"),
                  ),
              ],
            ),
    );
  }
}
