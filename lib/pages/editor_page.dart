import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/canvas/canvas_widget.dart';
import '../widgets/toolbar/toolbar_widget.dart';
import '../widgets/properties_panel/properties_panel.dart';
import '../providers/canvas_provider.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CanvasProvider(),
      child: Scaffold(
        body: Row(
          children: [
            const ToolbarWidget(),
            const Expanded(child: CanvasWidget()),
            const PropertiesPanel(),
          ],
        ),
      ),
    );
  }
}
