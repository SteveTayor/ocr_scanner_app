import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../models/documents_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Create or verify a user exists in Firestore.
  Future<void> createOrVerifyUser(String userName, String matricNumber) async {
    try {
      if (userName.isEmpty || matricNumber.isEmpty) {
        throw Exception("User name and matric number cannot be empty.");
      }
      // Use a document ID format: userName_matricNumber
      final userDoc = _firestore
          .collection("archived_scanned_document")
          .doc("${userName}_${matricNumber}");
      final snapshot = await userDoc.get();
      if (!snapshot.exists) {
        await userDoc.set({
          'userName': userName,
          'matricNumber': matricNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception("Failed to create or verify user: $e");
    }
  }

  

  /// Upload Image to Firebase Storage
  // Future<String> uploadImage(
  //     File imageFile, String matricNumber, String level) async {
  //   try {
  //     if (matricNumber.isEmpty || level.isEmpty) {
  //       throw Exception("Matric number and level must be provided.");
  //     }

  //     final String filePath =
  //         "documents/$matricNumber/$level/${DateTime.now().millisecondsSinceEpoch}.jpg";
  //     final Reference storageRef = _storage.ref().child(filePath);
  //     final UploadTask uploadTask = storageRef.putFile(imageFile);
  //     final TaskSnapshot snapshot = await uploadTask;
  //     return await snapshot.ref.getDownloadURL();
  //   } catch (e) {
  //     throw Exception("Error uploading image: $e");
  //   }
  // }

  /// Save Document Metadata to Firestore
  // Future<void> saveDocument(DocumentModel document) async {
  //   try {
  //     if (document.matricNumber.isEmpty || document.level.isEmpty) {
  //       throw Exception("Document must have a matric number and level.");
  //     }

  //     final userDoc = _firestore
  //         .collection("archived_scanned_document")
  //         .doc("user_${document.matricNumber}");
  //     await userDoc.collection(document.level).add(document.toMap());
  //   } catch (e) {
  //     throw Exception("Error saving document: $e");
  //   }
  // }

  /// Save document metadata (with extracted text only) to Firestore.
  Future<void> saveDocument(DocumentModel document) async {
    try {
      if (document.matricNumber.isEmpty || document.level.isEmpty) {
        throw Exception("Document must have a matric number and level.");
      }
      // Use the document ID format: userName_matricNumber
      final userDoc = _firestore
          .collection("archived_scanned_document")
          .doc("${document.userName}_${document.matricNumber}");
      
      // Firestore will automatically create the subcollection (e.g., '100') if it doesn't exist.
      final docRef = userDoc.collection(document.level).doc();
      // Create a new document model with fileUrl as an empty string.
      final newDocument = DocumentModel(
        id: docRef.id,
        userName: document.userName,
        matricNumber: document.matricNumber,
        level: document.level,
        text: document.text,
        fileUrl: "", // Not saving the image
        timestamp: document.timestamp,
      );
      await docRef.set(newDocument.toMap());
    } catch (e) {
      throw Exception("Error saving document: $e");
    }
  }

  /// Fetch All Documents for a User
  Future<List<DocumentModel>> fetchDocuments(String matricNumber,
      {String? level}) async {
    try {
      if (matricNumber.isEmpty) {
        throw Exception("Matric number must be provided.");
      }

      final userDoc = _firestore
          .collection("archived_scanned_document")
          .doc("user_$matricNumber");

      var snapshot;
      if (level != null) {
        snapshot = await userDoc.collection(level).get();
      } else {
        snapshot =
            await userDoc.get();
      }

      return snapshot.docs
          .map((doc) =>
              DocumentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Error fetching documents: $e");
    }
  }

  /// Delete a Document
  Future<void> deleteDocument(
      String matricNumber, String level, String documentId) async {
    try {
      if (matricNumber.isEmpty || level.isEmpty || documentId.isEmpty) {
        throw Exception(
            "All parameters (matric number, level, document ID) must be provided.");
      }

      final userDoc = _firestore
          .collection("archived_scanned_document")
          .doc("user_$matricNumber");
      await userDoc.collection(level).doc(documentId).delete();
    } catch (e) {
      throw Exception("Error deleting document: $e");
    }
  }

  /// Update a Document
  Future<void> updateDocument(String matricNumber, String level,
      String documentId, Map<String, dynamic> updates) async {
    try {
      if (matricNumber.isEmpty || level.isEmpty || documentId.isEmpty) {
        throw Exception(
            "All parameters (matric number, level, document ID) must be provided.");
      }

      final userDoc = _firestore
          .collection("archived_scanned_document")
          .doc("user_$matricNumber");
      await userDoc.collection(level).doc(documentId).update(updates);
    } catch (e) {
      throw Exception("Error updating document: $e");
    }
  }

  /// Fetch All Available Users
  Future<List<Map<String, String>>> fetchAllUsers() async {
    try {
      final querySnapshot =
          await _firestore.collection("archived_scanned_document").get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userName': (data['userName'] ?? '') as String,
          'matricNumber': doc.id.replaceFirst('user_', ''),
        };
      }).toList();
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }
}
