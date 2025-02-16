import 'package:flutter/material.dart';

class CanvasProvider extends ChangeNotifier {
  List<Offset> elements = [];

  void addElement(Offset position) {
    elements.add(position);
    notifyListeners();
  }
}
