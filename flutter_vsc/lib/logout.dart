import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';

import 'main.dart';

class LogoutTab extends StatelessWidget {
  final Function onSignOut;

  const LogoutTab({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final bool result = await showLogoutPopup(context);
          if (result) {
            await handleSignOut(context);
            onSignOut();
          }
        },
        child: const Text('Log Out'),
      ),
    );
  }

  Future<void> handleSignOut(BuildContext context) async {
    // Đăng xuất khỏi Firebase và Google
    await FirebaseAuth.instance.signOut();
    // await GoogleSignIn().signOut();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MyApp()),
      (Route<dynamic> route) => false,
    );
  }

  Future<bool> showLogoutPopup(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Log out"),
              content: const Text("Do you want to log out now?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Yes"),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
