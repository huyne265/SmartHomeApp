import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'circleProgress.dart';
import 'main.dart';

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
  late Animation<double> tempAnimation;
  late Animation<double> humidityAnimation;
  late Animation<double> airlevelAnimation;
  late Animation<double> lightlevelAnimation;

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
          _DashboardInit(temp, humidity, airlevel, lightlevel);
        });
      } else {
        print("No data available");
      }
    });
  }

  _DashboardInit(double temp, double humid, double air, double light) {
    progressController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 5000)); //5s

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

  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Dashboard'),
  //       centerTitle: true,
  //       automaticallyImplyLeading: false,
  //       leading: IconButton(
  //           icon: const Icon(Icons.reorder), onPressed: handleLoginOutPopup),
  //     ),
  //     body: Center(
  //         child: isLoading
  //             ? Column(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: <Widget>[
  //                   CustomPaint(
  //                     foregroundPainter:
  //                         CircleProgress(tempAnimation.value, true),
  //                     child: Container(
  //                       width: 200,
  //                       height: 200,
  //                       child: Center(
  //                         child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: <Widget>[
  //                             const Text('Temperature'),
  //                             Text(
  //                               '${tempAnimation.value.toInt()}',
  //                               style: const TextStyle(
  //                                   fontSize: 50, fontWeight: FontWeight.bold),
  //                             ),
  //                             const Text(
  //                               '°C',
  //                               style: TextStyle(
  //                                   fontSize: 20, fontWeight: FontWeight.bold),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   CustomPaint(
  //                     foregroundPainter:
  //                         CircleProgress(humidityAnimation.value, false),
  //                     child: Container(
  //                       width: 200,
  //                       height: 200,
  //                       child: Center(
  //                         child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: <Widget>[
  //                             const Text('Humidity'),
  //                             Text(
  //                               '${humidityAnimation.value.toInt()}',
  //                               style: const TextStyle(
  //                                   fontSize: 50, fontWeight: FontWeight.bold),
  //                             ),
  //                             const Text(
  //                               '%',
  //                               style: TextStyle(
  //                                   fontSize: 20, fontWeight: FontWeight.bold),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               )
  //             : const Text(
  //                 'Loading...',
  //                 style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
  //               )),
  //   );
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.reorder),
          onPressed: handleLoginOutPopup,
        ),
      ),
      body: Center(
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Left: Temperature && Air Level
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CustomPaint(
                        foregroundPainter:
                            CircleProgress(tempAnimation.value, "temp"),
                        child: Container(
                          width: 150,
                          height: 150,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text('Temperature'),
                                Text(
                                  '${tempAnimation.value.toStringAsFixed(1)}',
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
                            airlevelAnimation.value, "air",
                            maxValue: 5000),
                        child: Container(
                          width: 150,
                          height: 150,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text('Air Level'),
                                Text(
                                  '${airlevelAnimation.value.toStringAsFixed(1)}',
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
                        foregroundPainter:
                            CircleProgress(humidityAnimation.value, "humid"),
                        child: Container(
                          width: 150,
                          height: 150,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text('Humidity'),
                                Text(
                                  '${humidityAnimation.value.toInt()}',
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
                        foregroundPainter:
                            CircleProgress(lightlevelAnimation.value, "light"),
                        child: Container(
                          width: 150,
                          height: 150,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text('Light Level'),
                                Text(
                                  '${lightlevelAnimation.value.toInt()}',
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
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  handleLoginOutPopup() {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Login Out",
      desc: "Do you want to login out now?",
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.teal,
          child: const Text(
            "No",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: handleSignOut,
          color: Colors.teal,
          child: const Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }
}
