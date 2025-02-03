import 'package:flutter/material.dart';

import '../../../core/models/documents_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/network.dart';
import '../../widgets/no_network_widget.dart';
import '../../widgets/text_field.dart';
import 'dart:io';
import 'scan_document_screen.dart';

// class PreviewDocumentScreen extends StatefulWidget {
//   final File imageFile;
//   final String scannedText;

//   const PreviewDocumentScreen(
//       {super.key, required this.imageFile, required this.scannedText});

//   @override
//   State<PreviewDocumentScreen> createState() => _PreviewDocumentScreenState();
// }

// class _PreviewDocumentScreenState extends State<PreviewDocumentScreen> {
//   final TextEditingController _textController = TextEditingController();
//   final FirebaseService _firebaseService = FirebaseService();

//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     _textController.text = widget.scannedText;
//   }

//   Future<void> _saveDocument() async {
//     try {
//       setState(() {
//         _isSaving = true;
//       });

//       // Prompt for user details
//       String userName = "John Doe"; // Prompt user for this
//       String matricNumber = "123456"; // Prompt user for this
//       String level = "100"; // Prompt user for this

//       // Upload image and save metadata
//       String fileName =
//           "documents/$matricNumber/$level/${DateTime.now().millisecondsSinceEpoch}.jpg";
//       String fileUrl =
//           await _firebaseService.uploadImage(widget.imageFile, fileName);

//       final document = DocumentModel(
//         userName: userName,
//         matricNumber: matricNumber,
//         level: level,
//         text: _textController.text,
//         fileUrl: fileUrl,
//         timestamp: DateTime.now(),
//         id: '',
//       );

//       await _firebaseService.saveDocument(document);

//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Document saved successfully!")));
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Error saving document: $e")));
//     } finally {
//       setState(() {
//         _isSaving = false;
//       });
//     }

//     @override
//     Widget build(BuildContext context) {
//       // TODO: implement build
//       throw UnimplementedError();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Preview Document")),
//       body: Column(
//         children: [
//           Image.file(widget.imageFile, height: 200, fit: BoxFit.cover),
//           TextField(
//             controller: _textController,
//             maxLines: null,
//             decoration: const InputDecoration(labelText: "Edit Scanned Text"),
//           ),
//           const SizedBox(height: 20),
//           _isSaving
//               ? const CircularProgressIndicator()
//               : ElevatedButton(
//                   onPressed: _saveDocument,
//                   child: const Text("Save Document"),
//                 ),
//         ],
//       ),
//     );
//   }
// }
class PreviewDocumentScreen extends StatefulWidget {
  final File imageFile;
  final String scannedText;

  const PreviewDocumentScreen(
      {super.key, required this.imageFile, required this.scannedText});

  @override
  State<PreviewDocumentScreen> createState() => _PreviewDocumentScreenState();
}

class _PreviewDocumentScreenState extends State<PreviewDocumentScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _matricNumberController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  String _selectedLevel = "100";
  bool _isLoadingUsers = true;
  bool _isSaving = false;

  List<Map<String, String>> _users = [];
  String? _selectedUser;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.scannedText;
    _fetchUsers();
  }

  /// Fetch all users from Firestore
  Future<void> _fetchUsers() async {
    try {
      final users = await _firebaseService.fetchAllUsers();
      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      _showSnackBar("Error fetching users: $e", isError: true);
    }
  }

  /// Save the document to Firestore
  Future<void> _saveDocument() async {
    final hasInternet = await NetworkChecker().hasInternetConnection();
    if (!hasInternet) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NoNetworkWidget()),
      );
      return;
    }

    if (_matricNumberController.text.isEmpty ||
        _userNameController.text.isEmpty) {
      _showSnackBar("Please provide both name and matric number.",
          isError: true);
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      // Create user if it doesn't exist
      await _firebaseService.createOrVerifyUser(
        _userNameController.text,
        _matricNumberController.text,
      );

      // Upload image to Firebase Storage
      final fileUrl = await _firebaseService.uploadImage(
        widget.imageFile,
        _matricNumberController.text,
        _selectedLevel,
      );

      // Create document model
      final document = DocumentModel(
        id: "",
        userName: _userNameController.text,
        matricNumber: _matricNumberController.text,
        level: _selectedLevel,
        text: _textController.text,
        fileUrl: fileUrl,
        timestamp: DateTime.now(),
      );

      // Save document to Firestore
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

  /// Show a snack bar with a message
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview Document"),
      ),
      body: _isLoadingUsers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.file(widget.imageFile, height: 200, fit: BoxFit.cover),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _textController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: "Edit Scanned Text",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedUser,
                    items: _users
                        .map(
                          (user) => DropdownMenuItem(
                            value: user['matricNumber'],
                            child: Text(
                                "${user['userName']} (${user['matricNumber']})"),
                          ),
                        )
                        .toList()
                      ..add(
                        const DropdownMenuItem(
                          value: "new",
                          child: Text("Add New User"),
                        ),
                      ),
                    onChanged: (value) {
                      if (value == "new") {
                        _matricNumberController.clear();
                        _userNameController.clear();
                      } else {
                        final user = _users.firstWhere(
                            (user) => user['matricNumber'] == value);
                        _matricNumberController.text = user['matricNumber']!;
                        _userNameController.text = user['userName']!;
                      }
                      setState(() {
                        _selectedUser = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Select or Add User",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _matricNumberController,
                    decoration: const InputDecoration(
                      labelText: "Matric Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _userNameController,
                    decoration: const InputDecoration(
                      labelText: "User Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedLevel,
                    items: ["100", "200", "300", "400", "500"]
                        .map((level) => DropdownMenuItem(
                              value: level,
                              child: Text("Level $level"),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLevel = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Select Level",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _isSaving
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: _saveDocument,
                          icon: const Icon(Icons.save),
                          label: const Text("Save Document"),
                        ),
                ],
              ),
            ),
    );
  }
}
