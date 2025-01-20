import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../models/documents_model.dart';

// class FirestoreService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> saveDocument(String userId, DocumentModel document) async {
//     try {
//       await _firestore
//           .collection('archived_scanned_document')
//           .doc(userId)
//           .collection('metadata')
//           .doc(document.id)
//           .set(document.toMap());
//     } catch (e) {
//       throw Exception("Failed to save document: $e");
//     }
//   }

//   Future<List<DocumentModel>> fetchDocuments(String userId) async {
//     try {
//       QuerySnapshot snapshot = await _firestore
//           .collection('archived_scanned_document')
//           .doc(userId)
//           .collection('metadata')
//           .get();

//       return snapshot.docs
//           .map((doc) => DocumentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw Exception("Failed to fetch documents: $e");
//     }
//   }
// }


class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile, String fileName) async {
    try {
      final storageRef = _storage.ref().child(fileName);
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Error uploading image: $e");
    }
  }

  Future<void> saveDocument(ScannedDocument document) async {
    try {
      final userDoc = _firestore.collection("archived_scanned_document").doc("user_${document.matricNumber}");
      await userDoc.collection(document.level).add(document.toJson());
    } catch (e) {
      throw Exception("Error saving document to Firestore: $e");
    }
  }
}
