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
    selectedElement = element; // Select the newly created element
    elements.add(element);
    drawingMode = false; // Switch to selection mode after creating shape
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

  void resizeSelectedElement(Offset delta, ResizeHandle handle) {
    if (selectedElement == null) return;

    final rect = Rect.fromPoints(
      selectedElement!.position,
      selectedElement!.endPosition!,
    );
    Offset newStart = selectedElement!.position;
    Offset newEnd = selectedElement!.endPosition!;

    switch (handle) {
      case ResizeHandle.topLeft:
        newStart = Offset(rect.left + delta.dx, rect.top + delta.dy);
        break;
      case ResizeHandle.topRight:
        newStart = Offset(rect.left, rect.top + delta.dy);
        newEnd = Offset(rect.right + delta.dx, rect.bottom);
        break;
      case ResizeHandle.bottomLeft:
        newStart = Offset(rect.left + delta.dx, rect.top);
        newEnd = Offset(rect.right, rect.bottom + delta.dy);
        break;
      case ResizeHandle.bottomRight:
        newEnd = Offset(rect.right + delta.dx, rect.bottom + delta.dy);
        break;
      // Handle mid-point resizing
      case ResizeHandle.top:
        newStart = Offset(rect.left, rect.top + delta.dy);
        break;
      case ResizeHandle.bottom:
        newEnd = Offset(rect.right, rect.bottom + delta.dy);
        break;
      case ResizeHandle.left:
        newStart = Offset(rect.left + delta.dx, rect.top);
        break;
      case ResizeHandle.right:
        newEnd = Offset(rect.right + delta.dx, rect.bottom);
        break;
    }

    selectedElement!.position = newStart;
    selectedElement!.endPosition = newEnd;
    notifyListeners();
  }
}

enum ResizeHandle {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  top,
  bottom,
  left,
  right,
}
