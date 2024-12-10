import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'ir_device.dart';
import 'fan.dart';

class Device {
  final String name;
  String? mode;
  String? timer;
  final Function onTap;

  Device({
    required this.name,
    this.mode,
    this.timer,
    required this.onTap,
  });
}

class DeviceControllerScreen extends StatelessWidget {
  const DeviceControllerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Device> devices = [
      Device(
        name: "Fan",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FanControlUI()),
          );
        },
      ),
      Device(
        name: "IR Device",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const IRDeviceUI()),
          );
        },
      ),
    ];

    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return GestureDetector(
            onTap: () => device.onTap(),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (device.name == "Fan") _buildFanStatus(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFanStatus() {
    final DatabaseReference databaseRef =
        FirebaseDatabase.instance.ref().child('Fan');
    return StreamBuilder(
      stream: databaseRef.onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error loading data');
        } else if (snapshot.data?.snapshot.value == null) {
          return const Text('No data available');
        } else {
          final fanData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final String mode = fanData['mode'] ?? 'Unknown';
          final double speed = (fanData['speed'] as num?)?.toDouble() ?? 0.0;
          return Column(
            children: [
              Text('Mode: $mode'),
              Text('Speed: $speed'),
            ],
          );
        }
      },
    );
  }
}
