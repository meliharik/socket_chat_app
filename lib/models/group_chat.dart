import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreGroupChat {
  final String groupName;
  final String groupDescription;
  final String groupPhotoUrl;
  final List<dynamic> users;
  final DateTime createdAt;
  final String createdBy;

  FirestoreGroupChat({
    required this.groupName,
    required this.groupDescription,
    required this.groupPhotoUrl,
    required this.users,
    required this.createdAt,
    required this.createdBy,
  });

  factory FirestoreGroupChat.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return FirestoreGroupChat(
      groupName: data['groupName'],
      groupDescription: data['groupDescription'],
      groupPhotoUrl: data['groupPhotoUrl'],
      users: data['users'],
      createdBy: data['createdBy'],
      createdAt: data['createdAt'].toDate(),
    );
  }

  // factory for using in the stream builder
  factory FirestoreGroupChat.fromMap(Map data) {
    return FirestoreGroupChat(
      groupName: data['groupName'],
      groupDescription: data['groupDescription'],
      groupPhotoUrl: data['groupPhotoUrl'],
      users: data['users'],
      createdBy: data['createdBy'],
      createdAt: data['createdAt'].toDate(),
    );
  }
}
