import 'package:flutter/material.dart';
import '../../models/design_element.dart';

enum ShapeType { rectangle, circle }

class CanvasProvider extends ChangeNotifier {
  List<DesignElement> elements = [];
  DesignElement? selectedElement;
  ShapeType selectedShape = ShapeType.rectangle; // Set default shape
  bool drawing = false;
  bool drawingMode = true;

  void addElement(DesignElement element) {
    selectedElement = null; // Clear selection when adding a new element
    elements.add(element);
    notifyListeners();
  }

  void selectElement(DesignElement? element) {
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
    // Remove nullable type
    selectedShape = shape;
    notifyListeners();
  }

  void setDrawing(bool value) {
    drawing = value;
    notifyListeners();
  }

  void setDrawingMode(bool value) {
    drawingMode = value;
    notifyListeners();
  }

  void moveSelectedElement(Offset delta) {
    if (selectedElement != null) {
      selectedElement!.position = Offset(
        selectedElement!.position.dx + delta.dx,
        selectedElement!.position.dy + delta.dy,
      );
      selectedElement!.endPosition = Offset(
        selectedElement!.endPosition!.dx + delta.dx,
        selectedElement!.endPosition!.dy + delta.dy,
      );
      notifyListeners();
    }
  }

  void selectShape(Object? object) {
    if (object is ShapeType) {
      selectedShape = object;
      notifyListeners();
    }
  }
}
