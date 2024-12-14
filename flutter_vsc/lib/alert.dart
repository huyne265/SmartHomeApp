import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseAlertService {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  void listenForFireValue(BuildContext context) {
    databaseReference.child('Fire').onValue.listen((event) {
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
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "Warning",
              style: TextStyle(
                fontSize: 24,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Container(
            color: Colors.redAccent.withOpacity(0.2),
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "High temperature - Risk of explosion",
              style: TextStyle(
                fontSize: 18,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          backgroundColor: Colors.yellowAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        );
      },
    );
  }
}
