import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:note/models/animation_model.dart';
import 'package:note/models/note.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/presenter/media_size_presenter.dart';
import 'package:note/presenter_view/media_size_view.dart';
import 'package:note/values/fonts.dart';
import 'package:note/values/share_keys.dart';
import 'package:note/widget/custom_widget/animated_float_button_bar.dart';
import 'package:note/widget/custom_widget/note_grid_tile.dart';
import 'package:note/widget/custom_widget/note_list_tile.dart';
import 'package:note/widget/custom_widget/note_staggered_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteTile extends StatefulWidget {
  static const int TYPE_LIST = 0;
  static const int TYPE_GRID = 1;
  static const int TYPE_STAGGERED = 2;
  final int? type;
  final bool main;

  const NoteTile({super.key, this.type, required this.main});

  @override
  _NoteTileState createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> implements MediaSizeView {
  List<Note> notes = [];
  double sizeOfHeight = 0;
  double sizeOfWidth = 0;

  // List<Note> notes = NoteManager().notes; // demo data
  late SharedPreferences preferences;

  late MediaSizePresenter mediaSizePresenter;

  _NoteTileState() {
    mediaSizePresenter = MediaSizePresenter();
    mediaSizePresenter.attachView(this);
  }

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
                  child: Consumer<AnimationModel>(
                    builder: (context, myModel, child) {
                      return AnimatedFloatButtonBar(
                          textFirstButton: 'Xóa',
                          textSecondButton: 'Hủy',
                          firstButton: Icons.delete_outline,
                          secondButton: Icons.cancel_outlined,
                          duration: 200,
                          size: sizeOfWidth * 0.9,
                          ontapFirstButton: () {
                            context.read<NoteManager>().removeNote(
                                id: myModel.pressId, preferences: preferences, key: 0);
                          },
                          ontapSecondButton: () {
                            context.read<AnimationModel>().setNotePress(id: -1);
                          });
                    }
                  )),
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
                                type: widget.type ?? 0, pin: true),
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
                                type: widget.type ?? 0, pin: false),
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

  Widget buildListNote(bool pin) {
    int counterPin = context.read<NoteManager>().counterPin;
    int counter = context.read<NoteManager>().counterNote;
    if (counterPin != 0 || counter != 0) {
      switch (widget.type) {
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
    mediaSizePresenter.getMediaSize(context);
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

  @override
  onGetMediaSize(Size size) {
    sizeOfHeight = size.height;
    sizeOfWidth = size.width;
  }
}
