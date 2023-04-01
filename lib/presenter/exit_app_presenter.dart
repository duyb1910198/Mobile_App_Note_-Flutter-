
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:note/mvp/presenter.dart';
import 'package:note/presenter_view/exit_app_view.dart';

class ExitAppPresenter extends Presenter<ExitAppView> {
  exitApp({required BuildContext context}) async{
    final result = await openExitDialog(context: context);
    if (result != null) {
      print('result true');
      getView().onExitApp(result);
    } else {
      print('result fa;se');
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
      btnCancelOnPress: () => Navigator.of(context).pop(false),
      btnOkOnPress: () => Navigator.of(context).pop(true),
    ).show();
  }
}