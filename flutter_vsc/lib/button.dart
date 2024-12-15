import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'alert.dart';
import 'subSched.dart';

class RelayControlPage extends StatefulWidget {
  const RelayControlPage({super.key});

  @override
  _RelayControlPageState createState() => _RelayControlPageState();
}

class _RelayControlPageState extends State<RelayControlPage> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseAlertService _firebaseAlertService = FirebaseAlertService();

  bool relay1 = false;
  bool relay2 = false;
  bool relay3 = false;
  bool relay4 = false;

  bool isManualMode = false;
  double lightValue = 0.0;

  @override
  void initState() {
    super.initState();
    _firebaseAlertService.listenForFireValue(context);

    RelayScheduleService().loadSchedulesFromFirebase();
    databaseReference.child('Home/homeLightlevel').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        double newLightValue = double.tryParse(data.toString()) ?? 0.0;
        _updateLightValue(newLightValue);
      }
    });

    databaseReference.child('Relay').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        bool newRelay1 = data['Relay1'] == 1;
        bool newRelay2 = data['Relay2'] == 1;
        bool newRelay3 = data['Relay3'] == 1;
        bool newRelay4 = data['Relay4'] == 1;
        setState(() {
          relay1 = newRelay1;
          relay2 = newRelay2;
          relay3 = newRelay3;
          relay4 = newRelay4;
        });
      }
    });

    _updateModeInFirebase();
  }

  void _updateModeInFirebase() {
    databaseReference.child('Relay/Mode').set(isManualMode ? 'Manual' : 'Auto');
  }

  void _updateLightValue(double newLightValue) {
    setState(() {
      lightValue = newLightValue;
    });

    if (!isManualMode) {
      //Relay1 - light
      if (lightValue < 6 && !relay1) {
        setState(() {
          relay1 = true;
        });
        _toggleRelay('Relay1', true);
      } else if (lightValue > 90 && relay1) {
        setState(() {
          relay1 = false;
        });
        _toggleRelay('Relay1', false);
      }
    }
  }

  void _toggleRelay(String relayKey, bool status) {
    if (isManualMode) {
      databaseReference.child('Relay').update({
        relayKey: status ? 1 : 0,
      });
    }
  }

  Widget _buildRelayCard(String name, bool status, VoidCallback onPressed) {
    return GestureDetector(
      onTap: isManualMode ? onPressed : null,
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: status
                ? [
                    const Color.fromARGB(255, 98, 248, 105),
                    const Color.fromARGB(255, 98, 248, 105)
                  ]
                : [Colors.redAccent.shade200, Colors.redAccent.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(4, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                status ? Icons.power : Icons.power_off,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                status ? "$name: ON" : "$name: OFF",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF7da0ca),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(4, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.settings, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      isManualMode ? 'Mode: Manual' : 'Mode: Automatic',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Switch(
                      value: isManualMode,
                      onChanged: (bool value) {
                        setState(() {
                          isManualMode = value;
                          _updateModeInFirebase();
                        });
                      },
                      activeColor: const Color(0xFF2b669c),
                      inactiveThumbColor: const Color(0xFF5483b3),
                      inactiveTrackColor: const Color(0xFF7da0ca),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildRelayCard("Relay 1", relay1, () {
                      _toggleRelay('Relay1', !relay1);
                    }),
                    _buildRelayCard("Relay 2", relay2, () {
                      _toggleRelay('Relay2', !relay2);
                    }),
                    _buildRelayCard("Relay 3", relay3, () {
                      _toggleRelay('Relay3', !relay3);
                    }),
                    _buildRelayCard("Relay 4", relay4, () {
                      _toggleRelay('Relay4', !relay4);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
