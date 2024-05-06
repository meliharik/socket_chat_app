import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_chat_app/models/firestore_user.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  DateTime now = DateTime.now();
  final storage = const FlutterSecureStorage();

  Future<void> createUser({
    required String displayName,
    required String description,
    required String photoUrl,
    required String publicKey,
    required String status,
    required String id,
    required String phoneNumber,
  }) async {
    await firestore.collection('users').doc(phoneNumber).set(
      {
        'id': id,
        'displayName': displayName,
        'description': description,
        'photoURL': photoUrl,
        'publicKey': publicKey,
        'status': status,
        'lastSeen': now,
        'phoneNumber': phoneNumber,
        'createdAt': now,
      },
    );
  }

  Future<void> updateUser({
    required String name,
    required String status,
    required String profileUrl,
    required String phoneNumber,
  }) async {
    await firestore.collection('users').doc(phoneNumber).update(
      {
        'displayName': name,
        'description': status,
        'photoURL': profileUrl,
      },
    );

    auth.currentUser!.updateDisplayName(name);
    auth.currentUser!.updatePhotoURL(profileUrl);
  }

  Future<FirestoreUser> getUserData(String phoneNumber) async {
    var userData = await firestore.collection('users').doc(phoneNumber).get();
    // print(userData.data());
    return FirestoreUser.fromFirestore(userData);
  }

  Stream getChats(String phoneNumber) {
    return firestore
        .collection('chats')
        .doc(phoneNumber)
        .collection('messageTo')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream getUsers() {
    return firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream getUsersExceptCurrentUser() {
    return firestore
        .collection('users')
        .where('phoneNumber', isNotEqualTo: auth.currentUser!.phoneNumber)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
