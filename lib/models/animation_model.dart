
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
    animation = value;
    notifyListeners();
    if (value) {
      delay = true;
      notifyListeners();
      Future.delayed( const Duration( milliseconds: 200),(){
        delay = false;
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