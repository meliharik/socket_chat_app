import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_chat_app/models/firestore_user.dart';
import 'package:socket_chat_app/models/firestore_message.dart';

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
    return FirestoreUser.fromFirestore(userData);
  }

  Stream getChats(String phoneNumber) {
    return firestore.collection('chats').snapshots();
  }

  Future getChat(List<String> usersPhoneNumbers) async {
    var chat = await firestore
        .collection('chats')
        .where('users', isEqualTo: usersPhoneNumbers)
        .get();

    var chat2 = await firestore
        .collection('chats')
        .where('users', isEqualTo: usersPhoneNumbers.reversed.toList())
        .get();

    // if chat exists return the chat
    if (chat.docs.isNotEmpty) {
      return chat.docs.first;
    } else if (chat2.docs.isNotEmpty) {
      return chat2.docs.first;
    } else {
      // if chat does not exist create a new chat
      var newChat = await firestore.collection('chats').add({
        'users': usersPhoneNumbers,
        'createdAt': now,
      });

      return newChat;
    }
  }

  // create a new message
  Future<void> createMessage({
    required String chatId,
    required String message,
    required String senderPhoneNumber,
    required String receiverPhoneNumber,
  }) async {
    await firestore.collection('chats').doc(chatId).collection('messages').add({
      'messageForReceiver': message,
      'messageForSender': message,
      'senderId': senderPhoneNumber,
      'receiverId': receiverPhoneNumber,
      'createdAt': now,
    });
  }

  // get Messages, future
  Future<List<FirestoreMessage>> getMessages(String chatId) async {
    var messages = await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .get();

    return messages.docs
        .map((message) => FirestoreMessage.fromFirestore(message))
        .toList();
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
