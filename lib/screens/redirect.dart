import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_chat_app/main.dart';
import 'package:socket_chat_app/screens/auth/enter_number.dart';
import 'package:socket_chat_app/screens/chat_screen.dart';

class RedirectPage extends StatefulWidget {
  const RedirectPage({super.key});

  @override
  State<RedirectPage> createState() => _RedirectPageState();
}

class _RedirectPageState extends State<RedirectPage> {
  @override
  void initState() {
    super.initState();
    userControl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Platform.isAndroid
          ? const Center(child: CircularProgressIndicator())
          : const Center(child: CupertinoActivityIndicator()),
    );
  }

  userControl() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      debugPrint("User is already logged in");
      Navigator.pushAndRemoveUntil(
        GlobalcontextService.navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        GlobalcontextService.navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) => const EnterNumberScreen()),
        (route) => false,
      );
    }
  }
}
