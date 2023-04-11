import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note/models/animation_model.dart';
import 'package:note/models/font_size_change_notifier.dart';
import 'package:note/models/label_manager.dart';
import 'package:note/models/note.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/page/note_detail_page.dart';
import 'package:note/presenter/exit_app_presenter.dart';
import 'package:note/presenter_view/exit_app_view.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';
import 'package:note/values/share_keys.dart';
import 'package:note/widget/app_drawer/app_drawer.dart';
import 'package:note/widget/custom_widget/note_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/top_right_badge.dart';

class NoteOverviewPage extends StatefulWidget {
  static const String routeName = '/note_overview_page';

  const NoteOverviewPage({super.key});

  @override
  _NoteOverviewPageState createState() => _NoteOverviewPageState();
}

class _NoteOverviewPageState extends State<NoteOverviewPage>
    implements ExitAppView {
  late SharedPreferences preferences;
  int labelSize = 25;

  int contentSize = 18;

  late Future<bool> isExit;

  late ExitAppPresenter exitAppPresenter;

  @override
  void initState() {
    super.initState();
    initPreference();
  }

  _NoteOverviewPageState() {
    exitAppPresenter = ExitAppPresenter();
    exitAppPresenter.attachView(this);
  }

  initPreference() async {
    preferences = await SharedPreferences.getInstance();
    context.read<NoteManager>().setPreferencesInstance(preferences: preferences);
    labelSize = preferences.getInt(ShareKey.sizeLabel) ?? 25;
    contentSize = preferences.getInt(ShareKey.sizeContent) ?? 18;
    context.read<NoteManager>().setType(preferences.getInt(ShareKey.tile) ?? 0);
    context.read<FontSizeChangnotifier>().changeFontSize(
        labelSize: labelSize.toDouble(), contentSize: contentSize.toDouble());

    String labelStr = preferences.getString(ShareKey.labels) ?? '';

    List<String> labels = [];
    if (labelStr.isNotEmpty) {
      labels = labelStr.split(',');
    }
    context.read<LabelManager>().labels = labels;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: List.empty());
    return FutureBuilder(
        future: initPreference(),
        builder: (context, snapshot) {
          return WillPopScope(
            onWillPop: exitApp,
            child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Ghi chú',
                    style: AppStyle.senH4.copyWith(color: Colors.white),
                  ),
                  actions: <Widget>[
                    buildSortTypeIcon(),
                  ],
                  backgroundColor: AppColor.appBarColor,
                ),
                body: const NoteTile(
                  main: true,
                ),
                drawer: const AppDrawer(),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButtonAnimator:
                    FloatingActionButtonAnimator.scaling,
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    newNote();
                    // context.read<NoteManager>().deleteAll(preferences: preferences); // delete all data (to demo)
                  },
                  tooltip: 'Increment',
                  backgroundColor: AppColor.appBarColor,
                  child: const Icon(Icons.add),
                )),
          );
        });
  }

  Widget buildSortTypeIcon() {
    return Consumer<NoteManager>(builder: (context, myModel, child) {
      return Row(
        children: [
          TopRightBadge(
            child: IconButton(
              icon: const Icon(
                Icons.delete_forever_outlined,
              ),
              onPressed: () async {
                deleteAllNote();
              },
            ),
          ),

          TopRightBadge(
            child: IconButton(
              icon: Icon(
                getSortIcon(myModel.type),
              ),
              onPressed: () async {
                context.read<AnimationModel>().changeAnimation(value: false);
                context.read<NoteManager>().setChangeStyle(style: true);
                changeType();
              },
            ),
          ),
        ],
      );
    });
  }

  IconData getSortIcon(int tile) {
    IconData icon;

    switch (tile) {
      case NoteTile.TYPE_LIST:
        {
          icon = Icons.list;
        }
        break;

      case NoteTile.TYPE_GRID:
        {
          icon = Icons.grid_view;
        }
        break;

      case NoteTile.TYPE_STAGGERED:
        {
          icon = Icons.line_style;
        }
        break;
      default:
        {
          icon = Icons.grid_view;
        }
        break;
    }

    return icon;
  }

  void changeType() {
    int type = context.read<NoteManager>().type;
    if (type != 2) {
      type++;
    } else {
      type = 0;
    }
    context.read<NoteManager>().setType(type);
    preferences.setInt(ShareKey.tile, context.read<NoteManager>().type);
  }

  void newNote() {
    // context.read<NoteManager>().deleteAll(preferences: preferences);
    int id = context.read<NoteManager>().minId;
    Note note = Note(id: id, content: '', images: [], label: []);
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => NoteDetailPage(note: note)));
  }

  Future<bool> exitApp() async {
    exitAppPresenter.exitApp(context: context);
    return true;
  }

  @override
  onExitApp(bool isExit) {}

  deleteAllNote() {
      return AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        title: 'Xoá tất cả',
        desc: 'Bạn muốn xóa toàn bộ dữ liệu ghi chú',
        btnCancelOnPress: () {},
        btnOkOnPress: () => context.read<NoteManager>().deleteAll(),
      ).show();
  }
}
