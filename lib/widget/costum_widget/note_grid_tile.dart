import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note/models/animation_model.dart';
import 'package:note/models/note.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/models/route_manager.dart';
import 'package:note/widget/costum_widget/mini_note_widget.dart';
import 'package:provider/provider.dart';

class NoteGridTile extends StatefulWidget {

  final bool? pin;

  NoteGridTile({super.key, this.pin = false});

  @override
  _NoteGridTileState createState() => _NoteGridTileState();
}

class _NoteGridTileState extends State<NoteGridTile>{

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteManager>(builder: (context, myModel, child) {
      return AlignedGridView.count(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          scrollDirection: Axis.vertical,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          itemCount: widget.pin! ? myModel.counterPin : myModel.counterNote,
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
              return buildNote(
                  myModel.findByLabel(id: myModel.label)[i], widget.pin!);
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