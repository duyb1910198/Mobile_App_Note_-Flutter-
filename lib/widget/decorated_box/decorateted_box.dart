import 'package:flutter/cupertino.dart';
import 'package:note/models/label_manager.dart';
import 'package:note/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:note/values/fonts.dart';

class CustomDecoratedBox extends StatefulWidget {

  final int? label;

  const CustomDecoratedBox({this.label, super.key});

  @override
  _DecoratedBoxState createState() => _DecoratedBoxState();


}

class _DecoratedBoxState extends State<CustomDecoratedBox> {


  @override
  Widget build(BuildContext context) {

    int label = widget.label ?? -1;

    return Padding(
      padding: const EdgeInsets.only( left: 4.0),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: AppColor.appBarColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6),
          child: Text(
            LabelManager().labels[label],
            style:
            AppStyle.blackHanSansH5.copyWith(color: AppColor.white),
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade,
          ),
        ),
      ),
    );
  }
}