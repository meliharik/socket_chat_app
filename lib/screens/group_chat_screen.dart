import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socket_chat_app/controllers/socket_controller.dart';
import 'package:socket_chat_app/models/events.dart';
import 'package:socket_chat_app/models/firestore_group_message.dart';
import 'package:socket_chat_app/models/group_chat.dart';
import 'package:socket_chat_app/services/firestore_service.dart';
import 'package:socket_chat_app/widget/advanced_text_field.dart';
import 'package:socket_chat_app/widget/chat_bubble.dart';

class GroupChatScreen extends StatefulWidget {
  final FirestoreGroupChat chat;
  final String chatId;
  const GroupChatScreen({super.key, required this.chat, required this.chatId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  SocketController? _socketController;
  late final TextEditingController _textEditingController;

  bool _isTextFieldHasContentYet = false;

  List<FirestoreGroupMessage> messages = [];
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
    await FirestoreService().getGroupMessages(widget.chatId).then((value) {
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
    // close the keyboard
    FocusScope.of(context).unfocus();
    final message = Message(messageContent: _textEditingController.text);
    _socketController?.sendMessage(message);
    FirestoreService().createGroupChatMessage(
      chatId: widget.chatId,
      message: _textEditingController.text,
      senderPhoneNumber: FirebaseAuth.instance.currentUser!.phoneNumber!,
    );
    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text(
          widget.chat.groupName,
          style: const TextStyle(
            color: Colors.white,
          ),
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
                      FirestoreGroupMessage message = messages[index];
                      if (message.senderId ==
                          FirebaseAuth.instance.currentUser!.phoneNumber) {
                        return Column(
                          children: [
                            Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Text(message.senderId),
                              ],
                            ),
                            Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                InkWell(
                                  onLongPress: () {
                                    Clipboard.setData(ClipboardData(
                                        text: message.senderId.trim()));
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
                                        message.message,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10)
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            Row(
                              textDirection: TextDirection.ltr,
                              children: [
                                Text(message.senderId),
                              ],
                            ),
                            Row(
                              textDirection: TextDirection.ltr,
                              children: [
                                InkWell(
                                  onLongPress: () {
                                    Clipboard.setData(ClipboardData(
                                        text: message.message.trim()));
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
                                        message.message,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10)
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
                          return const Center(child: Text("Start sending..."));
                        }
                        return ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
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
                              return Column(
                                children: [
                                  Row(
                                    textDirection: event.userName ==
                                            _socketController!
                                                .subscription!.userName
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    children: [
                                      Text(event.userName.toString()),
                                    ],
                                  ),
                                  TextBubble(
                                    message: event,
                                    type: event.userName ==
                                            _socketController!
                                                .subscription!.userName
                                        ? BubbleType.sendBubble
                                        : BubbleType.receiverBubble,
                                  ),
                                  const SizedBox(height: 10),
                                ],
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
    );
  }
}
