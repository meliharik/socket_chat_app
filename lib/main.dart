import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socket_chat_app/controllers/socket_controller.dart';
import 'package:socket_chat_app/firebase_options.dart';
import 'package:socket_chat_app/redirect.dart';
import 'package:socket_chat_app/services/remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  //disable landscape mode
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  try {
    await FirebaseRemoteConfigService().initialize();
    debugPrint('FirebaseRemoteConfigService initialized');
  } catch (e) {
    debugPrint('FirebaseRemoteConfigService error: $e');
  }

  runApp(const MyApp());
}

class GlobalcontextService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => SocketController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: GlobalcontextService.navigatorKey,
        home: const RedirectPage(),
        theme: ThemeData.dark(),
      ),
    );
  }
}
