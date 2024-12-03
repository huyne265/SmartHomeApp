// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';

// import 'circleProgress.dart';
// import 'main.dart';
import 'button.dart';
import 'mainTaskboard.dart';
import 'logout.dart';
import 'themeSwitch.dart';
import 'relay_schedule.dart';

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
  late Animation<double> tempAnimation = AlwaysStoppedAnimation(0.0);
  late Animation<double> humidityAnimation = AlwaysStoppedAnimation(0.0);
  late Animation<double> airlevelAnimation = AlwaysStoppedAnimation(0.0);
  late Animation<double> lightlevelAnimation = AlwaysStoppedAnimation(0.0);

  bool isDarkMode = false;

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

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: isDarkMode
//           ? ThemeData.dark().copyWith(
//               primaryColor: Colors.black,
//               scaffoldBackgroundColor: Colors.black,
//             )
//           : ThemeData.light().copyWith(
//               primaryColor: Colors.white,
//               scaffoldBackgroundColor: Colors.white,
//             ),
//       debugShowCheckedModeBanner: false,
//       home: DefaultTabController(
//         length: 4,
//         child: Scaffold(
//           appBar: AppBar(
//             backgroundColor: const Color.fromARGB(255, 0, 204, 255),
//             title: const Text('ESP32 Temperature & Humidity App'),
//             actions: [
//               // Theme switch
//               ThemeSwitcher(
//                 onThemeChanged: (isDark) {
//                   setState(() {
//                     isDarkMode = isDark;
//                   });
//                 },
//               ),
//             ],
//           ),
//           body: Column(
//             children: <Widget>[
//               ButtonsTabBar(
//                 radius: 12,
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                 center: true,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: <Color>[
//                       Color.fromARGB(255, 0, 204, 255),
//                       Color.fromARGB(255, 61, 216, 255),
//                       Color.fromARGB(255, 126, 229, 255),
//                     ],
//                   ),
//                 ),
//                 unselectedLabelStyle: const TextStyle(color: Colors.black),
//                 labelStyle: const TextStyle(color: Colors.white),
//                 height: 56,
//                 tabs: const [
//                   Tab(icon: Icon(Icons.home), text: "Main Taskboard"),
//                   Tab(
//                       icon: Icon(Icons.radio_button_checked_rounded),
//                       text: "Button Taskboard"),
//                   Tab(icon: Icon(Icons.schedule), text: "Schedule"),
//                   Tab(icon: Icon(Icons.logout_outlined), text: "Log out"),
//                 ],
//               ),
//               Expanded(
//                 child: TabBarView(
//                   children: <Widget>[
//                     // Tab 1: Main Taskboard
//                     MainTaskboard(
//                       // isLoading: isLoading,
//                       isLoading: true,
//                       tempValue: tempAnimation.value,
//                       humidityValue: humidityAnimation.value,
//                       airLevelValue: airlevelAnimation.value,
//                       lightLevelValue: lightlevelAnimation.value,
//                     ),
//                     // Tab 2: Button Taskboard
//                     const RelayControlPage(),
//                     //Tab3: schedule
//                     ScheduleApp(schedules: schedules),
//                     // Tab 3: Logout
//                     LogoutTab(
//                       onSignOut: () {
//                         setState(() {
//                           isLoading = false;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 0, 204, 255),
            title: const Text('ESP32 Temperature & Humidity App'),
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
          body: TabBarView(
            children: <Widget>[
              MainTaskboard(
                isLoading: true,
                tempValue: tempAnimation.value,
                humidityValue: humidityAnimation.value,
                airLevelValue: airlevelAnimation.value,
                lightLevelValue: lightlevelAnimation.value,
              ),
              const RelayControlPage(),
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
          bottomNavigationBar: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: "Main Taskboard"),
              Tab(
                  icon: Icon(Icons.radio_button_checked),
                  text: "Button Taskboard"),
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
