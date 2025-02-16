import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/canvas_provider.dart';
import '../../models/design_element.dart';

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({Key? key}) : super(key: key);

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> {
  Offset? startPosition;
  Offset? currentPosition;
  bool isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, canvasProvider, child) {
        return MouseRegion(
          cursor: _getCursor(canvasProvider),
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.1,
            maxScale: 4.0,
            child: GestureDetector(
              onPanStart: (details) {
                if (canvasProvider.drawingMode) {
                  // Drawing mode
                  setState(() {
                    startPosition = details.localPosition;
                    currentPosition = details.localPosition;
                  });
                  canvasProvider.setDrawing(true);
                } else {
                  // Selection/dragging mode
                  bool hitElement = false;
                  for (var element in canvasProvider.elements) {
                    if (isPointInsideElement(details.localPosition, element)) {
                      canvasProvider.selectElement(element);
                      setState(() {
                        isDragging = true;
                        startPosition = details.localPosition;
                      });
                      hitElement = true;
                      break;
                    }
                  }
                  if (!hitElement) {
                    canvasProvider.selectElement(null);
                  }
                }
              },
              onPanUpdate: (details) {
                if (canvasProvider.drawing) {
                  // Drawing mode
                  setState(() {
                    currentPosition = details.localPosition;
                  });
                } else if (isDragging && startPosition != null) {
                  // Dragging mode
                  final delta = details.localPosition - startPosition!;
                  canvasProvider.moveSelectedElement(delta);
                  setState(() {
                    startPosition = details.localPosition;
                  });
                }
              },
              onPanEnd: (details) {
                if (canvasProvider.drawing) {
                  // Finish drawing
                  if (startPosition != null && currentPosition != null) {
                    canvasProvider.addElement(
                      DesignElement(
                        position: startPosition!,
                        endPosition: currentPosition!,
                        shapeType: canvasProvider.selectedShape,
                      ),
                    );
                  }
                }
                // Reset states
                setState(() {
                  isDragging = false;
                  startPosition = null;
                  currentPosition = null;
                });
                canvasProvider.setDrawing(false);
              },
              onTapDown: (details) {
                bool elementTapped = false;
                for (var element in canvasProvider.elements) {
                  if ((details.localPosition.dx - element.position.dx).abs() <
                          element.width / 2 &&
                      (details.localPosition.dy - element.position.dy).abs() <
                          element.height / 2) {
                    canvasProvider.selectElement(element);
                    elementTapped = true;
                    break;
                  }
                }
                if (!elementTapped) {
                  canvasProvider.selectElement(null);
                }
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color:
                    Colors
                        .grey[200], // Ensure canvas background is always drawn
                child: CustomPaint(
                  size: Size.infinite,
                  painter: CanvasPainter(
                    elements: canvasProvider.elements,
                    startPosition: startPosition,
                    currentPosition: currentPosition,
                    selectedElement: canvasProvider.selectedElement,
                    selectedShape: canvasProvider.selectedShape,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  MouseCursor _getCursor(CanvasProvider provider) {
    if (provider.drawingMode) {
      return SystemMouseCursors.precise;
    } else if (provider.selectedElement != null || isDragging) {
      return SystemMouseCursors.move;
    }
    return SystemMouseCursors.basic;
  }

  bool isPointInsideElement(Offset point, DesignElement element) {
    if (element.endPosition == null) return false;

    Rect elementRect = Rect.fromPoints(element.position, element.endPosition!);
    return elementRect.contains(point);
  }
}

class CanvasPainter extends CustomPainter {
  final List<DesignElement> elements;
  final Offset? startPosition;
  final Offset? currentPosition;
  final DesignElement? selectedElement;
  final ShapeType? selectedShape;

  CanvasPainter({
    required this.elements,
    this.startPosition,
    this.currentPosition,
    this.selectedElement,
    this.selectedShape,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw existing elements
    for (var element in elements) {
      _drawElement(canvas, element, element == selectedElement);
    }

    // Draw current drawing shape
    if (startPosition != null && currentPosition != null) {
      final paint =
          Paint()
            ..color = Colors.blue.withOpacity(0.5)
            ..style = PaintingStyle.fill;

      _drawPreviewShape(
        canvas,
        startPosition!,
        currentPosition!,
        selectedShape,
        paint,
      );
    }
  }

  void _drawElement(Canvas canvas, DesignElement element, bool isSelected) {
    final paint =
        Paint()
          ..color = element.color
          ..style = PaintingStyle.fill;

    Rect boundingBox;

    switch (element.shapeType) {
      case ShapeType.rectangle:
        boundingBox = Rect.fromPoints(element.position, element.endPosition!);
        canvas.drawRect(boundingBox, paint);
        break;
      case ShapeType.circle:
        Offset center = element.position;
        double radius = (element.endPosition! - element.position).distance / 2;
        boundingBox = Rect.fromCircle(center: center, radius: radius);
        canvas.drawCircle(center, radius, paint);
        break;
      default:
        return;
    }

    if (isSelected) {
      _drawResizeHandles(canvas, boundingBox);
    }
  }

  void _drawResizeHandles(Canvas canvas, Rect boundingBox) {
    final handlePaint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

    // Draw corner handles
    final handles = [
      boundingBox.topLeft,
      boundingBox.topRight,
      boundingBox.bottomLeft,
      boundingBox.bottomRight,

      // Mid-point handles
      Offset(boundingBox.left + boundingBox.width / 2, boundingBox.top),
      Offset(boundingBox.left + boundingBox.width / 2, boundingBox.bottom),
      Offset(boundingBox.left, boundingBox.top + boundingBox.height / 2),
      Offset(boundingBox.right, boundingBox.top + boundingBox.height / 2),
    ];

    for (var handle in handles) {
      canvas.drawCircle(handle, 5, handlePaint);
    }

    // Draw selection outline
    final outlinePaint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    canvas.drawRect(boundingBox, outlinePaint);
  }

  void _drawPreviewShape(
    Canvas canvas,
    Offset start,
    Offset end,
    ShapeType? type,
    Paint paint,
  ) {
    switch (type) {
      case ShapeType.rectangle:
        canvas.drawRect(Rect.fromPoints(start, end), paint);
        break;
      case ShapeType.circle:
        Offset center = start;
        double radius = (end - start).distance / 2;
        canvas.drawCircle(center, radius, paint);
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return oldDelegate.elements != elements ||
        oldDelegate.startPosition != startPosition ||
        oldDelegate.currentPosition != currentPosition ||
        oldDelegate.selectedElement != selectedElement;
  }
}
