
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:note/mvp/presenter.dart';
import 'package:note/presenter_view/width_image_view.dart';

class WidthImagePresenter extends Presenter<WidthImageView> {

  widthOfImage(dynamic file, double sizeParent) {
    double height = 0;
    double width = 0;
    double widthImageFromWidget = -1;
    Image image = Image.file(file);

    Completer<dynamic> completer = Completer<dynamic>();
    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool_) {
      completer.complete(info.image);
      height = info.image.height.toDouble();
      width = info.image.width.toDouble();
      widthImageFromWidget = width * (sizeParent / height);
      getView().onWidthOfImage(widthImageFromWidget);
    }));
  }

}