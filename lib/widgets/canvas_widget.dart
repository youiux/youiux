import 'package:flutter/material.dart';

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({super.key});

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> {
  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.1,
      maxScale: 4.0,
      child: Container(
        color: Colors.grey[200],
        child: const Center(child: Text('Design Canvas')),
      ),
    );
  }
}
