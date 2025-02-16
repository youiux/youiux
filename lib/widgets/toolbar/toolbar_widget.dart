import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/canvas_provider.dart';

class ToolbarWidget extends StatelessWidget {
  const ToolbarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Consumer<CanvasProvider>(
            builder: (context, canvasProvider, child) {
              return Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.rectangle_outlined),
                    onPressed:
                        () => canvasProvider.setSelectedShape(
                          ShapeType.rectangle,
                        ),
                    color:
                        canvasProvider.selectedShape == ShapeType.rectangle
                            ? Theme.of(context).primaryColor
                            : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.circle_outlined),
                    onPressed:
                        () => canvasProvider.setSelectedShape(ShapeType.circle),
                    color:
                        canvasProvider.selectedShape == ShapeType.circle
                            ? Theme.of(context).primaryColor
                            : null,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
