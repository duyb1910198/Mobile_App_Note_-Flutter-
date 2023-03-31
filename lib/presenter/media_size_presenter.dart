import 'package:flutter/cupertino.dart';
import 'package:note/mvp/presenter.dart';
import 'package:note/presenter_view/media_size_view.dart';

class MediaSizePresenter extends Presenter<MediaSizeView> {

  getMediaSize(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    getView().onGetMediaSize(size);
  }
}