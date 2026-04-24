import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/start_screen.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

// Import the firebase_options.dart file if you've generated it
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print("Starting Firebase initialization");

    if (kIsWeb) {
      // Web-specific initialization
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDPOet4Z8Rth5LUoNJN1FulpG8jP09qX7c",
          authDomain: "autolibreply-2d34d.firebaseapp.com",
          projectId: "autolibreply-2d34d",
          storageBucket:
              "autolibreply-2d34d.appspot.com", // Fixed storage bucket URL
          messagingSenderId: "631828263933",
          appId: "1:631828263933:web:b7826bb28615fed940df94",
          measurementId: "G-7P8M18HTG4",
        ),
      );
    } else {
      // Android, iOS, macOS, etc.
      // Option 1: Use default configuration
      await Firebase.initializeApp();

      // Option 2: Use the firebase_options.dart file (recommended)
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
    }

    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization error: $e");
    // Handle the error appropriately - maybe show a dialog or a banner
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Lib Reply',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const StartPage(),
    );
  }
}
