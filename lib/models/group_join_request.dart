import 'package:cloud_firestore/cloud_firestore.dart';

class GroupJoinRequest {
  final String groupName;
  final String groupId;
  final String requestedUserId;
  final String approvedUserId;
  final DateTime createdAt;
  final String aesKey;

  GroupJoinRequest({
    required this.groupName,
    required this.groupId,
    required this.requestedUserId,
    required this.approvedUserId,
    required this.aesKey,
    required this.createdAt,
  });

  factory GroupJoinRequest.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return GroupJoinRequest(
      groupName: data['groupName'],
      groupId: data['groupId'],
      requestedUserId: data['requestedUserId'],
      approvedUserId: data['approvedUserId'],
      aesKey: data['aesKey'],
      createdAt: data['createdAt'].toDate(),
    );
  }

  // factory for using in the stream builder
  factory GroupJoinRequest.fromMap(Map data) {
    return GroupJoinRequest(
      groupName: data['groupName'],
      groupId: data['groupId'],
      requestedUserId: data['requestedUserId'],
      approvedUserId: data['approvedUserId'],
      aesKey: data['aesKey'],
      createdAt: data['createdAt'].toDate(),
    );
  }
}
