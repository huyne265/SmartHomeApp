import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initializeFirebase() async {
    if (kIsWeb) {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyDq552RtmjLM8ok1NhIKufMbw3_c73sppk",
              authDomain: "test-9c8d6.firebaseapp.com",
              databaseURL:
                  "https://test-9c8d6-default-rtdb.asia-southeast1.firebasedatabase.app",
              projectId: "test-9c8d6",
              storageBucket: "test-9c8d6.firebasestorage.app",
              messagingSenderId: "94062739323",
              appId: "1:94062739323:web:f6bd9a93c9b5ba190f07de"));
    } else {
      await Firebase.initializeApp();
    }
  }
}
