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
  int tile = 0;
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
    labelSize = preferences.getInt(ShareKey.sizeLabel) ?? 25;
    contentSize = preferences.getInt(ShareKey.sizeContent) ?? 18;
    tile = preferences.getInt(ShareKey.tile) ?? 0;
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
                    buildSortTypeIcon(tile),
                  ],
                  backgroundColor: AppColor.appBarColor,
                ),
                body: NoteTile(
                  type: tile,
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

  Widget buildSortTypeIcon(int tile) {
    return TopRightBadge(
      child: IconButton(
        icon: Icon(
          getSortIcon(tile),
        ),
        onPressed: () async {
          context.read<AnimationModel>().changeAnimation(value: false);
          context.read<NoteManager>().changeStyle = true;
          changeType();
        },
      ),
    );
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
    setState(() {
      if (tile != 2) {
        tile++;
      } else {
        tile = 0;
      }
      preferences.setInt(ShareKey.tile, tile);
    });
  }

  void newNote() {
    // context.read<NoteManager>().deleteAll(preferences: preferences);
    int id = context.read<NoteManager>().notes.isEmpty
        ? 1
        : context.read<NoteManager>().firstIdRemove();
    Note note = Note(id: id, content: '', images: [], label: []);
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => DetailNotePage(notes: note)));
  }

  Future<bool> exitApp() async {
    exitAppPresenter.exitApp(context: context);
    return true;
  }

  @override
  onExitApp(bool isExit) {}
}
