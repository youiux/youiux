import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/canvas_provider.dart';

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
              canvasProvider.addElement(details.localPosition);
            },
            child: Container(
              color: Colors.grey[200],
              child: Stack(
                children: [
                  for (var element in canvasProvider.elements)
                    Positioned(
                      left: element.dx,
                      top: element.dy,
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
