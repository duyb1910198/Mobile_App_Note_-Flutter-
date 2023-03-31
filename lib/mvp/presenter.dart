import 'mvp_view.dart';

class Presenter<T extends MvpView> {

  late T view;

  attachView(T view) {
    this.view = view;
  }

  getView() {
    return view;
  }
}
