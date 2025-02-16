import 'package:flutter/material.dart';
import '../providers/canvas_provider.dart';

class DesignElement {
  Offset position;
  Offset? endPosition;
  double width;
  double height;
  Color color;
  ShapeType? shapeType;

  DesignElement({
    required this.position,
    this.endPosition,
    this.width = 50,
    this.height = 50,
    this.color = Colors.red,
    this.shapeType,
  });
}
