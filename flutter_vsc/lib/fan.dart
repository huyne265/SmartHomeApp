import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FanControlUI extends StatefulWidget {
  const FanControlUI({Key? key}) : super(key: key);

  @override
  State<FanControlUI> createState() => _FanControlUIState();
}

class _FanControlUIState extends State<FanControlUI> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  String fanMode = "Manual"; // Default mode
  double fanSpeed = 100; // Default speed
  // bool isFanOn = true; // Default fan status (ON)
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchFanData(); // Fetch initial data from Firebase
    _focusNode.addListener(_handleFocusChange);
  }

  void _fetchFanData() async {
    // Get initial data from Firebase
    DataSnapshot modeSnapshot = await databaseRef.child('Fan/mode').get();
    DataSnapshot speedSnapshot = await databaseRef.child('Fan/speed').get();
    // DataSnapshot statusSnapshot = await databaseRef.child('Fan/status').get();

    setState(() {
      fanMode = modeSnapshot.value as String? ?? "Manual";
      fanSpeed = (speedSnapshot.value as num?)?.toDouble() ?? 100.0;
      // isFanOn = statusSnapshot.value as bool? ?? true;
    });
  }

  void _handleFocusChange() {
    setState(() {});
  }

  void _updateFanMode(String mode) {
    setState(() {
      fanMode = mode;
    });
    databaseRef.child('Fan/mode').set(mode);
  }

  void _updateFanSpeed(double speed) {
    setState(() {
      fanSpeed = speed;
    });
    databaseRef.child('Fan/speed').set(speed.toInt());
  }

  // void _toggleFanStatus() {
  //   setState(() {
  //     isFanOn = !isFanOn;
  //   });
  //   databaseRef.child('Fan/status').set(isFanOn);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fan Control',
          style: const TextStyle(
              color: Color(0xFF021024), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFFc1e8ff),
        iconTheme: const IconThemeData(
          color: Color(0xFF021024),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFFc1e8ff),
            Color(0xFF7da0ca),
            Color(0xFF5483b3),
            Color(0xFF2b669c),
            Color(0xFF052659),
            Color(0xFF021024),
          ],
        )),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Fan Status (ON/OFF)
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       isFanOn ? "Fan ON" : "Fan OFF",
              //       style: const TextStyle(
              //         color: Color(0xFFc1e8ff),
              //         fontWeight: FontWeight.bold,
              //         fontSize: 18,
              //       ),
              //     ),
              //     const SizedBox(height: 20),
              //     Switch(
              //       value: isFanOn,
              //       onChanged: (value) => _toggleFanStatus(),
              //       activeColor: Color(0xFFc1e8ff),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 20),

              // Fan Mode Selection
              const Text(
                'Fan Mode',
                style: TextStyle(
                  color: Color(0xFFc1e8ff),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              ToggleButtons(
                isSelected: [fanMode == "Auto", fanMode == "Manual"],
                onPressed: (index) {
                  _updateFanMode(index == 0 ? "Auto" : "Manual");
                },
                borderRadius: BorderRadius.circular(20),
                selectedColor: Color(0xFFc1e8ff),
                fillColor: Color(0xFFc1e8ff),
                borderColor: Color(0xFFc1e8ff),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      "Automatic",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: fanMode == "Auto"
                            ? Color(0xFF021024)
                            : Color(0xFFc1e8ff),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      "Manual",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: fanMode == "Manual"
                            ? Color(0xFF021024)
                            : Color(0xFFc1e8ff),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Fan Speed
              const Text(
                'Fan Speed',
                style: TextStyle(
                  color: Color(0xFFc1e8ff),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        valueIndicatorTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF021024)),
                      ),
                      child: Slider(
                        value: fanSpeed,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: fanSpeed.toStringAsFixed(0),
                        onChanged: fanMode == "Manual"
                            ? (value) => _updateFanSpeed(value)
                            : null,
                        activeColor:
                            fanMode == "Manual" ? Color(0xFFc1e8ff) : null,
                        inactiveColor:
                            fanMode == "Manual" ? Color(0xFF052659) : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      focusNode: _focusNode,
                      enabled: fanMode == "Manual",
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: const BorderSide(
                            color: Color(0xFF052659),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFc1e8ff),
                            width: 2.0,
                          ),
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(
                        color: Color(0xFFc1e8ff),
                        fontWeight: FontWeight.bold,
                      ),
                      onSubmitted: (value) {
                        double? newValue = double.tryParse(value);
                        if (newValue != null &&
                            newValue >= 0 &&
                            newValue <= 100) {
                          _updateFanSpeed(newValue);
                        }
                      },
                      controller: TextEditingController(
                        text: fanSpeed.toStringAsFixed(0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
