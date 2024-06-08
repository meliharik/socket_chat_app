import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_chat_app/helpers/space.dart';

class QAScreen extends StatefulWidget {
  const QAScreen({super.key});

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.black,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.0,
          ),
        ),
        previousPageTitle: 'Settings',
        middle: const Text(
          'Q&A',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: _getBody,
    );
  }

  Widget get _getBody => SingleChildScrollView(
        child: Column(
          children: [
            SpaceHelper.height(context, 0.03),
            _aciklamaText,
            SpaceHelper.height(context, 0.03),
            _listTile(
                title: "What is Securely?",
                subtitle:
                    "Securely is a messaging application that allows you to send messages to your friends in a secure way. You can send messages to your friends with end-to-end encryption. You can also send photos."),
            _listTile(
                title: "What is end-to-end encryption?",
                subtitle:
                    "End-to-end encryption is a method of secure communication that prevents third-parties from accessing data while it's transferred from one end system or device to another. End-to-end encryption ensures that only the sender and intended recipient can read the message. End-to-end encryption is important because it protects sensitive data from unauthorized access."),
            _listTile(
                title: "How can I send a message?",
                subtitle:
                    "You can send a message by clicking the plus button in the bottom right corner of the home page."),
            _listTile(
                title: "What is RSA encryption?",
                subtitle:
                    "RSA encryption is a public key encryption technology developed by RSA Data Security. RSA encryption is used by Securely to encrypt messages."),
            _listTile(
                title: "What is a public key?",
                subtitle:
                    "A public key is a cryptographic key that can be used by any person to encrypt a message so that it can only be decrypted by the intended recipient. Public keys are used in asymmetric encryption. Public keys are used to encrypt messages that can only be decrypted by the intended recipient."),
            _listTile(
                title: "What is a private key?",
                subtitle:
                    "A private key is a cryptographic key that can be used by any person to decrypt a message that has been encrypted with the corresponding public key. Private keys are used in asymmetric encryption. Private keys are used to decrypt messages that have been encrypted with the corresponding public key."),
            _listTile(
                title: "What is a symmetric key?",
                subtitle:
                    "A symmetric key is a cryptographic key that can be used by any person to encrypt a message so that it can only be decrypted by the intended recipient. Symmetric keys are used in symmetric encryption. Symmetric keys are used to encrypt messages that can only be decrypted by the intended recipient."),
            _listTile(
                title: "What database does Securely use?",
                subtitle: "Securely uses Firebase Firestore as its database."),
            _listTile(
                title: "What is Firebase Firestore?",
                subtitle:
                    "Firebase Firestore is a NoSQL document database that lets you easily store, sync, and query data for your mobile and web apps - at global scale."),
            SpaceHelper.height(context, 0.2),
          ],
        ),
      );

  Widget _listTile({
    required String title,
    required String subtitle,
  }) {
    return Material(
      color: Colors.transparent,
      child: ExpansionTile(
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        children: [
          ListTile(
            title: Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _aciklamaText => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.of(context).size.width * 0.06,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SpaceHelper.height(context, 0.01),
            Text(
              'You can find answers to frequently asked questions here.',
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.of(context).size.width * 0.045,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
}
