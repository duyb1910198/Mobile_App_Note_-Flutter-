
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';

class LabelButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool select;

  LabelButton(
      {Key ? key, required this.label, required this.onTap, required this.select})
      : super(key: key);

  @override
  _LabelButtonState createState() => _LabelButtonState();
}

class _LabelButtonState extends State<LabelButton> {

  @override
  Widget build(BuildContext context) {

    return  InkWell(
      overlayColor: getColor(AppColor.white, AppColor.fillColor),
      onTap: () {
        Future.delayed( const Duration( milliseconds: 200),(){
          widget.onTap();
        });
      },
      child: Container(
        width: double.maxFinite ,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only( topRight: Radius.circular(18), bottomRight: Radius.circular(15)),
          color: widget.select ? AppColor.selectButtonColor : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric( horizontal: 8),
              child: widget.select ? Icon(Icons.label, color: Colors.black,size: 20,) : Icon(Icons.label_outline, color: Colors.black,size: 20,),
            ),
            Text(widget.label, style: AppStyle.senH5.copyWith(color: AppColor.black )),
          ],
        ),
      ),
    );
  }

  MaterialStateProperty<Color> getColor(Color pressColor, Color color) {
    getColor(Set<MaterialState> state) {
      if ( state.contains(MaterialState.pressed)) {
        return pressColor;
      }
      return color;
    }
    return MaterialStateProperty.resolveWith(getColor);
  }
}