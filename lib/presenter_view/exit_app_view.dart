import 'package:note/mvp/mvp_view.dart';

abstract class ExitAppView extends MvpView {
  onExitApp(Future<bool> exit);
}