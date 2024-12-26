import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'alert.dart';
import 'circleProgress.dart';
// import 'dart:async';

import 'clock.dart';
import 'subSched.dart';

class MainTaskboard extends StatefulWidget {
  final bool isLoading;
  final double tempValue;
  final double humidityValue;
  final double airLevelValue;
  final double lightLevelValue;

  const MainTaskboard({
    super.key,
    required this.isLoading,
    required this.tempValue,
    required this.humidityValue,
    required this.airLevelValue,
    required this.lightLevelValue,
  });

  @override
  _MainTaskboardState createState() => _MainTaskboardState();
}

class _MainTaskboardState extends State<MainTaskboard> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseAlertService _firebaseAlertService = FirebaseAlertService();
  bool isDataLoading = true;
  @override
  void initState() {
    super.initState();
    _firebaseAlertService.listenForFireValue(context);
    RelayScheduleService().loadSchedulesFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    bool isDayTime = DateTime.now().hour >= 6 && DateTime.now().hour <= 18;
    return Column(
      children: [
        // Date and Time Bar
        Container(
          padding: const EdgeInsets.all(10.0),
          color: isDayTime
              ? const Color.fromARGB(255, 172, 238, 255)
              : const Color.fromARGB(255, 190, 200, 204),
          child: const ClockWidget(),
        ),
        Expanded(
          child: Container(
            color: const Color.fromARGB(255, 255, 255, 255),
            child: Center(
              child: widget.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Left: Temperature && Air Level
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            CustomPaint(
                              foregroundPainter:
                                  CircleProgress(widget.tempValue, "temp"),
                              child: Container(
                                width: 150,
                                height: 150,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Text('Temperature'),
                                      Text(
                                        widget.tempValue.toStringAsFixed(2),
                                        style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        '°C',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            CustomPaint(
                              foregroundPainter: CircleProgress(
                                  widget.airLevelValue, "air",
                                  maxValue: 2000),
                              child: Container(
                                width: 150,
                                height: 150,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Text('Air Level'),
                                      Text(
                                        widget.airLevelValue.toStringAsFixed(2),
                                        style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        'AQI',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Right: Humidity && Light Level
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            CustomPaint(
                              foregroundPainter: CircleProgress(
                                  widget.humidityValue, "humid",
                                  maxValue: 200),
                              child: Container(
                                width: 150,
                                height: 150,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Text('Humidity'),
                                      Text(
                                        '${widget.humidityValue.toInt()}',
                                        style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        '%',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            CustomPaint(
                              foregroundPainter: CircleProgress(
                                  widget.lightLevelValue, "light",
                                  maxValue: 5000),
                              child: Container(
                                width: 150,
                                height: 150,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Text('Light Level'),
                                      Text(
                                        widget.lightLevelValue
                                            .toStringAsFixed(2),
                                        style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        'lux',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : const Text(
                      'Loading...',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
