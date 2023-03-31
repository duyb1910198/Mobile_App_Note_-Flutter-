
import 'package:flutter/material.dart';

class FontSizeChangnotifier with ChangeNotifier {
  double labelSize = 10;
  double contentSize = 10;

  changeFontSize({ required labelSize, required contentSize}) {
    this.labelSize = labelSize;
    this.contentSize = contentSize;
    notifyListeners();
  }
}