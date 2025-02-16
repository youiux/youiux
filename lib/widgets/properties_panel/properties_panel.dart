import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/canvas_provider.dart';

class PropertiesPanel extends StatelessWidget {
  const PropertiesPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Theme.of(context).colorScheme.surface,
      child: Consumer<CanvasProvider>(
        builder: (context, canvasProvider, child) {
          if (canvasProvider.selectedElement == null) {
            return const Center(child: Text('No element selected'));
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Properties'),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Width'),
                  initialValue:
                      canvasProvider.selectedElement!.width.toString(),
                  onChanged: (value) {
                    canvasProvider.updateSelectedElement(
                      width: double.tryParse(value) ?? 50,
                    );
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Height'),
                  initialValue:
                      canvasProvider.selectedElement!.height.toString(),
                  onChanged: (value) {
                    canvasProvider.updateSelectedElement(
                      height: double.tryParse(value) ?? 50,
                    );
                  },
                ),
                // Add more properties here (e.g., color, position)
              ],
            ),
          );
        },
      ),
    );
  }
}
