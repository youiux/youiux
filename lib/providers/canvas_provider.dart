import 'package:flutter/material.dart';
import '../../models/design_element.dart';

enum ShapeType { rectangle, circle }

class CanvasProvider extends ChangeNotifier {
  List<DesignElement> elements = [];
  DesignElement? selectedElement;
  ShapeType selectedShape = ShapeType.rectangle;
  bool isDrawing = false;
  bool isEditMode = false;

  void addElement(DesignElement element) {
    elements.add(element);
    selectedElement = element;
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
    selectedShape = shape;
    notifyListeners();
  }

  void setDrawing(bool value) {
    isDrawing = value;
    notifyListeners();
  }

  void setDrawingMode(bool value) {
    isEditMode = value;
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

  void deleteElement(DesignElement element) {
    elements.remove(element);
    if (selectedElement == element) {
      selectedElement = null;
    }
    notifyListeners();
  }

  void duplicateElement(DesignElement element) {
    final newElement = DesignElement(
      position: Offset(element.position.dx + 20, element.position.dy + 20),
      endPosition: Offset(
        element.endPosition!.dx + 20,
        element.endPosition!.dy + 20,
      ),
      width: element.width,
      height: element.height,
      color: element.color,
      shapeType: element.shapeType,
    );
    elements.add(newElement);
    selectedElement = newElement;
    notifyListeners();
  }

  void bringToFront(DesignElement element) {
    elements.remove(element);
    elements.add(element);
    notifyListeners();
  }

  void sendToBack(DesignElement element) {
    elements.remove(element);
    elements.insert(0, element);
    notifyListeners();
  }

  void paste(Offset position) {
    if (selectedElement != null) {
      duplicateElement(selectedElement!);
    }
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
