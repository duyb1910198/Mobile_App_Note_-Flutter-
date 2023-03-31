
import 'package:flutter/material.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';

class PrimaryAppBar extends StatefulWidget {

  const PrimaryAppBar({ super.key, this.title});
  final String? title;

  @override
  _PrimaryAppBarState createState() => _PrimaryAppBarState();
}

class _PrimaryAppBarState extends State<PrimaryAppBar> {

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 50,
      leadingWidth: double.maxFinite,
      title: Text(
        widget.title ?? '',
        style: AppStyle.senH4.copyWith( color: Colors.white),
      ),
      backgroundColor: AppColor.appBarColor,
    );
  }
}

