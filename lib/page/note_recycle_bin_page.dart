import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note/models/animation_model.dart';
import 'package:note/models/note.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/presenter/media_size_presenter.dart';
import 'package:note/presenter_view/media_size_view.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';
import 'package:note/values/share_keys.dart';
import 'package:note/widget/custom_widget/animated_float_button_bar.dart';
import 'package:note/widget/custom_widget/mini_note_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteRecycleBinPage extends StatefulWidget {
  static const String routeName = '/note_recycle_bin_page';

  const NoteRecycleBinPage({super.key});

  @override
  NoteRecycleBinPageState createState() => NoteRecycleBinPageState();
}

class NoteRecycleBinPageState extends State<NoteRecycleBinPage> implements MediaSizeView{
  List<Note> notes = [];
  double sizeOfHeight = 0;
  double sizeOfWidth = 0;

  late SharedPreferences preferences;

  bool isLongPress = false;

  late ValueNotifier<bool> isLongPressV;

  int noteId = -1;

  late MediaSizePresenter mediaSizePresenter;


  NoteRecycleBinPageState() {
    mediaSizePresenter = MediaSizePresenter();
    mediaSizePresenter.attachView(this);
  }

  @override
  void initState() {
    super.initState();
  }

  initData() async {
    isLongPressV = ValueNotifier(isLongPress);
    notes.clear();
    preferences = await SharedPreferences.getInstance();
    String notesId = preferences.getString(ShareKey.deleteNotesId) ?? '';
    List<String> checkList = notesId.split(" ");
    int count = checkList.length;
    if (checkList[0] != '') {
      for (int i = 0; i < count; i++) {
        String noteString =
            preferences.getString(ShareKey.deleteNote + checkList[i]) ?? '';
        Note note = Note.fromJson(json.decode(noteString));
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
    setSizeOfMedia();
    return FutureBuilder(
        future: initData(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
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
                        textSecondButton: 'Xóa vanish viễn',
                        firstButton: Icons.undo,
                        secondButton: Icons.delete_outline,
                        duration: 200,
                        size: sizeOfWidth * 0.9,
                        ontapFirstButton: () {
                          Note note = context
                              .read<NoteManager>()
                              .deleteNotes
                              .firstWhere((element) => element.id == noteId);
                          context.read<NoteManager>().addNote(
                              note: note, preferences: preferences, key: 0);
                          if (context.read<NoteManager>().hasLabel) {
                            int index = note.label!.indexWhere((element) => element == context.read<NoteManager>().label);
                            if (index != -1) {
                              context.read<NoteManager>().notesLabel.add(note);
                              if (note.pin) {
                                context.read<NoteManager>().pinsLabel.add(note);
                              }
                            }
                          }
                        },
                        ontapSecondButton: () {
                          context.read<NoteManager>().removeNote(
                              id: noteId, preferences: preferences, key: 1);
                        })
                ));
          }
          return Container();

        });
  }

  setSizeOfMedia() {
    mediaSizePresenter.getMediaSize(context);
  }

  void innitRemoveList() async {}

  buildDeleteNotes() {
    return Consumer<NoteManager>(builder: (ctx, myModel, child) {
      return AlignedGridView.count(
          physics: const NeverScrollableScrollPhysics(),
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


  @override
  onGetMediaSize(Size size) {
    setState(() {
      sizeOfHeight = size.height;
      sizeOfWidth = size.width;
    });
  }
}
