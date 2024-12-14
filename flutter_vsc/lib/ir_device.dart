import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class IRDeviceUI extends StatefulWidget {
  const IRDeviceUI({super.key});

  @override
  _IRDeviceUIState createState() => _IRDeviceUIState();
}

class _IRDeviceUIState extends State<IRDeviceUI> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  Map buttonStates = {};

  final Map<String, int> buttonToFirebaseValue = {
    '1': 69,
    '2': 70,
    '3': 71,
    '4': 68,
    '5': 64,
    '6': 67,
    '7': 7,
    '8': 21,
    '9': 9,
    '0': 25,
    '*': 22,
    '#': 13,
    '▲': 24,
    '◄': 8,
    'OK': 28,
    '►': 90,
    '▼': 82,
  };

  void _sendSignal(String buttonValue) {
    int? firebaseValue = buttonToFirebaseValue[buttonValue];
    if (firebaseValue == null) return;
    setState(() {
      buttonStates[buttonValue] = true;
    });
    databaseRef.child('ir_device/key').set(firebaseValue);
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        buttonStates[buttonValue] = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IR Device"),
        backgroundColor: const Color.fromARGB(253, 255, 248, 248),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueAccent,
              Colors.lightBlue,
              Color(0xFF2575FC),
            ],
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildButtonGrid(context),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth < 400 ? 40.0 : 60.0;

    List<List<String>> buttonRows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', '#'],
      ['▲'],
      ['◄', 'OK', '►'],
      ['▼']
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: buttonRows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row
                .map((buttonValue) => _buildButton(buttonValue, buttonSize))
                .toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(String buttonValue, double buttonSize) {
    bool isActive = buttonStates[buttonValue] == true;
    return GestureDetector(
      onTap: () => _sendSignal(buttonValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: buttonSize,
        height: buttonSize,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isActive ? Color(0xFF4A90E2) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? Color(0xFF2C7BD9) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? Color(0xFF4A90E2).withOpacity(0.4)
                  : Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            buttonValue,
            style: TextStyle(
              fontSize: buttonSize * 0.4,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
