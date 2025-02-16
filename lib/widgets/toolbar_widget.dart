import 'package:flutter/material.dart';

class ToolbarWidget extends StatelessWidget {
  const ToolbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          IconButton(icon: const Icon(Icons.select_all), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.rectangle_outlined),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.text_fields), onPressed: () {}),
        ],
      ),
    );
  }
}
