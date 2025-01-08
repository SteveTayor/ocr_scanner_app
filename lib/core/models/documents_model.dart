class DocumentModel {
  final String id;
  final String editedText;
  final String level;
  final String matricNumber;
  final String documentName;
  final DateTime? timestamp;

  DocumentModel({
    required this.id,
    required this.editedText,
    required this.level,
    required this.matricNumber,
    required this.documentName,
    this.timestamp,
  });

  factory DocumentModel.fromMap(String id, Map<String, dynamic> map) {
    return DocumentModel(
      id: id,
      editedText: map['edited_text'] ?? '',
      level: map['level'] ?? '',
      matricNumber: map['matric_number'] ?? '',
      documentName: map['document_name'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'edited_text': editedText,
      'level': level,
      'matric_number': matricNumber,
      'document_name': documentName,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
