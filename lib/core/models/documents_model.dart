import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  final String id;
  final String userName;
  final String matricNumber;
  final String level;
  final String text;
  final String fileUrl;
  final DateTime timestamp;

  DocumentModel({
    required this.id,
    required this.userName,
    required this.matricNumber,
    required this.level,
    required this.text,
    required this.fileUrl,
    required this.timestamp,
  });

  factory DocumentModel.fromMap(String id, Map<String, dynamic> map) {
    return DocumentModel(
      id: id,
      userName: json['userName'] ?? '',
      matricNumber: json['matricNumber'] ?? '',
      level: json['level'] ?? '',
      text: json['text'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
      // timestamp: (map['timestamp'] as Timestamp?)?.toDate(),

  // Map<String, dynamic> toMap() {
  //   return {
  //     'edited_text': editedText,
  //     'level': level,
  //     'matric_number': matricNumber,
  //     'document_name': documentName,
  //     'timestamp': FieldValue.serverTimestamp(),
  //   };
  // }
  // Convert to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'matricNumber': matricNumber,
      'level': level,
      'text': text,
      'fileUrl': fileUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
