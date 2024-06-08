// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_chat_app/controllers/socket_controller.dart';
import 'package:socket_chat_app/helpers/dialog.dart';
import 'package:socket_chat_app/main.dart';
import 'package:socket_chat_app/models/firestore_user.dart';
import 'package:socket_chat_app/models/subscription_models.dart';
import 'package:socket_chat_app/screens/chat_screen.dart';
import 'package:socket_chat_app/services/firestore_service.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  bool isLoading = false;

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    printPubKey();
  }

  printPubKey() async {
    String? pubKey = await storage.read(key: "pub_key");
    debugPrint('pub_key: $pubKey');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            backgroundColor: Colors.black,
            title: Text(
              "Chats",
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
          ),
          body: StreamBuilder(
              stream: FirestoreService().getUsers(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.requireData;

                  List<FirestoreUser> users = [];

                  for (var i = 0; i < data.docs.length; i++) {
                    var user = data.docs[i];
                    FirestoreUser firestoreUser =
                        FirestoreUser.fromMap(user.data());
                    if (firestoreUser.phoneNumber !=
                        FirestoreService().auth.currentUser!.phoneNumber) {
                      users.add(firestoreUser);
                    }
                  }

                  if (users.isEmpty) {
                    return Center(
                      child: Text(
                        'No chats available',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  debugPrint('snapshot: ${snapshot.connectionState}');

                  return ListView.separated(
                    separatorBuilder: (context, index) =>
                        Divider(color: Colors.grey[800]),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      FirestoreUser user = users[index];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          tileColor: Colors.grey[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              var doc = await FirestoreService().getChat(
                                [
                                  FirestoreService()
                                      .auth
                                      .currentUser!
                                      .phoneNumber!,
                                  user.phoneNumber,
                                ],
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
                                      builder: (_) => ChatScreen(
                                        user: user,
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
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user.photoURL),
                            radius: 25,
                          ),
                          title: Text(user.phoneNumber),
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
