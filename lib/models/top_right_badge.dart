import 'package:flutter/material.dart';

class TopRightBadge extends StatelessWidget {
  final Widget child;
  final Object? data;
  final Color? color;

  const TopRightBadge({
    super.key,
    required this.child,
    this.data,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              // color: color ?? Theme.of(context).colorScheme.secondary
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: const Text(
              '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ),

        )
      ],
    );
  }


}