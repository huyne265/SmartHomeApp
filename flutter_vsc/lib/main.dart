import 'package:flutter/material.dart';
import 'firebase_config.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initializeFirebase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 204, 255)),
        useMaterial3: true,
      ),
      home: const LoginScreen(title: 'Smart Room App'),
      debugShowCheckedModeBanner: false,
    );
  }
}


// {
//   "rules": {
//     ".read": "now < 1736355600000",  // 2025-1-9
//     ".write": "now < 1736355600000",  // 2025-1-9
//   }
// }