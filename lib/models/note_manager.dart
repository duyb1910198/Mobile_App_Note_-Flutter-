import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:note/models/note_tile.dart';
import 'package:note/models/widget_height.dart';
import 'package:note/values/share_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'note.dart';

class NoteManager with ChangeNotifier {
  List<Note> notes = [];

  List<Note> pinNotes = [];

  List<Note> deleteNotes = [];

  List<int> _removeList = [];

  List<WidgetHeight> miniNotesSize = [];
  List<WidgetHeight> pinNotesSize = [];

  bool pin = false;

  bool hasLabel = false;

  bool changeStyle = false;

  int updateHeightId = -1;

  int label = -1;

  int get counterPin => pinNotes.length;

  int get noteCount => notes.length;

  int get deleteNotesCount => deleteNotes.length;

  setHasLabel({required bool value, required int label}) {
    print('setHasLabel function: value is [$value] label is [$label]');
    this.hasLabel = value;
    this.label = label;
    notifyListeners();
  }

  setRemoveList(List<int> list) {
    _removeList = list;
  }

  notesCount() {
    return notes.length;
  }

  firstIdRemove() {
    print('firstIdRemove founction: removeListIsEmpty ${removeListIsEmpty()} ');
    print('firstIdRemove founction: removeList is ${_removeList} ');

    if (notes.length == 0) {
      print(
          'firstIdRemove founction: id return = ${removeListIsEmpty() ? 1 : removeListMin()}');
      return removeListIsEmpty() ? 1 : removeListMin();
    } else {
      print(
          'firstIdRemove founction: id return = ${removeListIsEmpty() ? getMaxId() + 1 : removeListMin()}');
      return removeListIsEmpty() ? getMaxId() + 1 : removeListMin();
    }
  }

  getMaxId() {
    int id = notes[0].id;
    int length = noteCount >= deleteNotesCount ? noteCount : deleteNotesCount;
    for (int i = 1; i < length; i++) {
      if (noteCount > i) {
        if (id < notes[i].id) {
          id = notes[i].id;
        }
      }
      if (deleteNotesCount > i) {
        if (id < deleteNotes[i].id) {
          id = deleteNotes[i].id;
        }
      }
    }
    return id;
  }

  setNotes(List<Note> list) {
    notes = list;
    pin = existPin();
    notifyListeners();
  }

  setDeleteNotes(List<Note> list) {
    deleteNotes = list;
    notifyListeners();
  }

  addNote(
      {required Note note,
      required SharedPreferences preferences,
      required int key}) {
    print('addNote founction : remove list now ++ ${_removeList}');
    String noteString = jsonEncode(note);
    String notesId = getCheckString(preferences: preferences, key: key);
    List<String> checkList = getCheckList(preferences: preferences, key: key);

    setPreference(
        shareKey: key == 0
            ? ShareKey.note + note.id.toString()
            : ShareKey.deleteNote + note.id.toString(),
        stringPreference: noteString,
        preferences: preferences);

    if (notesId == '') {
      if (key == 0){
        int index = deleteNotes.indexWhere((element) => element.id == note.id);
        if (index != -1) {
          removeNote(id: note.id, preferences: preferences, key: 1);
        }
        notes.add(note);
      } else {
        deleteNotes.add(note);
      }
    } else {
      for (int i = 0; i < checkList.length; i++) {
        if (int.parse(checkList[i]) == note.id) {
          if (key == 0) {
            updateNote(note: note);
          }
          break;
        } else if (i == checkList.length - 1) {
          if (key == 0){
            int index = deleteNotes.indexWhere((element) => element.id == note.id);
            if (index != -1) {
              removeNote(id: note.id, preferences: preferences, key: 1);
            }
            notes.add(note);
          } else {
            deleteNotes.add(note);
          }
        }
      }
    }
    setCheckList(key: key, note: note, preferences: preferences);
    if (key == 0) {
      setPinNotes();
    }
    notifyListeners();
  }

  setCheckList(
      {required int key,
      required Note note,
      required SharedPreferences preferences}) {

    List<String> checkList = getCheckList(preferences: preferences, key: key);
    String notesId = getCheckString(preferences: preferences, key: key);
    if (notesId == '') {
      setPreference(
          shareKey: key == 0 ? ShareKey.notesId : ShareKey.deleteNotesId,
          stringPreference: '${note.id}',
          preferences: preferences);
    } else {
      for (int i = 0; i < checkList.length; i++) {
        if (int.parse(checkList[i]) == note.id) {
          break;
        } else if (i == checkList.length - 1) {
          setPreference(
              shareKey: key == 0 ? ShareKey.notesId : ShareKey.deleteNotesId,
              stringPreference: '$notesId ${note.id}',
              preferences: preferences);
        }
      }
    }
  }

  updateNote({required Note note}) {
    final index = notes.indexWhere((element) => element.id == note.id);
    if (index >= 0) {
      notes[index] = note;
      pin = existPin();
    }
    notifyListeners();
  }

