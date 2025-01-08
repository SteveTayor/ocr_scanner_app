import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/document_model.dart';
import '../widgets/text_field_widget.dart';

class PreviewDocumentScreen extends StatelessWidget {
  final String scannedText;
  final TextEditingController textController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();
  final String userId = 'user123'; // Replace with actual user ID

  PreviewDocumentScreen({Key? key, required this.scannedText}) : super(key: key) {
    textController.text = scannedText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Save Document")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: textController,
              label: "Edited Text",
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String editedText = textController.text.trim();
                if (editedText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter some text.")),
                  );
                  return;
                }

                try {
                  DocumentModel document = DocumentModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    editedText: editedText,
                    level: "100",
                    matricNumber: "123456",
                    documentName: "Scanned Document",
                  );

                  await firestoreService.saveDocument(userId, document);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Document saved successfully!")),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to save document: $e")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
