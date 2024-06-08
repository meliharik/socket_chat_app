// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_chat_app/helpers/dialog.dart';
import 'package:socket_chat_app/services/firestore_service.dart';

class CreateGroupChatScreen extends StatefulWidget {
  const CreateGroupChatScreen({super.key});

  @override
  State<CreateGroupChatScreen> createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen> {
  TextEditingController groupNameController = TextEditingController();
  TextEditingController groupDescriptionController = TextEditingController();

  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text(
          "Create Group Chat",
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: groupNameController,
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: "Group Name",
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: groupDescriptionController,
              maxLines: 3,
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: "Group Description",
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                fixedSize: WidgetStateProperty.all(
                  Size(
                    MediaQuery.of(context).size.width,
                    65,
                  ),
                ),
              ),
              onPressed: () async {
                // final key = aes.Key.fromSecureRandom(32);
                // debugPrint(key.base64);
                // return;
                if (groupNameController.text.isEmpty ||
                    groupDescriptionController.text.isEmpty) {
                  DialogHelper().showCustomDialog(
                    title: "Error",
                    subtitle: "Please fill all fields.",
                  );
                  return;
                }
                // name must be unique
                bool exists = await FirestoreService().isGroupChatExist(
                  groupNameController.text,
                );
                if (exists) {
                  DialogHelper().showCustomDialog(
                    title: "Error",
                    subtitle: "Group name already exists.",
                  );
                  return;
                }
                try {
                  await FirestoreService().createGroupChat(
                    createdBy:
                        FirestoreService().auth.currentUser!.phoneNumber!,
                    groupName: groupNameController.text,
                    groupDescription: groupDescriptionController.text,
                  );

                  // get the group chat id
                  String id = await FirestoreService().getGroupChatId(
                    groupNameController.text,
                  );

                  String randomKey = generateRandomKey(32);
                  debugPrint("AES Key: $randomKey");

                  // save the key to the storage
                  await storage.write(key: id, value: randomKey);

                  // final key = aes.Key.fromUtf8(randomKey);
                  // final iv = IV.fromLength(16);

                  // final encrypter = Encrypter(AES(key));

                  // final encrypted =
                  //     encrypter.encrypt('selam ben melih', iv: iv);
                  // debugPrint(encrypted.base64);

                  // // decrypt from base64 and key
                  // final decrypted = encrypter.decrypt(encrypted, iv: iv);
                  // debugPrint(decrypted);

                  Navigator.pop(context);
                } catch (e) {
                  DialogHelper().showCustomDialog(
                    title: "Error",
                    subtitle: "An error occurred. Please try again.",
                  );
                  debugPrint(e.toString());
                }
              },
              child: Text(
                "Create Group",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String generateRandomKey(int length) {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(
            length, (index) => characters[random.nextInt(characters.length)])
        .join();
  }
}
