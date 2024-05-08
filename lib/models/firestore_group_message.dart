import 'package:cloud_firestore/cloud_firestore.dart';
class FirestoreGroupMessage {
  final String message;
  final String senderId;
  final DateTime createdAt;
  // Constructor
  FirestoreGroupMessage({
    // required this.id,
    required this.message,
    required this.senderId,
    required this.createdAt,
  });

  factory FirestoreGroupMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return FirestoreGroupMessage(
      // id: data['id'],
      message: data['message'],
      senderId: data['senderId'],
      createdAt: data['createdAt'].toDate(),
    );
  }
}
