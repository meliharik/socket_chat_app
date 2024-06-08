import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_chat_app/controllers/socket_controller.dart';
import 'package:socket_chat_app/screens/chats.dart';
import 'package:socket_chat_app/screens/group_chats.dart';
import 'package:socket_chat_app/screens/settings/settings.dart';
import 'package:socket_chat_app/services/remote_config_service.dart';

class TabBarMain extends StatefulWidget {
  const TabBarMain({super.key});

  @override
  State<TabBarMain> createState() => _TabBarMainState();
}

class _TabBarMainState extends State<TabBarMain> {
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
          connected: () {
            debugPrint('Connected to socket');
          },
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: CupertinoTabScaffold(
        backgroundColor: Colors.transparent,
        tabBar: CupertinoTabBar(
          activeColor: Colors.white,
          inactiveColor: const Color(0xff7E7E7E),
          backgroundColor: Colors.transparent,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_text),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.group_solid),
              label: 'Group Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings),
              label: 'Settings',
            )
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return CupertinoTabView(
            builder: (BuildContext context) {
              switch (index) {
                case 0:
                  return const ChatsScreen();
                case 1:
                  return const GroupChatsScreen();
                case 2:
                  return const SettingsScreen();
                default:
                  return const ChatsScreen();
              }
            },
          );
        },
      ),
    );
  }
}
