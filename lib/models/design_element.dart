import 'package:flutter/material.dart';

class DesignElement {
  Offset position;
  double width;
  double height;
  Color color;

  DesignElement({
    required this.position,
    this.width = 50,
    this.height = 50,
    this.color = Colors.red,
  });
}
