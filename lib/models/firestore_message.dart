import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreMessage  {
  final String messageForReceiver;
  final String messageForSender;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;

  // Constructor
  FirestoreMessage({
    // required this.id,
    required this.messageForReceiver,
    required this.messageForSender,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
  });

  factory FirestoreMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return FirestoreMessage(
      // id: data['id'],
      messageForReceiver: data['messageForReceiver'],
      messageForSender: data['messageForSender'],
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      createdAt: data['createdAt'].toDate(),
    );
  }
}
