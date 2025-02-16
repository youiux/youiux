import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/canvas_provider.dart';
import '../../models/design_element.dart';

class CanvasWidget extends StatelessWidget {
  const CanvasWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, canvasProvider, child) {
        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.1,
          maxScale: 4.0,
          child: Listener(
            onPointerDown: (event) {
              // Check if we're near an existing element
              bool elementTapped = false;
              for (var element in canvasProvider.elements) {
                if ((event.localPosition.dx - element.position.dx).abs() <
                        element.width / 2 &&
                    (event.localPosition.dy - element.position.dy).abs() <
                        element.height / 2) {
                  canvasProvider.selectElement(element);
                  elementTapped = true;
                  break;
                }
              }

              // If no element was tapped, add a new one
              if (!elementTapped) {
                canvasProvider.addElement(
                  DesignElement(
                    position: event.localPosition,
                    shapeType: canvasProvider.selectedShape,
                  ),
                );
              }
            },
            child: CustomPaint(
              painter: CanvasPainter(canvasProvider.elements),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey[200],
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

  CanvasPainter(this.elements);

  @override
  void paint(Canvas canvas, Size size) {
    for (var element in elements) {
      final paint =
          Paint()
            ..color = element.color
            ..style = PaintingStyle.fill;

      // Draw different shapes based on the shapeType
      // Draw different shapes based on the shapeType
      switch (element.shapeType) {
        case ShapeType.rectangle:
          canvas.drawRect(
            Rect.fromLTWH(
              element.position.dx,
              element.position.dy,
              element.width,
              element.height,
            ),
            paint,
          );
          break;
        case ShapeType.circle:
          canvas.drawCircle(
            Offset(
              element.position.dx + element.width / 2,
              element.position.dy + element.height / 2,
            ),
            element.width / 2,
            paint,
          );
          break;
        // Add more shapes here (e.g., line, triangle)
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
