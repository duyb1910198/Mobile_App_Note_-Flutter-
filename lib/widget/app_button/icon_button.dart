import 'package:flutter/material.dart';
import 'package:note/values/fonts.dart';

class IconTextButton extends StatelessWidget {
  final String label;
  final onTap;
  final IconData icon;
  final double size;

  const IconTextButton(
      {Key? key,
      required this.label,
      required this.onTap,
      required this.icon,
      required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(icon),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                label,
                style: AppStyle.senH5,
              ),
            )
          ],
        ),
      ),
    );
  }
}
