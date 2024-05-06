// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_chat_app/controllers/socket_controller.dart';

import 'package:socket_chat_app/models/events.dart';
import 'package:socket_chat_app/widget/advanced_text_field.dart';
import 'package:socket_chat_app/widget/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  SocketController? _socketController;
  late final TextEditingController _textEditingController;

  bool _isTextFieldHasContentYet = false;

  @override
  void initState() {
    _textEditingController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _socketController = SocketController.get(context);

      //Start listening to the text editing controller
      _textEditingController.addListener(() {
        final text = _textEditingController.text.trim();
        if (text.isEmpty) {
          _socketController!.stopTyping();
          _isTextFieldHasContentYet = false;
        } else {
          if (_isTextFieldHasContentYet) return;
          _socketController!.typing();
          _isTextFieldHasContentYet = true;
        }
      });

      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _socketController!.unsubscribe();
    _textEditingController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_textEditingController.text.isEmpty) return;
    final message = Message(messageContent: _textEditingController.text);
    _socketController?.sendMessage(message);
    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: Text(_socketController?.subscription?.roomName ?? "-"),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  _socketController!.unsubscribe();
                  Navigator.pop(context);
                },
              )
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: StreamBuilder<List<ChatEvent>>(
                      stream: _socketController?.watchEvents,
                      initialData: const [],
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator.adaptive());
                        }
                        final events = snapshot.data!;
                        if (events.isEmpty) {
                          return const Center(child: Text("Start sending..."));
                        }
                        return ListView.separated(
                          reverse: true,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20.0).add(
                            const EdgeInsets.only(bottom: 70.0),
                          ),
                          itemCount: events.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 5.0),
                          itemBuilder: (context, index) {
                            final event = events[index];
                            //? If the event is a new message
                            if (event is Message) {
                              //TODO: Determin the type of the message user by using user's socket_id not his name.
                              return TextBubble(
                                message: event,
                                type: event.userName ==
                                        _socketController!
                                            .subscription!.userName
                                    ? BubbleType.sendBubble
                                    : BubbleType.receiverBubble,
                              );
                              //? If a user entered or left the room
                            } else if (event is ChatUser) {
                              //? The user has left the current room
                              if (event.userEvent == ChatUserEvent.left) {
                                return Center(
                                    child: Text("${event.userName} left"));
                              }
                              //? The user has joined a new room
                              return Center(
                                  child: Text("${event.userName} has joined"));

                              //? A user started typing event
                            } else if (event is UserStartedTyping) {
                              return const UserTypingBubble();
                            }
                            return const SizedBox();
                          },
                        );
                      }),
                ),
                Positioned.fill(
                  top: null,
                  bottom: 0,
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Expanded(
                          child: AdvancedTextField(
                            controller: _textEditingController,
                            hintText: "Type your message...",
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () => _sendMessage(),
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
