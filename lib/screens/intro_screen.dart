// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import 'package:socket_chat_app/controllers/socket_controller.dart';
import 'package:socket_chat_app/models/subscription_models.dart';
import 'chat_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late final TextEditingController _userNameEditingController;
  late final TextEditingController _roomEditingController;

  @override
  void initState() {
    _userNameEditingController = TextEditingController();
    _roomEditingController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //Initilizing and connecting to the socket
      SocketController.get(context)
        ..init()
        ..connect(
          onConnectionError: (data) {
            debugPrint(data.toString());
          },
        );
    });
    super.initState();
  }

  @override
  void dispose() {
    _userNameEditingController.dispose();
    _roomEditingController.dispose();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => SocketController.get(context).dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Socket.IO"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: _userNameEditingController,
              decoration: const InputDecoration(hintText: "Username"),
            ),
            TextField(
              controller: _roomEditingController,
              decoration: const InputDecoration(hintText: "Room Name"),
            ),
            ElevatedButton(
              onPressed: () {
                var subscription = Subscription(
                  roomName: _roomEditingController.text,
                  userName: _userNameEditingController.text,
                );
                // Subscribe and go the Chat screen
                SocketController.get(context).subscribe(
                  subscription,
                  onSubscribe: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ChatScreen()));
                  },
                );
              },
              child: const Text("Join"),
            ),
          ],
        ),
      ),
    );
  }
}
