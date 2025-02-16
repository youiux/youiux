import 'package:flutter/material.dart';
import '../../models/design_element.dart';

class CanvasProvider extends ChangeNotifier {
  List<DesignElement> elements = [];
  DesignElement? selectedElement;

  void addElement(DesignElement element) {
    elements.add(element);
    notifyListeners();
  }

  void selectElement(DesignElement element) {
    selectedElement = element;
    notifyListeners();
  }

  void updateSelectedElement({double? width, double? height}) {
    if (selectedElement != null) {
      if (width != null) {
        selectedElement!.width = width;
      }
      if (height != null) {
        selectedElement!.height = height;
      }
      notifyListeners();
    }
  }
}
