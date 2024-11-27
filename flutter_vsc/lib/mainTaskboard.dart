import 'package:flutter/material.dart';
import 'circleProgress.dart';

class MainTaskboard extends StatelessWidget {
  final bool isLoading;
  final double tempValue;
  final double humidityValue;
  final double airLevelValue;
  final double lightLevelValue;

  const MainTaskboard({
    Key? key,
    required this.isLoading,
    required this.tempValue,
    required this.humidityValue,
    required this.airLevelValue,
    required this.lightLevelValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Left: Temperature && Air Level
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    CustomPaint(
                      foregroundPainter: CircleProgress(tempValue, "temp"),
                      child: Container(
                        width: 150,
                        height: 150,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text('Temperature'),
                              Text(
                                '${tempValue.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                '°C',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    CustomPaint(
                      foregroundPainter:
                          CircleProgress(airLevelValue, "air", maxValue: 5000),
                      child: Container(
                        width: 150,
                        height: 150,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text('Air Level'),
                              Text(
                                '${airLevelValue.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                'AQI',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
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
                      foregroundPainter: CircleProgress(humidityValue, "humid"),
                      child: Container(
                        width: 150,
                        height: 150,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text('Humidity'),
                              Text(
                                '${humidityValue.toInt()}',
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                '%',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    CustomPaint(
                      foregroundPainter:
                          CircleProgress(lightLevelValue, "light"),
                      child: Container(
                        width: 150,
                        height: 150,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text('Light Level'),
                              Text(
                                '${lightLevelValue.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                'lux',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
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
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
    );
  }
}