  void removeNote({required int id, required SharedPreferences preferences, required int key}) {
    print('note id is ${id}');
    final index = key == 0 ? notes.indexWhere((element) => element.id == id) : deleteNotes.indexWhere((element) => element.id == id);
    String checkListString = '';
    int removeElement = -1;
    List<String> checkList = getCheckList(preferences: preferences, key: key);
    for (int i = 0; i < checkList.length; i++) {
      if (int.parse(checkList[i]) == id) {
        if (key == 0) {
          removeElement = int.parse(checkList.removeAt(i));
          addNote(note: notes[index], preferences: preferences, key: 1);
          notes.removeAt(index);
          removeSize(pin: false);
        } else {
          removeElement = int.parse(checkList.removeAt(i));
          deleteNotes.removeAt(index);
        }
        break;
      }
    }
    for (int i = 0; i < checkList.length; i++) {
      if (i == 0) {
        checkListString += checkList[i];
      } else {
        checkListString += ' ${checkList[i]}';
      }
    }

    // _removeList add after deleteNotes remove item
    if (key == 1) {
      if (!maxElement(checkList, removeElement)) {
        _removeList.add(id);
        setRemoveListReference(preferences: preferences);
      }
    }

    setPreference(
        shareKey: key == 0 ? ShareKey.notesId : ShareKey.deleteNotesId,
        stringPreference: checkListString,
        preferences: preferences);
    preferences.remove( key == 0 ? ShareKey.note + id.toString() : ShareKey.deleteNote + id.toString());
    setPinNotes();

    notifyListeners();
  }

  removeListIsEmpty() {
    return _removeList.length == 0 ? true : false;
  }

  bool existPin() {
    try {
      Note? notePin = notes.firstWhere((note) => note.pin == true);
      return notePin == null ? false : true;
    } catch (error) {
      return false;
    }
  }

  bool existNote({required int id}) {
    Note? note = findById(id);
    if (note == null) {
      return false;
    }
    return true;
  }

  Note? findById(int id) {
    int index = notes.indexWhere((element) => element.id == id);
    if (index == -1) {
      index = deleteNotes.indexWhere((element) => element.id == id);
      if (index != -1) {
        return deleteNotes[index];
      }
    }
    if (index != -1) {
      return notes[index];
    }

    return null;
  }

  deleteAll({required SharedPreferences preferences}) {
    notes = [];
    deleteNotes = [];
    _removeList = [];
    preferences.remove(ShareKey.notesId);
    preferences.remove(ShareKey.deleteNotesId);
    preferences.remove(ShareKey.removeList);
    notifyListeners();
  }

  getCheckList({required SharedPreferences preferences, required int key}) {
    String notesId = getCheckString(preferences: preferences, key: key) ?? '';
    List<String> checkList = notesId.split(" ");
    return checkList;
  }

  getCheckString({required SharedPreferences preferences, required int key}) {
    String notesId = preferences.getString(key == 0 ? ShareKey.notesId : ShareKey.deleteNotesId) ?? '';
    print('check string is');
    print('check string ${notesId}');
    return notesId;
  }

  setPreference(
      {required String shareKey,
      required String stringPreference,
      required SharedPreferences preferences}) {
    preferences.setString(shareKey, stringPreference);
  }

  removeListMin() {
    print('removeListMin founction:');
    int min = _removeList[0];
    print('removeListMin founction: min before check = $min');
    ;
    for (int i = 1; i < _removeList.length; i++) {
      print('removeListMin founction: min in check = $min');
      if (_removeList[i] < min) {
        min = _removeList[i];
        print('removeListMin founction: min change = $min');
      }
    }
    print('removeListMin founction: min return = $min');
    return min;
  }

  void setRemoveListReference(
      {required SharedPreferences preferences, int? idRemove}) {
    print('setRemoveListReference founction:');
    String temp = '';
    if (_removeList.isNotEmpty) {
      print(
          'setRemoveListReference founction: _removeList.isNotEmpty $_removeList => ${_removeList.isNotEmpty}');
      if (_removeList[0] != '') {
        _removeList.remove(idRemove);
        for (int i = 0; i < _removeList.length; i++) {
          temp += i == 0
              ? _removeList[i].toString()
              : ' ${_removeList[i].toString()}';
          print(
              'setRemoveListReference founction: remove list add = ${_removeList[i]}');
        }
        print('setRemoveListReference founction: set preference string: $temp');
        preferences.setString(ShareKey.removeList, temp);
      } else {
        print('setRemoveListReference founction: _removeList[0] = '
            ' ${_removeList[0]}');
      }
    }
  }

  bool maxElement(List<String> checkList, int element) {
    print('maxElement founction: check list $checkList + position $element');
    for (int i = 0; i < checkList.length; i++) {
      if (int.parse(checkList[i]) > element) {
        print('maxElement founction: not id max $element');
        return false;
      }
    }
    print('maxElement founction: is id max $element');
    return true;
  }

  List<Note> findByLabel({required int id}) {
    List<Note> list = [];
    for (int i = 0; i < noteCount; i++) {
      List<int> labels = notes[i].label ?? [];
      if (labels != []) {
        if (labels.indexWhere((element) => element == id) != -1) {
          list.add(notes[i]);
        }
      }
    }
    return list;
  }

