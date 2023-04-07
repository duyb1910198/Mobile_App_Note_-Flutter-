
import 'package:flutter/cupertino.dart';

class AnimationModel with ChangeNotifier {
  bool animation = false;
  bool delay = false;
  int pressId = -1;


  setNotePress({required int id}) {
    pressId = id;
    notifyListeners();
  }


  changeAnimation({required bool value}) {
    print('onchange is $value');
    animation = value;
    notifyListeners();
    if (value) {
      print('value true model');
      delay = true;
      notifyListeners();
      Future.delayed( const Duration( milliseconds: 200),(){
        delay = false;
        print('delay = false true model');
        notifyListeners();
      });
    } else {
      delay = true;
      notifyListeners();
      Future.delayed( const Duration( milliseconds: 180),(){
        delay = false;
        notifyListeners();
      });
    }
  }
}