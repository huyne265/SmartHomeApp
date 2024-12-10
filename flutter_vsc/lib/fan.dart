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
  bool isFanOn = true; // Default fan status (ON)

  @override
  void initState() {
    super.initState();
    _fetchFanData(); // Fetch initial data from Firebase
  }

  void _fetchFanData() async {
    // Get initial data from Firebase
    DataSnapshot modeSnapshot = await databaseRef.child('Fan/mode').get();
    DataSnapshot speedSnapshot = await databaseRef.child('Fan/speed').get();
    DataSnapshot statusSnapshot = await databaseRef.child('Fan/status').get();

    setState(() {
      fanMode = modeSnapshot.value as String? ?? "Manual";
      fanSpeed = (speedSnapshot.value as num?)?.toDouble() ?? 100.0;
      isFanOn = statusSnapshot.value as bool? ?? true;
    });
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

  void _toggleFanStatus() {
    setState(() {
      isFanOn = !isFanOn;
    });
    databaseRef.child('Fan/status').set(isFanOn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fan Control'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Fan Status (ON/OFF)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fan Status:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: isFanOn,
                  onChanged: (value) => _toggleFanStatus(),
                  activeColor: Colors.blueAccent,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fan Mode Selection
            const Text(
              'Fan Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ToggleButtons(
              isSelected: [fanMode == "Automatic", fanMode == "Manual"],
              onPressed: (index) {
                _updateFanMode(index == 0 ? "Automatic" : "Manual");
              },
              borderRadius: BorderRadius.circular(20),
              selectedColor: Colors.white,
              fillColor: Colors.blueAccent,
              borderColor: Colors.blueAccent,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("Automatic", style: TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("Manual", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Fan Speed
            const Text(
              'Fan Speed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Speed Slider + Number Input
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Slider(
                    value: fanSpeed,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: fanSpeed.toStringAsFixed(0),
                    onChanged: fanMode == "Manual"
                        ? (value) => _updateFanSpeed(value)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 60,
                  child: TextField(
                    enabled: fanMode == "Manual",
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
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
    );
  }
}
