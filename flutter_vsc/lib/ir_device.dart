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
        title: const Text(
          "IR Device",
          style: const TextStyle(
              color: Color(0xFF021024), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFc1e8ff),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFc1e8ff),
              Color(0xFF7da0ca),
              Color(0xFF5483b3),
              Color(0xFF2b669c),
              Color(0xFF052659),
              Color(0xFF021024),
            ],
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF2b669c),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 4),
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
          color: isActive ? Color(0xFF021024) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? Color(0xFF021024) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? const Color(0xFF7da0ca)
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
              color:
                  isActive ? const Color(0xFFc1e8ff) : const Color(0xFF021024),
            ),
          ),
        ),
      ),
    );
  }
}
