import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUser {
  // Properties
  final String id;
  final String displayName;
  final String description;
  final String photoURL;
  final String publicKey;
  final String status;
  final DateTime lastSeen;
  final String token;
  final String phoneNumber;
  final DateTime createdAt;

  // Constructor
  FirestoreUser({
    required this.id,
    required this.displayName,
    required this.description,
    required this.photoURL,
    required this.publicKey,
    required this.status,
    required this.lastSeen,
    required this.token,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory FirestoreUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return FirestoreUser(
      id: data['id'],
      displayName: data['displayName'],
      description: data['description'],
      photoURL: data['photoURL'],
      publicKey: data['publicKey'],
      status: data['status'],
      lastSeen: data['lastSeen'].toDate(),
      token: data['token'],
      phoneNumber: data['phoneNumber'],
      createdAt: data['createdAt'].toDate(),
    );
  }
}