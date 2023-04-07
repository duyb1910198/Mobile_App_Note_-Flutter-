import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:note/models/animation_model.dart';
import 'package:note/models/note.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';
import 'package:note/values/share_keys.dart';
import 'package:note/widget/costum_widget/animated_floatbutton_bar.dart';
import 'package:note/widget/costum_widget/note_grid_tile.dart';
import 'package:note/widget/costum_widget/note_list_tile.dart';
import 'package:note/widget/costum_widget/note_staggered_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteTile extends StatefulWidget {
  static const int TYPE_LIST = 0;
  static const int TYPE_GRID = 1;
  static const int TYPE_STAGGERED = 2;
  final int? tile;
  final bool main;

  const NoteTile({super.key, this.tile, required this.main});

  @override
  _NoteTileState createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {
  List<Note> notes = [];
  double sizeOfHeight = 0;
  double sizeOfWidth = 0;

  // List<Note> notes = NoteManager().notes; // demo data
  double viewHeight = 0;
  bool pin = false;
  late SharedPreferences preferences;
  GlobalKey keyNotes = GlobalKey();
  GlobalKey keyPinNotes = GlobalKey();
  double notesHeight = -1;
  double pinHeight = 0;
  late Offset position;

  Size sizeNote = const Size(0, 0);
  Size sizePinNote = const Size(0, 0);

  int idLongPress = -1;

  @override
  void initState() {
    super.initState();
  }

  initPreference({required BuildContext context}) async {
    setSizeOfMedia();
    notes.clear();
    preferences = await SharedPreferences.getInstance();

    String notesId = preferences.getString(ShareKey.notesId) ?? '';
    List<String> checkList = notesId.split(" ");
    if (checkList[0] != '') {
      for (int i = 0; i < checkList.length; i++) {
        String noteString =
            preferences.getString(ShareKey.note + checkList[i]) ?? '';
        Note note = Note.fromJson(json.decode(noteString));

        notes.add(note);
      }
      innitRemoveList();
      context.read<NoteManager>().setNotes(notes);
      context.read<NoteManager>().setPinNotes();
    } // init note list
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initPreference(context: context),
        builder: (context, snapshot) {
          return GestureDetector(
            onTap: () {
              context.read<AnimationModel>().changeAnimation(value: false);
            },
            child: Scaffold(
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: AnimatedFloatButtonBar(
                      textFirstButton: 'Xóa',
                      textSecondButton: 'Hủy',
                      firstButton: Icons.delete_outline,
                      secondButton: Icons.cancel_outlined,
                      duration: 200,
                      size: sizeOfWidth * 0.9,
                      ontapFirstButton: () {
                        context.read<NoteManager>().removeNote(
                            id: idLongPress, preferences: preferences, key: 0);
                      },
                      ontapSecondButton: () {})),
              body: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8),
                        child: Text('Ghim', style: AppStyle.senH5),
                      ),
                      Consumer<NoteManager>(builder: (ctx, myModel, child) {
                        return GestureDetector(
                          onTap: () {
                            context
                                .read<AnimationModel>()
                                .changeAnimation(value: false);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: myModel.getMiniNotesSize(
                                type: widget.tile ?? 0, pin: true),
                            width: sizeOfWidth,
                            child:
                                snapshot.connectionState == ConnectionState.done
                                    ? buildListNote(true)
                                    : Container(),
                          ),
                        );
                      }),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8),
                        child: Text('Ghi chú', style: AppStyle.senH5),
                      ),
                      Consumer<NoteManager>(builder: (context, myModel, child) {
                        return GestureDetector(
                          onTap: () {
                            context
                                .read<AnimationModel>()
                                .changeAnimation(value: false);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: myModel.getMiniNotesSize(
                                type: widget.tile ?? 0, pin: false),
                            child:
                                snapshot.connectionState == ConnectionState.done
                                    ? buildListNote(false)
                                    : Container(),
                          ),
                        );
                      }),
                    ],
                  )),
            ),
          );
        });
  }

  Widget buildIndicator(/*bool isActive, Size size*/) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      height: 50,
      decoration: const BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 3),
              blurRadius: 3,
            )
          ]),
    );
  }

  Widget buildListNote(bool pin) {
    int counterPin = context.read<NoteManager>().counterPin;
    int counter = context.read<NoteManager>().counterNote;
    if (counterPin != 0 || counter != 0) {
      switch (widget.tile) {
        case NoteTile.TYPE_LIST:
          {
            return NoteListTile(
              pin: pin,
            );
          }
        case NoteTile.TYPE_GRID:
          {
            return NoteGridTile(pin: pin);
          }
        case NoteTile.TYPE_STAGGERED:
          {
            return NoteStaggeredTile(
              pin: pin,
            );
          }
        default:
          {
            return NoteListTile(
              pin: pin,
            );
          }
      }
    }
    return Container();
  }

  setSizeOfMedia() {
    sizeOfHeight = MediaQuery.of(context).size.height;
    sizeOfWidth = MediaQuery.of(context).size.width;
  }

  void innitRemoveList() async {
    String removeListString = preferences.getString(ShareKey.removeList) ?? '';
    if (removeListString.isNotEmpty) {
      List<String> list = removeListString.split(" ");

      List<int> removeList = [];

      for (int i = 0; i < list.length; i++) {
        int element = int.parse(list[i]);
        removeList.add(element);
      }

      context.read<NoteManager>().setRemoveList(removeList);
    } else {
      context.read<NoteManager>().setRemoveList([]);
    }
  }
}
