import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initializeFirebase() async {
    if (kIsWeb) {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyAIMkx2XnNrD4Fy0TWyFNAi_pKKqwHMDUg",
              authDomain: "smartroomapp-1cad3.firebaseapp.com",
              projectId: "smartroomapp-1cad3",
              databaseURL:
                  "https://smartroomapp-1cad3-default-rtdb.asia-southeast1.firebasedatabase.app/",
              storageBucket: "smartroomapp-1cad3.firebasestorage.app",
              messagingSenderId: "252924529231",
              appId: "1:252924529231:web:cdcf21fcb30500189ff83a",
              measurementId: "G-CXPLKEMKQ3"));
    } else {
      await Firebase.initializeApp();
    }
  }
}
