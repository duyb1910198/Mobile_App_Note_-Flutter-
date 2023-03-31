import 'package:flutter/material.dart';

class ShapeBottomBar extends StatefulWidget {
  const ShapeBottomBar({super.key});

  @override
  _ShapeBottomBarState createState() => _ShapeBottomBarState();
}

class _ShapeBottomBarState extends State<ShapeBottomBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: MediaQuery.of(context).size.height * 0.07,
      shape: const CircularNotchedRectangle(),
      color: Theme.of(context).colorScheme.primary,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add),
              )
            ],
          ),
        ),
      ),
    );
  }
}
