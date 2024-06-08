import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_chat_app/models/firestore_group_message.dart';
import 'package:socket_chat_app/models/firestore_message.dart';
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

  Future<bool> isUserExist(String phoneNumber) async {
    var user = await firestore.collection('users').doc(phoneNumber).get();
    if (user.exists) {
      return true;
    } else {
      return false;
    }
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

  Future getGroupChat(String chatId) async {
    var chat = await firestore.collection('groupChats').doc(chatId).get();
    return chat;
  }

  // get group chat id
  Future<String> getGroupChatId(String groupName) async {
    var chat = await firestore
        .collection('groupChats')
        .where('groupName', isEqualTo: groupName)
        .get();

    return chat.docs.first.id;
  }

  // group chat must be unique
  Future<bool> isGroupChatExist(String groupName) async {
    var chat = await firestore
        .collection('groupChats')
        .where('groupName', isEqualTo: groupName)
        .get();

    if (chat.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  // create a new message
  Future<void> createMessage({
    required String chatId,
    required String messageForReceiver,
    required String messageForSender,
    required String senderPhoneNumber,
    required String receiverPhoneNumber,
  }) async {
    await firestore.collection('chats').doc(chatId).collection('messages').add({
      'messageForReceiver': messageForReceiver,
      'messageForSender': messageForSender,
      'senderId': senderPhoneNumber,
      'receiverId': receiverPhoneNumber,
      'createdAt': now,
    });
  }

  // create group chat message
  Future<void> createGroupChatMessage({
    required String chatId,
    required String message,
    required String senderPhoneNumber,
  }) async {
    await firestore
        .collection('groupChats')
        .doc(chatId)
        .collection('messages')
        .add({
      'message': message,
      'senderId': senderPhoneNumber,
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

  // get Messages, future
  Future<List<FirestoreGroupMessage>> getGroupMessages(String chatId) async {
    var messages = await firestore
        .collection('groupChats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .get();

    return messages.docs
        .map((message) => FirestoreGroupMessage.fromFirestore(message))
        .toList();
  }

  // get group chats
  Stream getGroups() {
    return firestore
        .collection('groupChats')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // create a new group chat
  Future<void> createGroupChat({
    required String groupName,
    required String groupDescription,
    required String createdBy,
    String groupPhotoUrl = 'https://picsum.photos/200',
    List<String> users = const [],
  }) async {
    await firestore.collection('groupChats').add({
      'groupName': groupName,
      'groupDescription': groupDescription,
      'groupPhotoUrl': groupPhotoUrl,
      'users': users,
      'createdAt': now,
      'createdBy': createdBy,
    });
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

  // create group join request
  //   required this.groupName,
  // required this.groupId,
  // required this.requestedUserId,
  // required this.approvedUserId,
  // required this.aesKey,
  // required this.createdAt,

  Future<void> createGroupJoinRequest({
    required String groupName,
    required String groupId,
    required String requestedUserId,
    required String approvedUserId,
  }) async {
    // first check if the request already exists
    var request = await firestore
        .collection('groupJoinRequests')
        .where('groupId', isEqualTo: groupId)
        .where('requestedUserId', isEqualTo: requestedUserId)
        .get();

    if (request.docs.isNotEmpty) {
      return;
    }

    await firestore.collection('groupJoinRequests').add({
      'groupName': groupName,
      'groupId': groupId,
      'requestedUserId': requestedUserId,
      'approvedUserId': approvedUserId,
      'aesKey': '',
      'createdAt': now,
    });
  }

  // get group join requests for approval
  Stream getCurrentUsersGroupRequest(String phoneNumber) {
    return firestore
        .collection('groupJoinRequests')
        .where('requestedUserId', isEqualTo: phoneNumber)
        .snapshots();
  }

  // approve group join request
  Future<void> approveGroupJoinRequest({
    required String groupId,
    required String requestedUserId,
    required String aesKey,
  }) async {
    var request = await firestore
        .collection('groupJoinRequests')
        .where('groupId', isEqualTo: groupId)
        .where('requestedUserId', isEqualTo: requestedUserId)
        .get();

        

    if (request.docs.isNotEmpty) {
      await firestore
          .collection('groupJoinRequests')
          .doc(request.docs.first.id)
          .update({
        'aesKey': aesKey,
        // 'approvedUserId': auth.currentUser!.phoneNumber,
      });

      // add user to the group
      await firestore.collection('groupChats').doc(groupId).update({
        'users': FieldValue.arrayUnion([requestedUserId]),
      });
    }
  }

  // get group join requests for approval
  Stream getGroupJoinRequestsForApproval(String phoneNumber) {
    return firestore
        .collection('groupJoinRequests')
        .where('approvedUserId', isEqualTo: phoneNumber)
        .snapshots();
  }
}
