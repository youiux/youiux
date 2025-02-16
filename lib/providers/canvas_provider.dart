import 'package:flutter/material.dart';
import '../../models/design_element.dart';

enum ShapeType { rectangle, circle }

class CanvasProvider extends ChangeNotifier {
  List<DesignElement> elements = [];
  DesignElement? selectedElement;
  ShapeType selectedShape = ShapeType.rectangle;

  void addElement(DesignElement element) {
    selectedElement = null; // Clear selection when adding a new element
    elements.add(element);
    notifyListeners();
  }

  void selectElement(DesignElement element) {
    selectedElement = element;
    notifyListeners();
  }

  void updateSelectedElement({double? width, double? height, Color? color}) {
    if (selectedElement != null) {
      if (width != null) {
        selectedElement!.width = width;
      }
      if (height != null) {
        selectedElement!.height = height;
      }
      if (color != null) {
        selectedElement!.color = color;
      }
      notifyListeners();
    }
  }

  void setSelectedShape(ShapeType shape) {
    selectedShape = shape;
    notifyListeners();
  }
}
