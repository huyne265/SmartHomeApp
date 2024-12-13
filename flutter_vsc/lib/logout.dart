import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'alert.dart';
import 'main.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final bool shouldLogout = await _showLogoutPopup(context);
          if (shouldLogout) {
            await _handleSignOut(context);
          }
        },
        child: const Text('Log Out'),
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
              title: const Text("Log out"),
              content: const Text("Do you want to log out now?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Yes"),
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
