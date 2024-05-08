import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                  borderSide: BorderSide(
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
                  borderSide: BorderSide(
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
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                fixedSize: MaterialStateProperty.all(
                  Size(
                    MediaQuery.of(context).size.width,
                    65,
                  ),
                ),
              ),
              onPressed: () async {
                if (groupNameController.text.isEmpty ||
                    groupDescriptionController.text.isEmpty) {
                  DialogHelper().showCustomDialog(
                    title: "Error",
                    subtitle: "Please fill all fields.",
                  );
                  return;
                }
                try {
                  await FirestoreService().createGroupChat(
                    groupName: groupNameController.text,
                    groupDescription: groupDescriptionController.text,
                  );
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
}
