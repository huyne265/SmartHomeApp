import 'dart:math';

import 'package:flutter/material.dart';

class CircleProgress extends CustomPainter {
  double value;
  int maxValue;
  String type;

  CircleProgress(this.value, this.type, {this.maxValue = 100});

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    int maximumValue;
    Paint arcPaint;

    if (type == "temp") {
      maximumValue = maxValue;
      arcPaint = Paint()
        ..strokeWidth = 16
        ..color = (value < maxValue * 0.8)
            ? const Color.fromARGB(255, 61, 253, 93)
            : (const Color.fromARGB(255, 255, 17, 0))
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
    } else if (type == "humid") {
      maximumValue = maxValue;
      arcPaint = Paint()
        ..strokeWidth = 16
        ..color = (value < maxValue * 0.8)
            ? Colors.blueAccent
            : const Color.fromARGB(255, 255, 17, 0)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
    } else if (type == "air") {
      maximumValue = maxValue;
      arcPaint = Paint()
        ..strokeWidth = 16
        ..color = (value < maxValue * 0.8)
            ? const Color.fromARGB(255, 255, 0, 85)
            : const Color.fromARGB(255, 255, 17, 0)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
    } else if (type == "light") {
      maximumValue = maxValue;
      arcPaint = Paint()
        ..strokeWidth = 16
        ..color = (value < maxValue * 0.8)
            ? const Color.fromARGB(255, 255, 255, 57)
            : const Color.fromARGB(255, 255, 17, 0)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
    } else {
      maximumValue = maxValue;
      arcPaint = Paint()
        ..strokeWidth = 16
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
    }

    // Vẽ vòng tròn ngoài
    Paint outerCircle = Paint()
      ..strokeWidth = 16
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - 5;
    canvas.drawCircle(center, radius, outerCircle);

    // Tính toán góc dựa trên giá trị hiện tại và giá trị tối đa
    double angle = 2 * pi * (value / maximumValue);

    // Vẽ vòng tròn tiến độ
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      angle,
      false,
      arcPaint,
    );
  }
}
