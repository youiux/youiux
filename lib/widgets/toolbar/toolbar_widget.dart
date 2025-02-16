import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/canvas_provider.dart';

class ToolbarWidget extends StatelessWidget {
  const ToolbarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Increased width for better visibility
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Drawing Mode Toggle
          Consumer<CanvasProvider>(
            builder: (context, canvasProvider, child) {
              return IconButton(
                icon: Icon(
                  canvasProvider.drawingMode ? Icons.mouse : Icons.edit,
                ),
                onPressed: () {
                  canvasProvider.setDrawingMode(!canvasProvider.drawingMode);
                  canvasProvider.selectShape(null);
                },
              );
            },
          ),
          // Shape Selection Dropdown
          Consumer<CanvasProvider>(
            builder: (context, canvasProvider, child) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<ShapeType>(
                  value: canvasProvider.selectedShape,
                  items:
                      ShapeType.values.map((ShapeType shape) {
                        return DropdownMenuItem<ShapeType>(
                          value: shape,
                          child: Text(shape.toString().split('.').last),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      canvasProvider.setSelectedShape(value);
                    }
                  },
                ),
              );
            },
          ),
          // Add more tools here (e.g., line, circle, freehand)
        ],
      ),
    );
  }
}
