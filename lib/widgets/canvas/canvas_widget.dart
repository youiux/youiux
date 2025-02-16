import 'package:flutter/gestures.dart';
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
  Offset? menuPosition;
  DesignElement? hoveredElement;

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, canvasProvider, child) {
        return MouseRegion(
          onHover: (event) {
            setState(() {
              hoveredElement = _findElementAt(
                event.localPosition,
                canvasProvider.elements,
              );
            });
          },
          onExit: (_) {
            setState(() {
              hoveredElement = null;
            });
          },
          cursor: _getCursor(),
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                startPosition = details.localPosition;
                currentPosition = details.localPosition;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                currentPosition = details.localPosition;
              });
            },
            onPanEnd: (details) {
              if (startPosition != null && currentPosition != null) {
                canvasProvider.addElement(
                  DesignElement(
                    position: startPosition!,
                    endPosition: currentPosition!,
                    shapeType: canvasProvider.selectedShape,
                  ),
                );
                setState(() {
                  startPosition = null;
                  currentPosition = null;
                });
              }
            },
            onSecondaryTapDown: (details) {
              _showContextMenu(context, details.globalPosition, canvasProvider);
            },
            child: SizedBox(
              width: 800,
              height: 600,
              child: CustomPaint(
                painter: CanvasPainter(
                  elements: canvasProvider.elements,
                  startPosition: startPosition,
                  currentPosition: currentPosition,
                  selectedElement: canvasProvider.selectedElement,
                  selectedShape: canvasProvider.selectedShape,
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[200],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showContextMenu(
    BuildContext context,
    Offset position,
    CanvasProvider provider,
  ) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect positionRect = RelativeRect.fromRect(
      Rect.fromPoints(position, position),
      Offset.zero & overlay.size,
    );

    // Show menu on next frame to ensure browser context menu is fully prevented
    Future.microtask(() {
      showMenu(
        context: context,
        position: positionRect,
        items: [
          if (provider.selectedElement != null) ...[
            PopupMenuItem(
              child: const Text('Delete'),
              onTap: () => provider.deleteElement(provider.selectedElement!),
            ),
            PopupMenuItem(
              child: const Text('Duplicate'),
              onTap: () => provider.duplicateElement(provider.selectedElement!),
            ),
            PopupMenuItem(
              child: const Text('Bring to Front'),
              onTap: () => provider.bringToFront(provider.selectedElement!),
            ),
            PopupMenuItem(
              child: const Text('Send to Back'),
              onTap: () => provider.sendToBack(provider.selectedElement!),
            ),
          ],
          PopupMenuItem(
            child: const Text('Paste'),
            onTap: () => provider.paste(menuPosition!),
          ),
        ],
      );
    });
  }

  DesignElement? _findElementAt(Offset position, List<DesignElement> elements) {
    for (var element in elements.reversed) {
      if (isPointInsideElement(position, element)) {
        return element;
      }
    }
    return null;
  }

  MouseCursor _getCursor() {
    if (isDragging) return SystemMouseCursors.move;
    if (hoveredElement != null) return SystemMouseCursors.click;
    return SystemMouseCursors.basic;
  }

  bool isPointInsideElement(Offset point, DesignElement element) {
    if (element.endPosition == null) return false;

    if (element.shapeType == ShapeType.rectangle) {
      final rect = Rect.fromPoints(element.position, element.endPosition!);
      return rect.contains(point);
    } else if (element.shapeType == ShapeType.circle) {
      final center = element.position;
      final radius = (element.endPosition! - element.position).distance / 2;
      return (point - center).distance <= radius;
    }
    return false;
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

      if (element.shapeType == ShapeType.rectangle) {
        // Ensure that the rectangle is drawn with correct points
        final rect = Rect.fromPoints(element.position, element.endPosition!);
        canvas.drawRect(rect, paint);
      } else if (element.shapeType == ShapeType.circle) {
        // Ensure that the circle is drawn with correct center and radius
        final center = element.position;
        final radius = (element.endPosition! - element.position).distance / 2;
        canvas.drawCircle(center, radius, paint);
      }
    }

    // Draw current shape being drawn
    if (startPosition != null && currentPosition != null) {
      final paint =
          Paint()
            ..color = Colors.blue.withOpacity(0.5)
            ..style = PaintingStyle.fill;

      if (selectedShape == ShapeType.rectangle) {
        // Ensure that the rectangle is drawn with correct points
        final rect = Rect.fromPoints(startPosition!, currentPosition!);
        canvas.drawRect(rect, paint);
      } else if (selectedShape == ShapeType.circle) {
        // Ensure that the circle is drawn with correct center and radius
        final center = startPosition!;
        final radius = (currentPosition! - startPosition!).distance / 2;
        canvas.drawCircle(center, radius, paint);
      }
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
