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
          child: GestureDetector(
            onTapDown: (details) {
              canvasProvider.addElement(
                DesignElement(position: details.localPosition),
              );
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

      canvas.drawRect(
        Rect.fromLTWH(
          element.position.dx,
          element.position.dy,
          element.width,
          element.height,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
