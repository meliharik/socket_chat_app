import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_chat_app/controllers/socket_controller.dart';

import 'Screens/intro_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => SocketController(),
      child: MaterialApp(
        home: IntroScreen(),
      ),
    );
  }
}
