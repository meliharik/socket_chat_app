// // ignore_for_file: library_private_types_in_public_api

// import 'package:flutter/material.dart';

// import 'package:socket_chat_app/controllers/socket_controller.dart';
// import 'package:socket_chat_app/models/subscription_models.dart';
// import 'chat_screen.dart';

// class IntroScreen extends StatefulWidget {
//   const IntroScreen({super.key});

//   @override
//   _IntroScreenState createState() => _IntroScreenState();
// }

// class _IntroScreenState extends State<IntroScreen> {
//   late final TextEditingController _userNameEditingController;
//   late final TextEditingController _roomEditingController;

//   @override
//   void initState() {
//     _userNameEditingController = TextEditingController();
//     _roomEditingController = TextEditingController();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       //Initilizing and connecting to the socket
//       SocketController.get(context)
//         ..init()
//         ..connect(
//           onConnectionError: (data) {
//             debugPrint(data.toString());
//           },
//         );
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _userNameEditingController.dispose();
//     _roomEditingController.dispose();
//     WidgetsBinding.instance
//         .addPostFrameCallback((_) => SocketController.get(context).dispose());
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Socket.IO"),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             TextField(
//               controller: _userNameEditingController,
//               decoration: const InputDecoration(hintText: "Username"),
//             ),
//             TextField(
//               controller: _roomEditingController,
//               decoration: const InputDecoration(hintText: "Room Name"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 var subscription = Subscription(
//                   roomName: _roomEditingController.text,
//                   userName: _userNameEditingController.text,
//                 );
//                 // Subscribe and go the Chat screen
//                 SocketController.get(context).subscribe(
//                   subscription,
//                   onSubscribe: () {
//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (_) => const ChatScreen()));
//                   },
//                 );
//               },
//               child: const Text("Join"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_chat_app/controllers/socket_controller.dart';
import 'package:socket_chat_app/helpers/dialog.dart';
import 'package:socket_chat_app/models/firestore_user.dart';
import 'package:socket_chat_app/models/subscription_models.dart';
import 'package:socket_chat_app/screens/chat_screen.dart';
import 'package:socket_chat_app/services/firestore_service.dart';
import 'package:socket_chat_app/services/remote_config_service.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  void initState() {
    super.initState();
    socketConnection();
  }

  socketConnection() async {
    String url = await FirebaseRemoteConfigService()
        .getString(FirebaseRemoteConfigKeys.url);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //Initilizing and connecting to the socket
      SocketController.get(context)
        ..init(url: url)
        ..connect(
          onConnectionError: (data) {
            debugPrint(data.toString());
          },
        );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => SocketController.get(context).dispose());
    super.dispose();
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
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
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        user:user,
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
