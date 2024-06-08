import 'package:fast_rsa/fast_rsa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_chat_app/models/firestore_user.dart';
import 'package:socket_chat_app/models/group_join_request.dart';
import 'package:socket_chat_app/services/firestore_service.dart';

class GroupRequestsScreen extends StatefulWidget {
  const GroupRequestsScreen({super.key});

  @override
  State<GroupRequestsScreen> createState() => _GroupRequestsScreenState();
}

class _GroupRequestsScreenState extends State<GroupRequestsScreen> {
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: const Text(
          "Group Requests",
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const Text(
                  'Requests for approval',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: FirestoreService().getGroupJoinRequestsForApproval(
                      FirebaseAuth.instance.currentUser!.phoneNumber!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data = snapshot.requireData;
                        List<GroupJoinRequest> groupRequests = [];

                        for (var i = 0; i < data.docs.length; i++) {
                          var groupRequest = data.docs[i];
                          GroupJoinRequest groupJoinRequest =
                              GroupJoinRequest.fromMap(groupRequest.data());
                          groupRequests.add(groupJoinRequest);
                        }

                        if (groupRequests.isEmpty) {
                          return const Center(
                            child: Text(
                              'No group requests available',
                            ),
                          );
                        }

                        return ListView.separated(
                            itemCount: groupRequests.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  'Group Name: ${groupRequests[index].groupName}',
                                ),
                                subtitle: Text(
                                  'User: ${groupRequests[index].requestedUserId}',
                                ),
                                trailing: groupRequests[index].aesKey.isNotEmpty
                                    ? const Text('Accepted')
                                    : IconButton(
                                        icon: const Icon(Icons.check),
                                        onPressed: () {
                                          accept(groupRequests[index]);
                                        },
                                      ),
                              );
                            });
                      } else if (snapshot.hasError) {
                        debugPrint(snapshot.error.toString());
                        return Text(snapshot.error.toString());
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey[800],
            height: 3,
            thickness: 3,
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const Text(
                  'Your requests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: FirestoreService().getCurrentUsersGroupRequest(
                      FirebaseAuth.instance.currentUser!.phoneNumber!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data = snapshot.requireData;
                        List<GroupJoinRequest> groupRequests = [];

                        for (var i = 0; i < data.docs.length; i++) {
                          var groupRequest = data.docs[i];
                          GroupJoinRequest groupJoinRequest =
                              GroupJoinRequest.fromMap(groupRequest.data());
                          groupRequests.add(groupJoinRequest);
                        }

                        if (groupRequests.isEmpty) {
                          return const Center(
                            child: Text(
                              'No group requests available',
                            ),
                          );
                        }

                        return ListView.separated(
                            itemCount: groupRequests.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  'Group Name: ${groupRequests[index].groupName}',
                                ),
                                subtitle: Text(
                                  'User: ${groupRequests[index].requestedUserId}',
                                ),
                                trailing: groupRequests[index].aesKey.isEmpty
                                    ? const Text('Pending')
                                    : ElevatedButton(
                                        onPressed: () {
                                          decryptMsg(
                                            groupRequests[index].groupId,
                                            groupRequests[index].aesKey,
                                          );
                                        },
                                        child: const Text('Save Key'),
                                      ),
                              );
                            });
                      } else if (snapshot.hasError) {
                        debugPrint(snapshot.error.toString());
                        return Text(snapshot.error.toString());
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> encryptMsg(String aesKey, String rsaPublicKey) async {
    var enMsg = await RSA.encryptPKCS1v15(aesKey, rsaPublicKey);
    debugPrint("enMsg: $enMsg");

    return enMsg;
  }

  void accept(GroupJoinRequest groupRequest) async {
    String groupAesKey = '';
    groupAesKey = await storage.read(key: groupRequest.groupId) ?? '';

    //get users data
    FirestoreUser user =
        await FirestoreService().getUserData(groupRequest.requestedUserId);

    // encrypt groupAesKey with user's public key
    String encryptedAesKey = await encryptMsg(groupAesKey, user.publicKey);

    // update group join request
    await FirestoreService().approveGroupJoinRequest(
      groupId: groupRequest.groupId,
      requestedUserId: groupRequest.requestedUserId,
      aesKey: encryptedAesKey,
    );
  }

  Future<String> decryptMsg(
    String groupId,
    String message,
  ) async {
    var privateKey = await storage.read(key: "pri_key");

    var deMsg = await RSA.decryptPKCS1v15(message, privateKey!);
    debugPrint(deMsg);

    await storage.write(key: groupId, value: deMsg);

    return deMsg;
  }
}
