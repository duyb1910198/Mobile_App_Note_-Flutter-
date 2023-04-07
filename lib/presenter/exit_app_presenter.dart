
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:note/mvp/presenter.dart';
import 'package:note/presenter_view/exit_app_view.dart';

class ExitAppPresenter extends Presenter<ExitAppView> {

  exitApp({required BuildContext context}) async{
    final result = await openExitDialog(context: context);
    if (result != null) {
      getView().onExitApp(result);
    } else {
      getView().onExitApp(false);
    }
  }

  openExitDialog({required BuildContext context}) {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.topSlide,
      showCloseIcon: true,
      title: 'Thoát',
      desc: 'Bạn muốn thoát ứng dụng',
      btnCancelOnPress: () {},
      btnOkOnPress: () => Platform.isAndroid ? SystemNavigator.pop() : exit(0),
    ).show();
  }
}