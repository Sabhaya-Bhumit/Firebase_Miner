import 'package:authors_app/views/screens/add_book.dart';
import 'package:authors_app/views/screens/detail_page.dart';
import 'package:authors_app/views/screens/edite_book.dart';
import 'package:authors_app/views/screens/favorite.dart';
import 'package:authors_app/views/screens/home.dart';
import 'package:authors_app/views/screens/splesh_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
        'splesh_screen': (context) => splesh_screen(),
        'add_book': (context) => add_book(),
        'favorite': (context) => favorite(),
        'detail_page': (context) => detail_page(),
        'edite_book': (context) => edite_book(),
      },
    ),
  );
}
