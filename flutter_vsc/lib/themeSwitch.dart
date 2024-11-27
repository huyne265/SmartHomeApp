import 'package:flutter/material.dart';

class ThemeSwitcher extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged; // Callback để gửi trạng thái theme
  const ThemeSwitcher({Key? key, required this.onThemeChanged})
      : super(key: key);

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
        color: isDarkMode ? Colors.yellow : Colors.black,
      ),
      onPressed: () {
        setState(() {
          isDarkMode = !isDarkMode;
        });
        widget.onThemeChanged(isDarkMode); // Gọi callback để cập nhật theme
      },
    );
  }
}
