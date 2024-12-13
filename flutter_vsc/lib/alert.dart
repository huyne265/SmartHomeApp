import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseAlertService {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  void listenForFireValue(BuildContext context) {
    databaseReference.child('Fire/Value').onValue.listen((event) {
      final value = event.snapshot.value as int?;
      if (value == 1) {
        _showWarningDialog(context);
      }
    });
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            color: Colors.yellow,
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "Warning",
              style: TextStyle(
                fontSize: 24,
                color: Colors.red,
              ),
            ),
          ),
          content: Container(
            color: Colors.lightBlueAccent,
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "High temperature",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
