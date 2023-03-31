import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:note/models/note.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/values/share_keys.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class aNotePageChangeNotifier with ChangeNotifier {

  List<Note> notes = NoteManager().notes;

  List<Note> get getNote {
    return notes;
  }

  changeNote({required int id, required Note note}) {
    notifyListeners();
  }

  setObject({ required BuildContext context}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    for ( int i = 0; i < notes.length; i++) {
      String notesring = jsonEncode(notes[i]);

      await preferences.setString(ShareKey.note + notes[i].id.toString(), notesring);
      context.read<aNotePageChangeNotifier>().changeNote(id: notes[i].id, note: notes[i]);
    }
    setNote();
    notifyListeners();
  }

  setNote() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    for ( int i = 0; i < notes.length; i++) {
      Map<String, dynamic> jsonData =
       await jsonDecode(preferences.getString(ShareKey.note + notes[i].id.toString())!);
      notes[i] = Note.fromJson(jsonData);
    }

  }
}