import 'package:flutter/material.dart';

class PropertiesPanel extends StatelessWidget {
  const PropertiesPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Theme.of(context).colorScheme.surface,
      child: const Column(
        children: [
          Padding(padding: EdgeInsets.all(8.0), child: Text('Properties')),
        ],
      ),
    );
  }
}
