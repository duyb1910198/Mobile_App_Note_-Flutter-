import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note/models/animation_model.dart';
import 'package:note/models/note.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/models/route_manager.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';
import 'package:note/values/share_keys.dart';
import 'package:note/widget/costum_widget/animated_floatbutton_bar.dart';
import 'package:note/widget/costum_widget/mini_note_widget.dart';
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
  double notesHeight = 0;
  double pinHeight = 0;
  late Offset position;

  Size sizeNote = Size(0, 0);
  Size sizePinNote = Size(0, 0);

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
        log(' pin note $i is: ${note.pin}');

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
          if (snapshot.connectionState == ConnectionState.done) {
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
                              id: idLongPress,
                              preferences: preferences,
                              key: 0);
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
                            child: Container(
                              height: myModel.getMiniNotesSize(
                                  type: widget.tile ?? 0, pin: true),
                              width: sizeOfWidth,
                              child: buildListNote(true),
                            ),
                          );
                        }),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 8),
                          child: Text('Ghi chú', style: AppStyle.senH5),
                        ),
                        Consumer<NoteManager>(
                            builder: (context, myModel, child) {
                          return GestureDetector(
                            onTap: () {
                              context
                                  .read<AnimationModel>()
                                  .changeAnimation(value: false);
                            },
                            child: Container(
                              height: myModel.getMiniNotesSize(
                                  type: widget.tile ?? 0, pin: false),
                              //sizeOfHeight - 250 - (sizeOfHeight *0.1)
                              child: buildListNote(false),
                            ),
                          );
                        }),
                      ],
                    )),
              ),
            );
          }
          return Container(
            height: double.maxFinite,
            width: double.maxFinite,
            color: AppColor.fillColor,
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
            return Consumer<NoteManager>(builder: (context, myModel, child) {
              return AlignedGridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  scrollDirection: Axis.vertical,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 1,
                  itemCount: pin ? myModel.counterPin : myModel.counterNote,
                  itemBuilder: (ctx, i) {
                    if (pin) {
                      return buildNote(myModel.pinNotes[i], pin);
                    }
                    if (context.read<RouteManager>().select < 2) {
                      return buildNote(myModel.notes[i], pin);
                    } else {
                      return buildNote(
                          myModel.findByLabel(id: myModel.label)[i], pin);
                    }
                  });
            });
          }
        case NoteTile.TYPE_GRID:
          {
            return Consumer<NoteManager>(builder: (context, myModel, child) {
              return AlignedGridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  scrollDirection: Axis.vertical,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  itemCount: pin ? myModel.counterPin : myModel.counterNote,
                  itemBuilder: (ctx, i) {
                    if (pin) {
                      return buildNote(myModel.pinNotes[i], pin);
                    }
                    if (context.read<RouteManager>().select < 2) {
                      return buildNote(
                        myModel.notes[i],
                        pin,
                      );
                    } else {
                      return buildNote(
                          myModel.findByLabel(id: myModel.label)[i], pin);
                    }
                  });
            });
          }
        case NoteTile.TYPE_STAGGERED:
          {
            return Consumer<NoteManager>(builder: (context, myModel, child) {
              return MasonryGridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  scrollDirection: Axis.vertical,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  itemCount: context.read<RouteManager>().select < 2
                      ? (pin ? myModel.counterPin : myModel.counterNote)
                      : myModel.findByLabel(id: myModel.label).length,
                  itemBuilder: (ctx, i) {
                    if (pin) {
                      return buildNote(myModel.pinNotes[i], pin);
                    }
                    if (context.read<RouteManager>().select < 2) {
                      return buildNote(
                        myModel.notes[i],
                        pin,
                      );
                    } else {
                      List<Note> list = myModel.findByLabel(id: myModel.label);
                      if (list.length != 0) {
                        return buildNote(
                            myModel.findByLabel(id: myModel.label)[i], pin);
                      } else {
                        return Container();
                      }
                    }
                  });
            });
          }
        default:
          {
            return Consumer<NoteManager>(builder: (context, myModel, child) {
              return AlignedGridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  scrollDirection: Axis.vertical,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 1,
                  itemCount: pin ? myModel.counterPin : myModel.counterNote,
                  itemBuilder: (ctx, i) {
                    if (pin) {
                      return buildNote(myModel.pinNotes[i], pin);
                    }
                    if (context.read<RouteManager>().select < 2) {
                      return buildNote(
                        myModel.notes[i],
                        pin,
                      );
                    } else {
                      return buildNote(
                          myModel.findByLabel(id: myModel.label)[i], pin);
                    }
                  });
            });
          }
      }
    }
    return Container();
  }

  buildNote(Note note, bool pin) {
    return GestureDetector(
        onLongPress: () {
          context.read<AnimationModel>().changeAnimation(value: true);
          idLongPress = note.id;
        },
        child: MiniNoteWidget(
          note: note,
          pin: pin,
          keyCheck: 0,
        ));
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

  Future<bool> rebuild() async {
    if (!mounted) return false;

    // if there's a current frame,
    if (sizePinNote.height == 0) {
      if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
        // wait for the end of that frame.
        await SchedulerBinding.instance.endOfFrame;
        if (!mounted) return false;
      }
      caculateSize();
    }
    return true;
  }

  void caculateSize() => WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          if (sizePinNote.height == 0) {
            final RenderBox box =
                keyPinNotes.currentContext!.findRenderObject() as RenderBox;
            sizePinNote = box.size;
          }
        });
      });
}
