import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_chat_app/helpers/space.dart';
import 'package:socket_chat_app/models/firestore_user.dart';

class PrivacyScreen extends StatefulWidget {
  final FirestoreUser user;
  const PrivacyScreen({super.key, required this.user});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      navigationBar: navBar(),
      child: Column(
        children: [
          publicKeyTile(context),
          SpaceHelper.height(context, 0.02),
          privateKeyTile(context),
        ],
      ),
    );
  }

  Padding privateKeyTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: () async {
              var privateKey = await storage.read(key: "pri_key");
              showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Text(
                      'Your private key',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Text(
                        privateKey!,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    actions: [
                      // copy to clipboard button
                      CupertinoDialogAction(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: privateKey),
                          );
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Copy',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Close',
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            title: Text(
              'View your private key',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              'Do not share this key with anyone!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding publicKeyTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: () async {
              showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Text(
                      'Your public key',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Text(
                        widget.user.publicKey,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    actions: [
                      // copy to clipboard button
                      CupertinoDialogAction(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.user.publicKey),
                          );
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Copy',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Close',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            title: Text(
              'View your public key',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  CupertinoNavigationBar navBar() {
    return CupertinoNavigationBar(
      previousPageTitle: 'Settings',
      backgroundColor: Colors.black,
      border: Border(
        bottom: BorderSide(
          color: Colors.grey,
          width: 0.0,
        ),
      ),
      middle: Text(
        'Privacy',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
