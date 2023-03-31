
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RouteManager with ChangeNotifier {

  int select = 0;

  changeSelect(int value) {
    select = value;
    notifyListeners();
  }

}