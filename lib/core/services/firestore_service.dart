import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveDocument(String userId, DocumentModel document) async {
    try {
      await _firestore
          .collection('archived_scanned_document')
          .doc(userId)
          .collection('metadata')
          .doc(document.id)
          .set(document.toMap());
    } catch (e) {
      throw Exception("Failed to save document: $e");
    }
  }

  Future<List<DocumentModel>> fetchDocuments(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('archived_scanned_document')
          .doc(userId)
          .collection('metadata')
          .get();

      return snapshot.docs
          .map((doc) => DocumentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch documents: $e");
    }
  }
}
