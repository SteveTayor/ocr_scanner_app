import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../core/services/network.dart';
import '../../widgets/no_network_widget.dart';
import 'doc_preview_screen.dart';

class ExtractionScreen extends StatefulWidget {
  final ImageSource source;
  const ExtractionScreen({super.key, required this.source});

  @override
  State<ExtractionScreen> createState() => _ExtractionScreenState();
}

class _ExtractionScreenState extends State<ExtractionScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _scannedText;
  bool _isLoading = false;
final NetworkChecker _networkChecker = NetworkChecker();

  @override
  void initState() {
    super.initState();
    _checkNetworkAndPickImage();
  }

  Future<void> _checkNetworkAndPickImage() async {
    bool connected = await _networkChecker.hasInternetConnection();
    if (!connected) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const NoNetworkWidget()));
      return;
    }
    await _pickImage();
  }

  /// Pick an image from the provided source (camera or gallery)
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: widget.source);
      if (pickedFile == null) return;
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _performOCR();
    } catch (e) {
      _showSnackBar("Error picking image: $e", isError: true);
    }
  }

  /// Perform OCR using Google ML Kit
  Future<void> _performOCR() async {
    if (_selectedImage == null) return;
    try {
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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  /// Navigate to the Preview & Save screen
  void _navigateToPreview() {
    if (_selectedImage == null || _scannedText == null) {
      _showSnackBar("No document scanned.", isError: true);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewSavePage(imageFile: _selectedImage!, scannedText: _scannedText!),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extract Text'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (_selectedImage != null)
                    Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
                  const SizedBox(height: 20),
                  if (_scannedText != null)
                    ElevatedButton.icon(
                      onPressed: _navigateToPreview,
                      icon: const Icon(Icons.preview),
                      label: const Text('Preview & Save'),
                    ),
                ],
              ),
      ),
    );
  }
}
