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
          child: Listener(
            onPointerDown: (event) {
              // Handle right click
              if (event.kind == PointerDeviceKind.mouse &&
                  event.buttons == kSecondaryMouseButton) {
                _showContextMenu(context, event.position, canvasProvider);
              }
            },
            child: Stack(
              children: [
                InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.1,
                  maxScale: 4.0,
                  child: GestureDetector(
                    onPanStart: _handlePanStart,
                    onPanUpdate: _handlePanUpdate,
                    onPanEnd: _handlePanEnd,
                    child: CustomPaint(
                      painter: CanvasPainter(
                        elements: canvasProvider.elements,
                        startPosition: startPosition,
                        currentPosition: currentPosition,
                        selectedElement: canvasProvider.selectedElement,
                        hoveredElement: hoveredElement,
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
              ],
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

  void _handlePanStart(DragStartDetails details) {
    final canvasProvider = Provider.of<CanvasProvider>(context, listen: false);
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
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final canvasProvider = Provider.of<CanvasProvider>(context, listen: false);
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
  }

  void _handlePanEnd(DragEndDetails details) {
    final canvasProvider = Provider.of<CanvasProvider>(context, listen: false);
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
  final DesignElement? hoveredElement;
  final ShapeType? selectedShape;

  CanvasPainter({
    required this.elements,
    this.startPosition,
    this.currentPosition,
    this.selectedElement,
    this.hoveredElement,
    this.selectedShape,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw existing elements
    for (var element in elements) {
      final isSelected = element == selectedElement;
      final isHovered = element == hoveredElement;
      _drawElement(canvas, element, isSelected, isHovered);
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

  void _drawElement(
    Canvas canvas,
    DesignElement element,
    bool isSelected,
    bool isHovered,
  ) {
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

    if (isSelected || isHovered) {
      final outlinePaint =
          Paint()
            ..color = isSelected ? Colors.blue : Colors.grey
            ..strokeWidth = isSelected ? 2 : 1
            ..style = PaintingStyle.stroke;

      canvas.drawRect(boundingBox, outlinePaint);

      if (isSelected) {
        _drawResizeHandles(canvas, boundingBox);
      }
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
