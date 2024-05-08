import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_chat_app/main.dart';
import 'package:socket_chat_app/screens/auth/enter_number.dart';
import 'package:socket_chat_app/widget/tabbar.dart';

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
      backgroundColor: Colors.black,
      body: Platform.isAndroid
          ? const Center(child: CircularProgressIndicator())
          : const Center(child: CupertinoActivityIndicator()),
    );
  }

  userControl() async {
    await Future.delayed(const Duration(seconds: 2));
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      debugPrint("User is already logged in");
      debugPrint('name: ${user.displayName}');
      debugPrint('photo: ${user.photoURL}');
      debugPrint('phone number: ${user.phoneNumber}');
      Navigator.pushAndRemoveUntil(
        GlobalcontextService.navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) => const TabBarMain()),
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
