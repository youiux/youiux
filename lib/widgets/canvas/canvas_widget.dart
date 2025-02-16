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
  DesignElement? selectedElement;

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, canvasProvider, child) {
        return MouseRegion(
          cursor:
              canvasProvider.drawingMode
                  ? SystemMouseCursors.precise
                  : SystemMouseCursors.basic,
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.1,
            maxScale: 4.0,
            child: GestureDetector(
              onPanStart: (details) {
                if (canvasProvider.drawingMode) {
                  setState(() {
                    startPosition = details.localPosition;
                    currentPosition = details.localPosition;
                  });
                  canvasProvider.setDrawing(true);
                }
              },
              onPanUpdate: (details) {
                if (canvasProvider.drawing) {
                  setState(() {
                    currentPosition = details.localPosition;
                  });
                }
              },
              onPanEnd: (details) {
                if (canvasProvider.drawing &&
                    canvasProvider.selectedShape != null &&
                    startPosition != null &&
                    currentPosition != null) {
                  canvasProvider.addElement(
                    DesignElement(
                      position: startPosition!,
                      endPosition: currentPosition!,
                      shapeType: canvasProvider.selectedShape,
                    ),
                  );
                  canvasProvider.setDrawing(false);
                  setState(() {
                    startPosition = null;
                    currentPosition = null;
                  });
                } else {
                  setState(() {
                    startPosition = null;
                  });
                }
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
      final paint =
          Paint()
            ..color = element.color
            ..style = PaintingStyle.fill;

      switch (element.shapeType) {
        case ShapeType.rectangle:
          canvas.drawRect(
            Rect.fromPoints(element.position, element.endPosition!),
            paint,
          );
          break;
        case ShapeType.circle:
          Offset center = element.position;
          double radius =
              (element.endPosition! - element.position).distance / 2;
          canvas.drawCircle(center, radius, paint);
          break;
        default:
          break;
      }
    }

    // Draw current drawing shape
    if (startPosition != null && currentPosition != null) {
      final paint =
          Paint()
            ..color = Colors.blue.withOpacity(0.5)
            ..style = PaintingStyle.fill;

      switch (selectedShape) {
        case ShapeType.rectangle:
          canvas.drawRect(
            Rect.fromPoints(startPosition!, currentPosition!),
            paint,
          );
          break;
        case ShapeType.circle:
          Offset center = startPosition!;
          double radius = (currentPosition! - startPosition!).distance / 2;
          canvas.drawCircle(center, radius, paint);
          break;
        default:
          break;
      }
    }

    // Draw selection outline
    if (selectedElement != null) {
      final paint =
          Paint()
            ..color = Colors.blue
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;

      Rect rect;
      switch (selectedElement!.shapeType) {
        case ShapeType.rectangle:
          rect = Rect.fromPoints(
            selectedElement!.position,
            selectedElement!.endPosition!,
          );
          break;
        case ShapeType.circle:
          Offset center = selectedElement!.position;
          double radius =
              (selectedElement!.endPosition! - selectedElement!.position)
                  .distance /
              2;
          rect = Rect.fromCircle(center: center, radius: radius);
          break;
        default:
          return;
      }

      canvas.drawRect(rect, paint);
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
