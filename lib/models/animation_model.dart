
import 'package:flutter/cupertino.dart';

class AnimationModel with ChangeNotifier {
  bool animation = false;
  bool delay = false;

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
    print('cos change');
  }
}