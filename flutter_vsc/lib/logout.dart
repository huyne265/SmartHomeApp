import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'alert.dart';
import 'main.dart';
import 'subSched.dart';

class LogoutTab extends StatefulWidget {
  final Function onSignOut;

  const LogoutTab({super.key, required this.onSignOut});

  @override
  _LogoutTabState createState() => _LogoutTabState();
}

class _LogoutTabState extends State<LogoutTab> {
  final FirebaseAlertService _firebaseAlertService = FirebaseAlertService();

  @override
  void initState() {
    super.initState();
    _firebaseAlertService.listenForFireValue(context);
    RelayScheduleService().loadSchedulesFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFc1e8ff),
            Color(0xFF7da0ca),
            Color(0xFF5483b3),
            Color(0xFF2b669c),
            Color(0xFF052659),
            Color(0xFF021024),
          ],
        ),
      ),
      child: Center(
        child: ElevatedButton(
          onPressed: () async {
            final bool shouldLogout = await _showLogoutPopup(context);
            if (shouldLogout) {
              await _handleSignOut(context);
            }
          },
          child: const Text(
            'Log Out',
            style: TextStyle(
                color: Color(0xFF021024), fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      widget.onSignOut(); // Gọi callback để xử lý thêm (nếu cần)

      // Điều hướng về màn hình chính và xóa các màn hình trước đó
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyApp()),
        (route) => false,
      );
    } catch (e) {
      _showErrorDialog(context, 'Error logging out', e.toString());
    }
  }

  Future<bool> _showLogoutPopup(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                "Log out",
                style: TextStyle(
                  color: Color(0xFF021024),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text("Do you want to log out now?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    "No",
                    style: TextStyle(
                      color: Color(0xFF021024),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    "Yes",
                    style: TextStyle(
                      color: Color(0xFF021024),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Trường hợp người dùng không chọn bất kỳ hành động nào
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
