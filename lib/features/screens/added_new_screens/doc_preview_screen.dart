import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/models/documents_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/network.dart';
import '../../widgets/no_network_widget.dart';

class PreviewSavePage extends StatefulWidget {
  final File imageFile;
  final String scannedText;

  const PreviewSavePage({super.key, required this.imageFile, required this.scannedText});

  @override
  State<PreviewSavePage> createState() => _PreviewSavePageState();
}

class _PreviewSavePageState extends State<PreviewSavePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _matricNumberController = TextEditingController();
  
  String _selectedLevel = "100";
  String _selectedDocument = "Letter";
  bool _isSaving = false;
  final NetworkChecker _networkChecker = NetworkChecker();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.scannedText;
  }

  /// Save the document: upload image and save metadata.
  Future<void> _saveDocument() async {
    bool connected = await _networkChecker.hasInternetConnection();
    if (!connected) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const NoNetworkWidget()));
      return;
    }
    if (_userNameController.text.isEmpty || _matricNumberController.text.isEmpty) {
      _showSnackBar("Please enter both User Name and Matric Number.", isError: true);
      return;
    }
    try {
      setState(() {
        _isSaving = true;
      });
      // Ensure the user exists in Firestore.
      await _firebaseService.createOrVerifyUser(
        _userNameController.text,
        _matricNumberController.text,
      );
      // Upload image to Firebase Storage and get URL.
      // final fileUrl = await _firebaseService.uploadImage(
      //   widget.imageFile,
      //   _matricNumberController.text,
      //   _selectedLevel,
      // );
      // Create a new document model (Firestore auto-generates document ID in service).
      final document = DocumentModel(
        id: '',
        userName: _userNameController.text,
        matricNumber: _matricNumberController.text,
        level: _selectedLevel,
        text: _textController.text,
        documentType: _selectedDocument,
        fileUrl: "",
        timestamp: DateTime.now(),
      );
      await _firebaseService.saveDocument(document);
      _showSnackBar("Document saved successfully!");
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Error saving document: $e", isError: true);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview & Save Document'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display the image preview
            Image.file(widget.imageFile, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 20),
            // Editable text field for extracted text
            TextField(
              controller: _textController,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Edit Extracted Text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Dropdown to select academic level
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              items: ['100', '200', '300', '400', '500']
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text('Level $level'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLevel = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Academic Level',
                border: OutlineInputBorder(),
              ),
            ),
            Text(
              "Select Document Type",
              style: const TextStyle(fontSize: 18),
            ),
            DropdownButtonFormField<String>(
              value: _selectedDocument,
              items: ['Transcript', 'Exam paper', 'Letter', 'Research paper'] 
                  .map((docType) => DropdownMenuItem(
                        value: docType,
                        child: Text('$docType'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDocument = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Academic Level',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Text fields for entering or selecting user name and matric number
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'Enter User Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _matricNumberController,
              decoration: const InputDecoration(
                labelText: 'Enter Matric Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Save Document button
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.lightBlue.shade800),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                    onPressed: _saveDocument,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Document'),
                  ),  
          ],
        ),
      ),
    );
  }
}
