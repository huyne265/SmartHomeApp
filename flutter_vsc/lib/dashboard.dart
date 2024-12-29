import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'button.dart';
import 'device.dart';
import 'mainTaskboard.dart';
import 'logout.dart';
import 'relay_schedule.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  // final GoogleSignIn googleSignIn = GoogleSignIn();

  final databaseReference = FirebaseDatabase.instance.ref();

  late AnimationController progressController;
  late Animation<double> tempAnimation = const AlwaysStoppedAnimation(0.0);
  late Animation<double> humidityAnimation = const AlwaysStoppedAnimation(0.0);
  late Animation<double> airlevelAnimation = const AlwaysStoppedAnimation(0.0);
  late Animation<double> lightlevelAnimation =
      const AlwaysStoppedAnimation(0.0);

  List<Map<String, dynamic>> schedules = [];

  @override
  void dispose() {
    progressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    databaseReference.child('Home').once().then((DatabaseEvent event) {
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        double temp =
            double.tryParse(data['homeTemperature'].toString()) ?? 0.0;
        double humidity =
            double.tryParse(data['homeHumidity'].toString()) ?? 0.0;
        double airlevel =
            double.tryParse(data['homeAirlevel'].toString()) ?? 0.0;
        double lightlevel =
            double.tryParse(data['homeLightlevel'].toString()) ?? 0.0;

        setState(() {
          isLoading = true;
          _dashboardinit(temp, humidity, airlevel, lightlevel);
        });
        _startRealtimeUpdates();
        // Future.delayed(const Duration(seconds: 1), () {
        //   _startRealtimeUpdates();
        // });
      }
    });
  }

  _dashboardinit(double temp, double humid, double air, double light) {
    progressController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000)); //3s

    tempAnimation =
        Tween<double>(begin: 0, end: temp).animate(progressController)
          ..addListener(() {
            setState(() {});
          });

    humidityAnimation =
        Tween<double>(begin: 0, end: humid).animate(progressController)
          ..addListener(() {
            setState(() {});
          });

    airlevelAnimation =
        Tween<double>(begin: 0, end: air).animate(progressController)
          ..addListener(() {
            setState(() {});
          });

    lightlevelAnimation =
        Tween<double>(begin: 0, end: light).animate(progressController)
          ..addListener(() {
            setState(() {});
          });

    progressController.forward();
  }

  void _startRealtimeUpdates() {
    databaseReference.child('Home').once().then((DatabaseEvent event) {
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        // await Future.delayed(const Duration(seconds: 1));
        final data = snapshot.value as Map<dynamic, dynamic>;

        double temp =
            double.tryParse(data['homeTemperature']?.toString() ?? '') ?? 0.0;
        // await Future.delayed(const Duration(milliseconds: 10));
        double humidity =
            double.tryParse(data['homeHumidity']?.toString() ?? '') ?? 0.0;
        // await Future.delayed(const Duration(milliseconds: 10));
        double airlevel =
            double.tryParse(data['homeAirlevel']?.toString() ?? '') ?? 0.0;
        // await Future.delayed(const Duration(milliseconds: 10));
        double lightlevel =
            double.tryParse(data['homeLightlevel']?.toString() ?? '') ?? 0.0;
        // await Future.delayed(const Duration(milliseconds: 10));

        setState(() {
          isLoading = true;
          _dashboardUpdate(temp, humidity, airlevel, lightlevel);
        });
        Future.delayed(const Duration(seconds: 3), () {
          _startRealtimeUpdates();
        });
      }
    });
  }

  _dashboardUpdate(double temp, double humid, double air, double light) {
    tempAnimation = Tween<double>(begin: tempAnimation.value, end: temp)
        .animate(progressController)
      ..addListener(() {
        setState(() {});
      });

    humidityAnimation =
        Tween<double>(begin: humidityAnimation.value, end: humid)
            .animate(progressController)
          ..addListener(() {
            setState(() {});
          });

    airlevelAnimation = Tween<double>(begin: airlevelAnimation.value, end: air)
        .animate(progressController)
      ..addListener(() {
        setState(() {});
      });

    lightlevelAnimation =
        Tween<double>(begin: lightlevelAnimation.value, end: light)
            .animate(progressController)
          ..addListener(() {
            setState(() {});
          });

    progressController.forward(from: 0); // Chạy lại animation từ đầu
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF021024),
            title: const Text(
              'Smart Room App',
              style: TextStyle(
                  color: Color(0xFFc1e8ff), fontWeight: FontWeight.bold),
            ),
          ),
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 251, 251),
                ),
                child: TabBarView(
                  children: <Widget>[
                    MainTaskboard(
                      isLoading: true,
                      tempValue: tempAnimation.value,
                      humidityValue: humidityAnimation.value,
                      airLevelValue: airlevelAnimation.value,
                      lightLevelValue: lightlevelAnimation.value,
                    ),
                    const RelayControlPage(),
                    const DeviceControllerScreen(),
                    ScheduleApp(schedules: schedules),
                    LogoutTab(
                      onSignOut: () {
                        setState(() {
                          isLoading = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: const Material(
            color: Color(0xFF021024),
            child: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home), text: "Home"),
                Tab(icon: Icon(Icons.radio_button_checked), text: "Button"),
                Tab(
                  icon: Icon(Icons.wb_iridescent_rounded),
                  text: "Device",
                ),
                Tab(icon: Icon(Icons.schedule), text: "Scheduler"),
                Tab(icon: Icon(Icons.logout), text: "Log out"),
              ],
              labelColor: Color(0xFFc1e8ff),
              unselectedLabelColor: Color(0xFF7da0ca),
              indicatorColor: Color(0xFFc1e8ff),
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
