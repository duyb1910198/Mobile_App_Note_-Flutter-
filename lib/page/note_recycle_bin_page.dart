import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:note/models/animation_model.dart';
import 'package:note/models/note.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/models/route_manager.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';
import 'package:note/values/share_keys.dart';
import 'package:note/widget/app_drawer/app_drawer.dart';
import 'package:note/widget/costum_widget/animated_floatbutton_bar.dart';
import 'package:note/widget/costum_widget/mini_note_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteRecycleBinPage extends StatefulWidget {
  static const String routeName = '/note_recycle_bin_page';

  const NoteRecycleBinPage({super.key});

  @override
  NoteRecycleBinPageState createState() => NoteRecycleBinPageState();
}

class NoteRecycleBinPageState extends State<NoteRecycleBinPage> {
  List<Note> notes = [];
  double sizeOfHeight = 0;
  double sizeOfWidth = 0;

  // List<Note> notes = NoteManager().notes; // demo data
  double viewHeight = 0;
  bool pin = false;
  late SharedPreferences preferences;
  GlobalKey keyNotes = GlobalKey();
  GlobalKey keyPinNotes = GlobalKey();
  double notesHeight = 0;
  double pinHeight = 0;
  late Offset position;
  double floatButtonWidth = 0;

  Size sizeNote = Size(0, 0);

  bool isLongPress = false;

  late ValueNotifier<bool> isLongPressV;

  int noteId = -1;

  @override
  void initState() {
    super.initState();
  }

  initData() async {
    isLongPressV = ValueNotifier(isLongPress);
    setSizeOfMedia();
    notes.clear();
    preferences = await SharedPreferences.getInstance();
    String notesId = preferences.getString(ShareKey.deleteNotesId) ?? '';
    print('notesId is $notesId');
    List<String> checkList = notesId.split(" ");
    int count = checkList.length;
    print('count.length is ${count}');
    if (checkList[0] != '') {
      for (int i = 0; i < count; i++) {
        String noteString =
            preferences.getString(ShareKey.deleteNote + checkList[i]) ?? '';
        print('noteString is $noteString');
        Note note = Note.fromJson(json.decode(noteString));
        print('note  is ${note.id}');
        notes.add(note);
      }
      innitRemoveList();
      context.read<NoteManager>().setDeleteNotes(notes);
    } // init note list
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: List.empty());
    return FutureBuilder(
        future: initData(),
        builder: (context, snapshot) {
          return Scaffold(
              appBar: AppBar(
                title: Text('Thùng rác',
                    style: AppStyle.senH4.copyWith(color: AppColor.white)),
                backgroundColor: AppColor.appBarColor,
                leading: InkWell(
                  onTap: () {
                    context.read<AnimationModel>().changeAnimation(value: false);
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              body: SingleChildScrollView(
                child: GestureDetector(
                  onTap: () {
                    context
                        .read<AnimationModel>()
                        .changeAnimation(value: false);
                  },
                  onLongPress: () {
                    context
                        .read<AnimationModel>()
                        .changeAnimation(value: false);
                  },
                  child: Container(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    child: buildDeleteNotes(),
                  ),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: AnimatedFloatButtonBar(
                      textFirstButton: 'Khôi phục',
                      textSecondButton: 'Xóa vĩnh viễn',
                      FirstButton: Icons.undo,
                      SecondButton: Icons.delete_outline,
                      duration: 200,
                      size: sizeOfWidth * 0.9,
                      ontapFirstButton: () {
                        Note note = context
                            .read<NoteManager>()
                            .deleteNotes
                            .firstWhere((element) => element.id == noteId);
                        context.read<NoteManager>().addNote(
                            note: note, preferences: preferences, key: 0);
                      },
                      ontapSecondButton: () {
                        context.read<NoteManager>().removeNote(
                            id: noteId, preferences: preferences, key: 1);
                      })
              ));
        });
  }

  setSizeOfMedia() {
    sizeOfHeight = MediaQuery.of(context).size.height;
    sizeOfWidth = MediaQuery.of(context).size.width;
  }

  void innitRemoveList() async {}

  buildDeleteNotes() {
    return Consumer<NoteManager>(builder: (ctx, myModel, child) {
      print('delete count = ${myModel.deleteNotesCount}');
      return AlignedGridView.count(
          physics: NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          scrollDirection: Axis.vertical,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 1,
          itemCount: myModel.deleteNotesCount,
          itemBuilder: (ctx, i) {
            return GestureDetector(
                onTap: () {
                  context.read<AnimationModel>().changeAnimation(value: true);
                  noteId = myModel.deleteNotes[i].id;
                },
                onLongPress: () {
                  context.read<AnimationModel>().changeAnimation(value: true);
                  noteId = myModel.deleteNotes[i].id;
                },
                child: MiniNoteWidget(
                  note: myModel.deleteNotes[i],
                  keyCheck: 1,
                ));
          });
    });
  }
}