import 'package:flutter/cupertino.dart';
import 'package:note/mvp/mvp_view.dart';

abstract class  MediaSizeView extends MvpView {
  onGetMediaSize(Size size);
}