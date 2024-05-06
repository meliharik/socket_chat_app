import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_chat_app/main.dart';

class DialogHelper {
  Future<dynamic> showCustomDialog({
    required String title,
    required String subtitle,
  }) {
    if (Platform.isAndroid) {
      return showDialog(
        context: GlobalcontextService.navigatorKey.currentContext!,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            content: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              )
            ],
          );
        },
      );
    } else {
      return showCupertinoDialog(
        context: GlobalcontextService.navigatorKey.currentContext!,
        builder: (context) {
          if (Platform.isIOS) {
            return CupertinoAlertDialog(
              title: Text(title),
              content: Text(subtitle),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          } else {
            return AlertDialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              content: Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                )
              ],
            );
          }
        },
      );
    }
  }
}
