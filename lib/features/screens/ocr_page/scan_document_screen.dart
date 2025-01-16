import 'package:flutter/material.dart';
import 'preview_document_screen.dart';

class ScanDocumentScreen extends StatelessWidget {
  const ScanDocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OCR Scanner")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Simulate scanned text for now
            const scannedText = "Scanned text goes here.";
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PreviewDocumentScreen(scannedText: scannedText),
              ),
            );
          },
          child: const Text("Scan Document"),
        ),
      ),
    );
  }
}
