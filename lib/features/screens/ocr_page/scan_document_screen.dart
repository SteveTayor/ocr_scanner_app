import 'package:flutter/material.dart';
import 'save_document_screen.dart';

class ScanDocumentScreen extends StatelessWidget {
  const ScanDocumentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OCR Scanner")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Simulate scanned text for now
            final scannedText = "Scanned text goes here.";
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreviewDocumentScreen(scannedText: scannedText),
              ),
            );
          },
          child: const Text("Scan Document"),
        ),
      ),
    );
  }
}
