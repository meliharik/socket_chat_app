// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_chat_app/controllers/socket_controller.dart';
import 'package:socket_chat_app/helpers/dialog.dart';
import 'package:socket_chat_app/main.dart';
import 'package:socket_chat_app/models/group_chat.dart';
import 'package:socket_chat_app/models/subscription_models.dart';
import 'package:socket_chat_app/screens/create_group_chat.dart';
import 'package:socket_chat_app/screens/group_chat_screen.dart';
import 'package:socket_chat_app/screens/group_requests.dart';
import 'package:socket_chat_app/services/firestore_service.dart';

class GroupChatsScreen extends StatefulWidget {
  const GroupChatsScreen({super.key});

  @override
  State<GroupChatsScreen> createState() => _GroupChatsScreenState();
}

class _GroupChatsScreenState extends State<GroupChatsScreen> {
  bool isLoading = false;
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.push(
                  GlobalcontextService.navigatorKey.currentContext!,
                  MaterialPageRoute(
                    builder: (_) => const GroupRequestsScreen(),
                  ),
                );
              },
              icon: const Icon(CupertinoIcons.question),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    GlobalcontextService.navigatorKey.currentContext!,
                    MaterialPageRoute(
                      builder: (_) => const CreateGroupChatScreen(),
                    ),
                  );
                },
                icon: const Icon(CupertinoIcons.add),
              ),
            ],
            centerTitle: true,
            backgroundColor: Colors.black,
            title: Text(
              "Group Chats",
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
          ),
          body: StreamBuilder(
              stream: FirestoreService().getGroups(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.requireData;

                  List<FirestoreGroupChat> users = [];
                  List<String> docIds = [];

                  for (var i = 0; i < data.docs.length; i++) {
                    var user = data.docs[i];
                    FirestoreGroupChat firestoreGroupChat =
                        FirestoreGroupChat.fromMap(user.data());
                    users.add(firestoreGroupChat);
                    docIds.add(user.id);
                  }

                  if (users.isEmpty) {
                    return Center(
                      child: Text(
                        'No group chats available',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    separatorBuilder: (context, index) =>
                        Divider(color: Colors.grey[800]),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      FirestoreGroupChat user = users[index];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          tileColor: Colors.grey[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onTap: () async {
                            bool haveKey = await storage.read(
                                        key: docIds[index]) !=
                                    null &&
                                await storage.read(key: docIds[index]) != '';
                            if (!haveKey) {
                              showCupertinoDialog(
                                context: GlobalcontextService
                                    .navigatorKey.currentContext!,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: const Text(
                                      'Ooppsss',
                                    ),
                                    content: const Text(
                                      'You need to be a member of this group to chat. Please ask the group admin to add you.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          await FirestoreService()
                                              .createGroupJoinRequest(
                                            groupId: docIds[index],
                                            groupName: user.groupName,
                                            requestedUserId: FirestoreService()
                                                .auth
                                                .currentUser!
                                                .phoneNumber!,
                                            approvedUserId: user.createdBy,
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Send Request'),
                                      ),
                                      // close btn
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            }
                            String groupAesKey =
                                await storage.read(key: docIds[index]) ?? '';
                            debugPrint('groupAesKey: $groupAesKey');
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              var doc = await FirestoreService().getGroupChat(
                                docIds[index],
                              );
                              var subscription = Subscription(
                                roomName: doc.id,
                                userName: FirestoreService()
                                    .auth
                                    .currentUser!
                                    .phoneNumber!,
                              );
                              // Subscribe and go the Chat screen
                              SocketController.get(context).subscribe(
                                subscription,
                                onSubscribe: () {
                                  Navigator.push(
                                    GlobalcontextService
                                        .navigatorKey.currentContext!,
                                    MaterialPageRoute(
                                      builder: (_) => GroupChatScreen(
                                        chat: user,
                                        chatId: doc.id,
                                      ),
                                    ),
                                  );
                                },
                              );
                            } catch (e) {
                              debugPrint('Error: ${e.toString()}');
                              DialogHelper().showCustomDialog(
                                title: 'Error',
                                subtitle:
                                    'An error occurred. Please try again.',
                              );
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          trailing: const Icon(
                            CupertinoIcons.chevron_right,
                            color: Colors.white,
                            size: 20,
                          ),
                          subtitle: Text(
                            docIds[index],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user.groupPhotoUrl),
                            radius: 25,
                          ),
                          title: Text(user.groupName),
                        ),
                      );
                    },
                  );
                }
                debugPrint('snapshot: ${snapshot.connectionState}');
                return Center(
                  child: Platform.isAndroid
                      ? const CircularProgressIndicator()
                      : const CupertinoActivityIndicator(),
                );
              }),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Platform.isAndroid
                  ? const CircularProgressIndicator()
                  : const CupertinoActivityIndicator(),
            ),
          ),
      ],
    );
  }
}
