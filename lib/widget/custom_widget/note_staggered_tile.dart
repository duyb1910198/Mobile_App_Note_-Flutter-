import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note/models/animation_model.dart';
import 'package:note/models/note.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/models/route_manager.dart';
import 'package:note/widget/custom_widget/mini_note_widget.dart';
import 'package:provider/provider.dart';

class NoteStaggeredTile extends StatefulWidget {

  final bool? pin;

  NoteStaggeredTile({super.key, this.pin = false});

  @override
  _NoteStaggeredTileState createState() => _NoteStaggeredTileState();
}

class _NoteStaggeredTileState extends State<NoteStaggeredTile>{


  @override
  Widget build(BuildContext context) {
    return Consumer<NoteManager>(builder: (context, myModel, child) {
      return MasonryGridView.count(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          scrollDirection: Axis.vertical,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          itemCount: context.read<RouteManager>().select < 2
              ? (widget.pin! ? myModel.counterPin : myModel.counterNote)
              : myModel.findByLabel(id: myModel.label).length,
          itemBuilder: (ctx, i) {
            if (widget.pin!) {
              return buildNote(myModel.pinNotes[i], widget.pin!);
            }
            if (context.read<RouteManager>().select < 2) {
              return buildNote(
                myModel.notes[i],
                widget.pin!,
              );
            } else {
              List<Note> list = myModel.findByLabel(id: myModel.label);
              if (list.length != 0) {
                return buildNote(
                    myModel.findByLabel(id: myModel.label)[i], widget.pin!);
              } else {
                return Container();
              }
            }
          });
    });
  }

  buildNote(Note note, bool pin) {
    return GestureDetector(
        onLongPress: () {
          context.read<AnimationModel>().changeAnimation(value: true);
          context.read<AnimationModel>().setNotePress(id: note.id);
        },
        child: MiniNoteWidget(
          note: note,
          pin: pin,
          keyCheck: 0,
        ));
  }
}