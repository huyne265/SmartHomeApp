import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

import 'button.dart';
import 'mainTaskboard.dart';
import 'logout.dart';
import 'themeSwitch.dart';
import 'relay_schedule.dart';
import 'ir_device.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  final databaseReference = FirebaseDatabase.instance.ref();

  late AnimationController progressController;
  late Animation<double> tempAnimation = const AlwaysStoppedAnimation(0.0);
  late Animation<double> humidityAnimation = const AlwaysStoppedAnimation(0.0);
  late Animation<double> airlevelAnimation = const AlwaysStoppedAnimation(0.0);
  late Animation<double> lightlevelAnimation =
      const AlwaysStoppedAnimation(0.0);

  bool isDarkMode = false;

  List<Map<String, dynamic>> schedules = [];

  DateTime currentDateTime = DateTime.now();
  late Timer _timer;

  @override
  void dispose() {
    progressController.dispose();

    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    databaseReference.child('Home').once().then((DatabaseEvent event) {
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        double temp = data['homeTemperature'] ?? 0.0;
        double humidity = data['homeHumidity'] ?? 0.0;
        double airlevel = data['homeAirlevel'] ?? 0.0;
        double lightlevel = data['homeLightlevel'] ?? 0.0;

        setState(() {
          isLoading = true;
          _dashboardinit(temp, humidity, airlevel, lightlevel);
        });
        Future.delayed(const Duration(seconds: 3), () {
          _startRealtimeUpdates();
        });
      }
    });

    currentDateTime = DateTime.now();

    // Cập nhật thời gian mỗi giây
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        currentDateTime = DateTime.now();
      });
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
    databaseReference.child('Home').onValue.listen((DatabaseEvent event) {
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        double temp = data['homeTemperature'] ?? 0.0;
        double humidity = data['homeHumidity'] ?? 0.0;
        double airlevel = data['homeAirlevel'] ?? 0.0;
        double lightlevel = data['homeLightlevel'] ?? 0.0;

        setState(() {
          _dashboardUpdate(temp, humidity, airlevel, lightlevel);
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

  IconData getCurrentIcon() {
    int hour = currentDateTime.hour;
    if (hour >= 6 && hour < 18) {
      return Icons.wb_sunny; // Mặt trời
    } else {
      return Icons.nights_stay; // Mặt trăng
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkMode
          ? ThemeData.dark().copyWith(
              primaryColor: Colors.black,
              scaffoldBackgroundColor: Colors.black,
            )
          : ThemeData.light().copyWith(
              primaryColor: Colors.white,
              scaffoldBackgroundColor: Colors.white,
            ),
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 0, 204, 255),
            title: const Text('Smart Room App'),
            actions: [
              ThemeSwitcher(
                onThemeChanged: (isDark) {
                  setState(() {
                    isDarkMode = isDark;
                  });
                },
              ),
            ],
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
                    IRDeviceUI(),
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
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, dd/MM/yyyy')
                                .format(currentDateTime),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        DateFormat('HH:mm:ss').format(currentDateTime),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          bottomNavigationBar: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: "Home"),
              Tab(
                  icon: Icon(Icons.radio_button_checked),
                  text: "Button Taskboard"),
              Tab(
                icon: Icon(Icons.wb_iridescent_rounded),
                text: "IR Device",
              ),
              Tab(icon: Icon(Icons.schedule), text: "Schedule"),
              Tab(icon: Icon(Icons.logout), text: "Log out"),
            ],
            labelColor: Color.fromARGB(255, 93, 223, 255),
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.blue,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
