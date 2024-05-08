// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socket_chat_app/controllers/socket_controller.dart';
import 'package:socket_chat_app/models/events.dart';
import 'package:socket_chat_app/models/firestore_message.dart';
import 'package:socket_chat_app/models/firestore_user.dart';
import 'package:socket_chat_app/services/firestore_service.dart';
import 'package:socket_chat_app/widget/advanced_text_field.dart';
import 'package:socket_chat_app/widget/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final FirestoreUser user;
  final String chatId;
  const ChatScreen({super.key, required this.user, required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  SocketController? _socketController;
  late final TextEditingController _textEditingController;

  bool _isTextFieldHasContentYet = false;

  List<FirestoreMessage> messages = [];
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    _textEditingController = TextEditingController();

    getMessages();
    scrollDown();
    super.initState();
  }

  @override
  void dispose() {
    _socketController!.unsubscribe();
    _textEditingController.dispose();
    super.dispose();
  }

  getMessages() async {
    await FirestoreService().getMessages(widget.chatId).then((value) {
      setState(() {
        messages = value;
      });
    });
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
  }

  void scrollDown() {
    // _controller.jumpTo(0);
  }

  void _sendMessage() {
    if (_textEditingController.text.isEmpty) return;
    FocusScope.of(context).unfocus();

    final message = Message(messageContent: _textEditingController.text);
    _socketController?.sendMessage(message);
    FirestoreService().createMessage(
      chatId: widget.chatId,
      message: _textEditingController.text,
      senderPhoneNumber: FirebaseAuth.instance.currentUser!.phoneNumber!,
      receiverPhoneNumber: widget.user.phoneNumber,
    );
    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.black,
            centerTitle: true,
            // users circle avatar and phone number
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.user.photoURL),
                  // radius: 25,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.user.phoneNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            leading: IconButton(
              icon: const Icon(CupertinoIcons.back),
              onPressed: () {
                _socketController!.unsubscribe();
                Navigator.pop(context);
              },
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0)
                            .add(const EdgeInsets.only(bottom: 70.0)),
                        itemCount: messages.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 5.0),
                        itemBuilder: (context, index) {
                          FirestoreMessage message = messages[index];
                          if (message.senderId ==
                              FirebaseAuth.instance.currentUser!.phoneNumber) {
                            return Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                InkWell(
                                  onLongPress: () {
                                    Clipboard.setData(ClipboardData(
                                        text: message.messageForSender.trim()));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text("Copied to Clipboard")));
                                  },
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        minWidth: 0),
                                    margin: const EdgeInsets.only(top: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.blue,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Text(
                                        message.messageForSender,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              textDirection: TextDirection.ltr,
                              children: [
                                InkWell(
                                  onLongPress: () {
                                    Clipboard.setData(ClipboardData(
                                        text:
                                            message.messageForReceiver.trim()));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text("Copied to Clipboard")));
                                  },
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        minWidth: 0),
                                    margin: const EdgeInsets.only(top: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.green,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Text(
                                        message.messageForReceiver,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      StreamBuilder<List<ChatEvent>>(
                          stream: _socketController?.watchEvents,
                          initialData: const [],
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator.adaptive());
                            }
                            final events = snapshot.data!;
                            if (events.isEmpty) {
                              return const Center(
                                  child: Text("Start sending..."));
                            }
                            return ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              reverse: true,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0)
                                      .add(
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
                                      child:
                                          Text("${event.userName} has joined"));

                                  //? A user started typing event
                                } else if (event is UserStartedTyping) {
                                  return const UserTypingBubble();
                                }
                                return const SizedBox();
                              },
                            );
                          }),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.08,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(30),
                          ),
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
                              IconButton(
                                onPressed: () => _sendMessage(),
                                icon: const Icon(Icons.send),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
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
