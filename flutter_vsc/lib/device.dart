import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'alert.dart';
import 'ir_device.dart';
import 'fan.dart';
import 'subSched.dart';

class Device {
  final String name;
  IconData? icon;
  final Color backgroundColor;
  String? mode;
  String? timer;
  final Function onTap;

  Device({
    required this.name,
    this.icon,
    required this.backgroundColor,
    this.mode,
    this.timer,
    required this.onTap,
  });
}

class DeviceControllerScreen extends StatefulWidget {
  const DeviceControllerScreen({Key? key}) : super(key: key);
  @override
  _DeviceControllerScreen createState() => _DeviceControllerScreen();
}

class _DeviceControllerScreen extends State<DeviceControllerScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAlertService _firebaseAlertService = FirebaseAlertService();

  @override
  void initState() {
    super.initState();
    _firebaseAlertService.listenForFireValue(context);
    RelayScheduleService().loadSchedulesFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    final List<Device> devices = [
      Device(
        name: "Fan",
        icon: Icons.air_outlined,
        backgroundColor: Colors.blue.shade100,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FanControlUI()),
          );
        },
      ),
      Device(
        name: "IR Device",
        icon: Icons.tv,
        backgroundColor: Colors.green.shade100,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const IRDeviceUI()),
          );
        },
      ),
      Device(
        name: "Device 3",
        icon: Icons.fireplace_outlined,
        backgroundColor: Colors.red.shade100,
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => DangerAlert()),
          // );
        },
      ),
      Device(
        name: "Device 4",
        icon: Icons.device_thermostat,
        backgroundColor: Colors.yellow.shade100,
        onTap: () {
          // Device 4
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Controller',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF021024))),
        backgroundColor: Color(0xFFc1e8ff),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // Color(0xFFc1e8ff),
              Color(0xFF7da0ca),
              Color(0xFF5483b3),
              Color(0xFF2b669c),
              Color(0xFF052659),
              Color(0xFF021024),
            ],
          ),
        ),
        // color: Colors.white,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return _buildDeviceCard(device);
          },
        ),
      ),
    );
  }

  Widget _buildDeviceCard(Device device) {
    return GestureDetector(
      onTap: () => device.onTap(),
      child: Container(
        decoration: BoxDecoration(
          color: device.backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                device.icon,
                size: 50,
                color: const Color(0xFF021024),
              ),
              const SizedBox(height: 8),
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
  }

  Widget _buildFanStatus() {
    final DatabaseReference databaseRef =
        FirebaseDatabase.instance.ref().child('Fan');
    return StreamBuilder(
      stream: databaseRef.onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue));
        } else if (snapshot.hasError) {
          return const Text('Error loading data',
              style: TextStyle(color: Colors.red));
        } else if (snapshot.data?.snapshot.value == null) {
          return const Text('No data');
        } else {
          final fanData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final String mode = fanData['mode'] ?? 'Unknown';
          final double speed = (fanData['speed'] as num?)?.toDouble() ?? 0.0;
          return Column(
            children: [
              Text('Mode: $mode',
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              Text('Speed: $speed',
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          );
        }
      },
    );
  }
}
