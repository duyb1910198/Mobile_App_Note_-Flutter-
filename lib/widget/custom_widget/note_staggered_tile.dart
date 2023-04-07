import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note/models/animation_model.dart';
import 'package:note/models/note.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/widget/custom_widget/mini_note_widget.dart';
import 'package:provider/provider.dart';

class NoteStaggeredTile extends StatefulWidget {
  final bool? pin;

  NoteStaggeredTile({super.key, this.pin = false});

  @override
  _NoteStaggeredTileState createState() => _NoteStaggeredTileState();
}

class _NoteStaggeredTileState extends State<NoteStaggeredTile> {
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
          itemCount: myModel.counterCurrent(widget.pin!),
          itemBuilder: (ctx, i) {
            if (!myModel.hasLabel) {
              if (widget.pin!) {
                return buildNote(myModel.pinNotes[i], widget.pin!);
              }
              return buildNote(
                myModel.notes[i],
                widget.pin!,
              );
            } else {
              if (widget.pin!) {
                return buildNote(myModel.pinsLabel[i], widget.pin!);
              }
              return buildNote(
                myModel.notesLabel[i],
                widget.pin!,
              );
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
