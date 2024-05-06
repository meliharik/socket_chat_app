// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_chat_app/helpers/dialog.dart';
import 'package:socket_chat_app/main.dart';
import 'package:socket_chat_app/screens/intro_screen.dart';
import 'package:socket_chat_app/services/firestore_service.dart';

class VerifyNumberScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  const VerifyNumberScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<VerifyNumberScreen> createState() => _VerifyNumberScreenState();
}

class _VerifyNumberScreenState extends State<VerifyNumberScreen> {
  bool isLoading = false;

  TextEditingController controller = TextEditingController();

  //rsa variables
  var key, pub_key, pri_key;
  var message;

  final storage = const FlutterSecureStorage();

  TextEditingController numberEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          floatingActionButton: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              fixedSize: Size(MediaQuery.of(context).size.width - 16, 60),
            ),
            onPressed: () {
              if (numberEditingController.text.isEmpty) {
                DialogHelper().showCustomDialog(
                  title: "Error",
                  subtitle: "Please enter a valid number",
                );
                return;
              }
              if (numberEditingController.text.replaceAll(" ", "").length !=
                  6) {
                DialogHelper().showCustomDialog(
                  title: "Error",
                  subtitle: "Please enter a valid number",
                );
                return;
              }
              sendCodeToFirebase();
            },
            child: Text(
              "Verify OTP",
              style: GoogleFonts.poppins(
                color: Colors.black,
              ),
            ),
          ),
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(
              "Enter OTP",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.black,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: numberEditingController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        cursorColor: Colors.white,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter OTP",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.white70,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Platform.isIOS
                  ? const CupertinoActivityIndicator(
                      animating: true,
                    )
                  : const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
            ),
          ),
      ],
    );
  }

  Future sendCodeToFirebase() async {
    setState(() {
      isLoading = true;
    });
    var credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: numberEditingController.text);

    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((value) async {
          // search users collection for the user
          var user = await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.phoneNumber.replaceAll(' ', ''))
              .get();
          if (!user.exists) {
            ////////////////////////////////////////////////////
            ////////////////////generating key//////////////////
            ////////////////////////////////////////////////////

            key = await RSA.generate(2048);
            setState(() {
              pub_key = key.publicKey;
              pri_key = key.privateKey;
            });

            ////////////////////////////////////////////////////
            // in shared preference
            // Write value
            await storage.write(key: "pri_key", value: pri_key);

            String phoneNumber = widget.phoneNumber.replaceAll(' ', '');

            await storage.write(
              key: "number",
              value: phoneNumber,
            );

            await FirestoreService().createUser(
              id: phoneNumber,
              displayName: 'Unknown',
              description: 'Hey! I am safe with Securely.',
              photoUrl:
                  "https://api.dicebear.com/7.x/bottts-neutral/png?seed=$phoneNumber",
              publicKey: pub_key.toString(),
              status: 'Online',
              
              phoneNumber: phoneNumber,
            );
            setState(() {
              isLoading = false;
            });

            User? user = FirebaseAuth.instance.currentUser;

            user!.updateDisplayName('Unknown');
            user.updatePhotoURL(
                "https://api.dicebear.com/7.x/bottts-neutral/png?seed=$phoneNumber");

            // storage.write(key: "name", value: "Unknown");
            // storage.write(
            //   key: "photoURL",
            //   value:
            //       "https://api.dicebear.com/7.x/bottts-neutral/png?seed=$phoneNumber",
            // );

            debugPrint(user.photoURL.toString());
            debugPrint(user.displayName.toString());

            // Navigator.pushAndRemoveUntil(
            //   context,
            //   CupertinoPageRoute(
            //     builder: (context) => const CreateProfilePage(),
            //   ),
            //   (route) => false,
            // );
          } else {
            String phoneNumber = widget.phoneNumber.replaceAll(' ', '');

            // writing phone number in shared preferences
            await storage.write(key: "number", value: phoneNumber);

            setState(() {
              isLoading = false;
            });

            Navigator.pushAndRemoveUntil(
              GlobalcontextService.navigatorKey.currentContext!,
              CupertinoPageRoute(builder: (context) => const IntroScreen()),
              (route) => false,
            );
          }
        })
        .whenComplete(() {})
        .onError((error, stackTrace) {
          debugPrint("hata: $error");
          setState(() {
            isLoading = false;
          });
          if (error.toString().contains("invalid-verification-code")) {
            DialogHelper().showCustomDialog(
              title: 'Error',
              subtitle: 'Invalid verification code.',
            );
          } else {
            DialogHelper().showCustomDialog(
              title: 'Error',
              subtitle: error.toString(),
            );
          }
        });
  }
}
