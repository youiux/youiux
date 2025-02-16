import 'package:flutter/material.dart';
import '../widgets/canvas_widget.dart';
import '../widgets/toolbar_widget.dart';
import '../widgets/properties_panel.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const ToolbarWidget(),
          const Expanded(child: CanvasWidget()),
          const PropertiesPanel(),
        ],
      ),
    );
  }
}
