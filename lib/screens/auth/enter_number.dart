import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_chat_app/Screens/auth/verify_number.dart';
import 'package:socket_chat_app/helpers/dialog.dart';

class EnterNumberScreen extends StatefulWidget {
  const EnterNumberScreen({super.key});

  @override
  State<EnterNumberScreen> createState() => _EnterNumberScreenState();
}

class _EnterNumberScreenState extends State<EnterNumberScreen> {
  bool isLoading = false;
  TextEditingController numberEditingController = TextEditingController();
  String verificationId = '';

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
                  10) {
                DialogHelper().showCustomDialog(
                  title: "Error",
                  subtitle: "Please enter a valid number",
                );
                return;
              }
              verifyPhoneNumber();
            },
            child: Text(
              "Send OTP",
              style: GoogleFonts.poppins(
                color: Colors.black,
              ),
            ),
          ),
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(
              "Enter Number",
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
                          PhoneInputFormatter(
                            defaultCountryCode: 'TR',
                          ),
                        ],
                        cursorColor: Colors.white,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter Number (555 555 55 55)",
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

  Future verifyPhoneNumber() async {
    try {
      setState(() {
        isLoading = true;
      });
      FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+90${numberEditingController.text.replaceAll(' ', '')}',
        verificationCompleted: (phonesAuthCredentials) async {
          debugPrint(phonesAuthCredentials.toString());
          setState(() {
            isLoading = false;
          });
        },
        verificationFailed: (verificationFailed) async {
          debugPrint(verificationFailed.message.toString());
          setState(() {
            isLoading = false;
          });
          DialogHelper().showCustomDialog(
            title: 'Error',
            subtitle: verificationFailed.message.toString(),
          );
        },
        codeSent: (verificationId, resendingToken) async {
          debugPrint(verificationId);
          setState(() {
            isLoading = false;
            this.verificationId = verificationId;
          });
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => VerifyNumberScreen(
                verificationId: verificationId,
                phoneNumber: '+90 ${numberEditingController.text}',
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) async {
          debugPrint(verificationId);
          setState(() {
            isLoading = false;
          });
          DialogHelper().showCustomDialog(
            title: 'Error',
            subtitle: 'Code auto retrieval timeout.',
          );
        },
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("hata: $e");
      DialogHelper().showCustomDialog(
        title: 'Error',
        subtitle: e.toString(),
      );
    }
  }
}