  setPinNotes() {
    print('setPinNotes function');
    List<Note> list = [];
    for (int i = 0; i < noteCount; i++) {
      if (notes[i].pin) {
        list.add(notes[i]);
      }
    }
    pinNotes = list;
    removeSize(pin: true);
    print('setPinNotes function: pin count = ${pinNotes.length}');
    notifyListeners();
  }

  addMiniNotesSize(
      {required double height, required bool pin, required int id}) {
    print('addMiniNotesSize function:');
    if (pin) {
      int exist = pinNotesSize.indexWhere((element) => element.id == id);
      if (exist == -1) {
        WidgetHeight widgetHeight = WidgetHeight(id: id, height: height);
        pinNotesSize.add(widgetHeight);
      } else {
        updateMiniNotesSize(height: height, pin: pin, id: id);
      }
    } else {
      int exist = miniNotesSize.indexWhere((element) => element.id == id);
      if (exist == -1) {
        WidgetHeight widgetHeight = WidgetHeight(id: id, height: height);
        miniNotesSize.add(widgetHeight);
      } else {
        updateMiniNotesSize(height: height, pin: pin, id: id);
      }
    }
    notifyListeners();
  }

  removeMiniNotesSize({required position, required bool pin}) {
    print('removeMiniNotesSize function');
    if (pin) {
      pinNotesSize.removeAt(position);
    } else {
      miniNotesSize.removeAt(position);
    }
    notifyListeners();
  }

  updateMiniNotesSize(
      {required double height, required bool pin, required int id}) {
    print('updateMiniNotesSize function:');
    if (pin) {
      int index = pinNotesSize.indexWhere((element) => element.id == id);
      pinNotesSize[index] = WidgetHeight(id: id, height: height);
    } else {
      int index = miniNotesSize.indexWhere((element) => element.id == id);
      miniNotesSize[index] = WidgetHeight(id: id, height: height);
    }
    notifyListeners();
  }

  getMiniNotesSize({required int type, required bool pin}) {
    print('getMiniNotesSize function:');
    double column1 = 0;
    double column2 = 0;
    for ( int i = 0; i < pinNotesSize.length; i++) {
      print('pin: i is [$i] heightheight is: ${pinNotesSize[i].height}');
      print('mini: i is [$i] height is: ${miniNotesSize[i].height}');
    }
    if (pin) {
      if (pinNotesSize.isEmpty) return column1;
      print('getMiniNotesSize function: pin count = ${pinNotesSize.length}');
      column1 = getHeightColumn(true, pinNotesSize);
      column2 = getHeightColumn(false, pinNotesSize);
    } else {
      if (miniNotesSize.isEmpty) return column1;
      column1 = getHeightColumn(true, miniNotesSize);
      column2 = getHeightColumn(false, miniNotesSize);
    }
    switch (type) {
      case NoteTile.TYPE_LIST:
        {
          print(
              'size TYPE_LIST is column1 ${pin ? getHeightList(pinNotesSize) : getHeightList(miniNotesSize)}');
          return pin
              ? getHeightList(pinNotesSize)
              : getHeightList(miniNotesSize);
        }
      case NoteTile.TYPE_GRID:
        {
          print('size TYPE_GRID is column1 ${column1} column2 ${column2}');
          return column1;
        }
      case NoteTile.TYPE_STAGGERED:
        {
          print('size TYPE_STAGGERED is column1 ${column1} column2 ${column2}');
          return column1 >= column2 ? column1 : column2;
        }
      default:
        {
          return column1;
        }
    }
  }

  double getHeightColumn(bool column, List<WidgetHeight> heights) {
    double height = 0;
    for (int i = 0; i < heights.length; i++) {
      if (column) {
        if (i == 0 || i % 2 == 0) {
          height += heights[i].height;
          print('[i] f: $i height ${heights[i].id}');
        }
      } else {
        if (i != 0 && i % 2 != 0) {
          height += heights[i].height;
          print('[i] s: $i');
        }
      }
    }
    print('getHeightColumn :heigth is $height');
    return height;
  }

  double getHeightList(List<WidgetHeight> heights) {
    double height = 0;
    for (int i = 0; i < heights.length; i++) {
      height += heights[i].height;
    }
    print('getHeightList heigth is $height');
    return height;
  }

  setUpdateHeight({required int id}) {
    updateHeightId = id;
  }

  void removeSize({required bool pin}) {
    if (pin) {
      for (int i = 0; i < pinNotesSize.length; i++) {
        int index =
        pinNotes.indexWhere((element) => element.id == pinNotesSize[i].id);
        if (index == -1) {
          removeMiniNotesSize(pin: true, position: i);
        }
      }
    } else {
      for (int i = 0; i < miniNotesSize.length; i++) {
        int index =
        notes.indexWhere((element) => element.id == miniNotesSize[i].id);
        if (index == -1) {
          removeMiniNotesSize(pin: false, position: i);
        }
      }
    }
  }
}
