import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_miner/views/screens/favorite.dart';
import 'package:firebase_miner/views/screens/home.dart';
import 'package:firebase_miner/views/screens/splesh_screen.dart';
import 'package:flutter/material.dart';

// import 'firebase_options.dart';
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(primary: Colors.black, secondary: Colors.black)),
      debugShowCheckedModeBanner: false,
      initialRoute: 'splesh_screen',
      routes: {
        '/': (context) => home(),
        'favorite_page': (context) => favorite(),
        'splesh_screen': (context) => splesh_screen(),
      },
    ),
  );
}
