
import 'package:flutter/material.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';

class AppButton extends StatelessWidget{
  final String        label;
  final VoidCallback  onTap;
  final bool          select;
  final IconData      icon;

  const AppButton({Key ? key, required this.label, required this.onTap, required this.select, required this.icon}) : super(key : key);

  @override
  Widget build(BuildContext context) {
    
    return  InkWell(
      overlayColor: getColor(AppColor.white, AppColor.fillColor),
      onTap: () {
        Navigator.of(context).pop();
        Future.delayed( const Duration( milliseconds: 255),(){
          onTap();
        });
      },
      child: Container(
        width: double.maxFinite ,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only( topRight: Radius.circular(18), bottomRight: Radius.circular(15)),
          color: select ? AppColor.graylight : null,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric( horizontal: 20),
              child: Icon(icon, color: Colors.black,size: 22,),
            ),
            Text(label, style: AppStyle.senH4.copyWith(color: AppColor.black )),
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