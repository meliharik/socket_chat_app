// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';

import 'package:fast_rsa/fast_rsa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_chat_app/controllers/socket_controller.dart';
import 'package:socket_chat_app/models/events.dart';
import 'package:socket_chat_app/models/firestore_message.dart';
import 'package:socket_chat_app/models/firestore_user.dart';
import 'package:socket_chat_app/screens/encrypted_messages.dart';
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

  final storage = const FlutterSecureStorage();

  List<String> messagesString = [];

  @override
  void initState() {
    _textEditingController = TextEditingController();

    getMessages();
    socketSetup();
    printPublicKeys();
    super.initState();
  }

  printPublicKeys() async {
    var publicKey = await storage.read(key: "pub_key");

    debugPrint("publicKey: $publicKey");

    var publicKey2 = widget.user.publicKey;

    debugPrint("publicKey2: $publicKey2");
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

    for (var element in messages) {
      messagesString.add(await decryptMsg(
        element.messageForReceiver,
        element.senderId,
        element.receiverId,
        element.messageForSender,
      ));
    }
    setState(() {});
  }

  socketSetup() {
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

  Future<void> _sendMessage() async {
    if (_textEditingController.text.isEmpty) return;
    FocusScope.of(context).unfocus();

    final message = Message(messageContent: _textEditingController.text);
    _socketController?.sendMessage(message);
    FirestoreService().createMessage(
      chatId: widget.chatId,
      messageForReceiver: await encryptMsg(_textEditingController.text),
      messageForSender: await encryptMsgForSender(_textEditingController.text),
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
            actions: [
              //developer icon
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EncryptedMessagesScreen(
                        chatId: widget.chatId,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.developer_mode),
              ),
            ],
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.black,
            centerTitle: true,
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
                            return FutureBuilder(
                                future: decryptMsg(
                                  message.messageForReceiver,
                                  message.senderId,
                                  message.receiverId,
                                  message.messageForSender,
                                ),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    String messageString = snapshot.data;
                                    debugPrint("messageString: $messageString");

                                    return Row(
                                      textDirection: TextDirection.rtl,
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.6,
                                            minWidth: 0,
                                          ),
                                          margin: const EdgeInsets.only(top: 5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: Colors.blue,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            child: Text(
                                              messageString,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const SizedBox();
                                  }
                                });
                          } else {
                            return FutureBuilder(
                                future: decryptMsg(
                                  message.messageForReceiver,
                                  message.senderId,
                                  message.receiverId,
                                  message.messageForSender,
                                ),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    String messageString = snapshot.data;
                                    debugPrint(
                                        "messageString2: $messageString");
                                    return Row(
                                      textDirection: TextDirection.ltr,
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.6,
                                            minWidth: 0,
                                          ),
                                          margin: const EdgeInsets.only(top: 5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: Colors.green,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            child: Text(
                                              messageString,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const SizedBox();
                                  }
                                });
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

  Future<String> decryptMsg(
    String secretMessage,
    String senderId,
    String receiverId,
    String secretMessageForSender,
  ) async {
    var privateKey = await storage.read(key: "pri_key");
    var userid = await storage.read(key: "number");

    debugPrint('privateKey: $privateKey');
    debugPrint('userid: $userid');

    debugPrint('secretMessage: $secretMessage');
    debugPrint('senderId: $senderId');
    debugPrint('receiverId: $receiverId');
    debugPrint('secretMessageForSender: $secretMessageForSender');

    // debugPrint("privateKey: $privateKey");

    if (senderId == userid) {
      var deMsg =
          await RSA.decryptPKCS1v15(secretMessageForSender, privateKey!);
      debugPrint(deMsg);

      return deMsg;
    }

    // debugPrint("privateKey: $privateKey");

    var deMsg = await RSA.decryptPKCS1v15(secretMessage, privateKey!);
    debugPrint(deMsg);

    return deMsg;
  }

  Future<String> encryptMsg(String message) async {
    String publicKey = '';
    publicKey = widget.user.publicKey;
    debugPrint('widget.user.publicKey: $publicKey');
    debugPrint('message: $message');

    var enMsg = await RSA.encryptPKCS1v15(message, publicKey);
    debugPrint("enMsg: $enMsg");

    return enMsg;
  }

  Future<String> encryptMsgForSender(String message) async {
    var publicKey = await storage.read(key: "pub_key") ?? '';

    debugPrint("publicKey: $publicKey");
    debugPrint('message: $message');

    var enMsg = await RSA.encryptPKCS1v15(message, publicKey);
    debugPrint("enMsg: $enMsg");

    return enMsg;
  }
}
