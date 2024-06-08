// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:socket_chat_app/helpers/space.dart';
import 'package:socket_chat_app/main.dart';
import 'package:socket_chat_app/models/firestore_user.dart';
import 'package:socket_chat_app/screens/settings/about_us.dart';
import 'package:socket_chat_app/screens/settings/how_app_works.dart';
import 'package:socket_chat_app/screens/settings/privacy.dart';
import 'package:socket_chat_app/screens/settings/qa.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String version = '';
  String buildNumber = '';

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber',
              isEqualTo: FirebaseAuth.instance.currentUser!.phoneNumber)
          .snapshots(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          FirestoreUser user =
              FirestoreUser.fromFirestore(snapshot.data.docs[0]);

          return CupertinoPageScaffold(
            backgroundColor: Colors.black,
            child: CustomScrollView(
              slivers: [
                navBar(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      imgAndNameContainer(context, user),
                      SpaceHelper.height(context, 0.02),
                      privacySection(context, user),
                      SpaceHelper.height(context, 0.02),
                      aboutUsSection(context),
                      SpaceHelper.height(context, 0.02),
                      // help
                      q_aSection(context),
                      SpaceHelper.height(context, 0.02),
                      versionText(
                          GlobalcontextService.navigatorKey.currentContext!),
                      SpaceHelper.height(context, 0.2),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Text(
            'Something went wrong',
            style: GoogleFonts.poppins(
              color: CupertinoColors.white,
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
        return const Center(
          child: CupertinoActivityIndicator(),
        );
      },
    );
  }

  Widget versionText(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Column(
        children: [
          Text(
            'Securely',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Version $version ($buildNumber)',
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: MediaQuery.of(context).size.width * 0.035,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Padding q_aSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            onLongPress: () async {
              await storage.deleteAll();

              await FirebaseAuth.instance.signOut();

              // Navigator.pushAndRemoveUntil(
              //   context,
              //   CupertinoPageRoute(
              //     builder: (context) => const EnterNumberPage(),
              //   ),
              //   (route) => false,
              // );
            },
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const QAScreen(),
                ),
              );
            },
            trailing: Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.white.withOpacity(0.5),
              size: MediaQuery.of(context).size.width / 20,
            ),
            isThreeLine: false,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                CupertinoIcons.question_circle,
                color: CupertinoColors.white,
                size: MediaQuery.of(context).size.width / 20,
              ),
            ),
            title: Text(
              'Q/A',
              style: GoogleFonts.poppins(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w400,
                fontSize: MediaQuery.of(context).size.width / 25,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding aboutUsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const AboutUsScreen(),
                ),
              );
            },
            trailing: Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.white.withOpacity(0.5),
              size: MediaQuery.of(context).size.width / 20,
            ),
            isThreeLine: false,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                CupertinoIcons.person,
                color: CupertinoColors.white,
                size: MediaQuery.of(context).size.width / 20,
              ),
            ),
            title: Text(
              'About Us',
              style: GoogleFonts.poppins(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w400,
                fontSize: MediaQuery.of(context).size.width / 25,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding privacySection(BuildContext context, FirestoreUser user) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => PrivacyScreen(
                        user: user,
                      ),
                    ),
                  );
                },
                trailing: Icon(
                  CupertinoIcons.chevron_right,
                  color: CupertinoColors.white.withOpacity(0.5),
                  size: MediaQuery.of(context).size.width / 20,
                ),
                isThreeLine: false,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    CupertinoIcons.lock,
                    color: CupertinoColors.white,
                    size: MediaQuery.of(context).size.width / 20,
                  ),
                ),
                title: Text(
                  'Privacy',
                  style: GoogleFonts.poppins(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: MediaQuery.of(context).size.width / 25,
                  ),
                ),
              ),
            ),
            Divider(
              endIndent: MediaQuery.of(context).size.width / 10,
              indent: MediaQuery.of(context).size.width / 10,
              color: Colors.grey[900],
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    GlobalcontextService.navigatorKey.currentContext!,
                    CupertinoPageRoute(
                      builder: (context) => HowAppWorksScren(),
                    ),
                  );
                },
                minVerticalPadding: 0.0,
                trailing: Icon(
                  CupertinoIcons.chevron_right,
                  color: CupertinoColors.white.withOpacity(0.5),
                  size: MediaQuery.of(context).size.width / 20,
                ),
                isThreeLine: false,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    CupertinoIcons.app_badge,
                    color: CupertinoColors.white,
                    size: MediaQuery.of(context).size.width / 20,
                  ),
                ),
                title: Text(
                  'How does Securely work?',
                  style: GoogleFonts.poppins(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: MediaQuery.of(context).size.width / 25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding imgAndNameContainer(BuildContext context, FirestoreUser user) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   CupertinoPageRoute(
          //     builder: (context) => EditProfileScreen(
          //       user: user,
          //     ),
          //   ),
          // );
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              isThreeLine: false,
              leading: CircleAvatar(
                radius: MediaQuery.of(context).size.width / 15,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    user.photoURL,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.width / 2,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        color: Colors.black,
                      );
                    },
                  ),
                ),
              ),
              title: Text(
                user.phoneNumber,
                style: GoogleFonts.poppins(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.description.length > 30
                    ? '${user.description.substring(0, 26)}...'
                    : user.description,
                style: GoogleFonts.poppins(
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  CupertinoSliverNavigationBar navBar() {
    return CupertinoSliverNavigationBar(
      // bottom border grey
      border: Border(
        bottom: BorderSide(
          color: Colors.black,
          width: 0.0,
        ),
      ),
      backgroundColor: Colors.black,
      largeTitle: Text(
        "Settings",
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
