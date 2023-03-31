
import 'dart:math';
import 'package:note/models/image_love.dart';
import 'loves.dart';

class Loves {
  static List<LoveImage> datas = [];
  static getAllImage() {
    datas = mylove.map((element) => LoveImage.fromJson(element)).toList();

    // datas.forEach((element) {
    //   print('${element.id} bjk ${element.image}');
    // });
  }

  int getRandomImage() {
    return Random.secure().nextInt(mylove.length);
  }
}
