import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:note/models/widget_height.dart';
import 'package:note/values/share_keys.dart';
import 'package:note/widget/custom_widget/mini_note_widget.dart';
import 'package:note/widget/custom_widget/note_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:note/models/note.dart';

class NoteManager with ChangeNotifier {
  late SharedPreferences preferences;

  List<Note> notes = [];

  List<Note> pinNotes = [];

  List<Note> deleteNotes = [];

  List<int> _removeList = [];

  List<WidgetHeight> sizeOfMainNotes = [];

  List<WidgetHeight> sizeOfPinNotes = [];

  List<Note> pinsLabel = [];

  List<Note> notesLabel = [];

  List<int> checkListOfMainNote = [];

  List<int> checkListOfDeletedNotes = [];

  bool pin = false;

  bool hasLabel = false;

  bool changeStyle = false;

  bool buildHeight = false;

  bool buildHeightPin = false;

  bool hasData = false;

  int maxId = 1;

  int minId = 1;

  int updateHeightId = -1;

  int label = -1;

  int get counterPinLabel => pinsLabel.length;

  int get counterNoteLabel => notesLabel.length;

  int get counterPin => pinNotes.length;

  int get counterNote => notes.length;

  int get deleteNotesCount => deleteNotes.length;

  int type = 0;

  double heightOfNoteList = 0;

  double heightOfPinList = 0;

  initNotesManagerData(
      {required int maxId,
      required int minId,
      required int type,
      required List<Note> notes,
      required List<int> removeList}) {
    setRemoveList(removeList);
    setMaxId(id: maxId, max: true);
    setMaxId(id: minId);
    setType(type);
    setNotes(notes);
    setPinNotes();
    setExistPin();
    setCheckListOfMainNote(
        checkList: getCheckList(key: 0).map((e) => int.parse(e)).toList());
    setCheckListOfDeletedNotes(
        checkList: getCheckList(key: 1).map((e) => int.parse(e)).toList());
    notifyListeners();
  }

  void setPreferencesInstance({required SharedPreferences preferences}) {
    this.preferences = preferences;
  }

  // set pin notes from notes
  setPinNotes() {
    pinsLabel.clear();
    notesLabel.clear();
    List<Note> list = [];
    for (int i = 0; i < counterNote; i++) {
      int index = pinNotes.indexWhere((element) => element.id == notes[i].id);
      if (notes[i].pin && index == -1) {
        list.add(notes[i]);
        if (hasLabel) {
          int index = notes[i].label!.indexWhere((element) => element == label);
          if (index != -1) {
            pinsLabel.add(notes[i]);
          }
        }
      }
      if (index != -1 && !notes[i].pin) {
        pinNotes.removeAt(index);
      }
      if (hasLabel) {
        int index = notes[i].label!.indexWhere((element) => element == label);
        if (index != -1) {
          notesLabel.add(notes[i]);
        }
      }
    }
    pinNotes.addAll(list);
    removeSize(pin: true);
    notifyListeners();
  }

  setDeleteNotes(List<Note> list) {
    deleteNotes = list;
    notifyListeners();
  }

  void setCheckListOfMainNote({required List<int> checkList}) {
    checkListOfMainNote = checkList;
  }

  void setCheckListOfDeletedNotes({required List<int> checkList}) {
    checkListOfDeletedNotes = checkList;
  }

  int addCheckList({required int id, required int key}) {
    if (key == 0) {
      checkListOfMainNote.add(id); // set main check list

      int index = deleteNotes.indexWhere((element) => element.id == id);

      if (index != -1) {
        checkListOfDeletedNotes.remove(id);
        return index;
      }
    } else {
      checkListOfDeletedNotes.add(id);
      checkListOfMainNote.remove(id);
    }
    return -1;
  }

  addPreferencesCheckList({required int key, required int id}) {
    List<int> checkList =
        key == 0 ? checkListOfMainNote : checkListOfDeletedNotes;
    String sharedKey = key == 0 ? ShareKey.notesId : ShareKey.deleteNotesId;
    String notesId = preferences
            .getString(key == 0 ? sharedKey : sharedKey) ??
        '';
    if (checkList.length == 1) {
      preferences.setString(sharedKey, '$id');
    } else {
      preferences.setString(sharedKey, '$notesId $id');
    }
  }

  setPreferencesCheckList({required int key}) {
    List<int> checkList =
        key == 0 ? checkListOfMainNote : checkListOfDeletedNotes;
    String sharedKey = key == 0 ? ShareKey.notesId : ShareKey.deleteNotesId;
    if (checkList.isEmpty) {
      preferences.remove(sharedKey);
    } else {
        String notesId = '';
        for (int i = 0; i < checkList.length; i++) {
            notesId += i == 0
                ? '${checkList[i]}'
                : ' ${checkList[i]}';
        }
        preferences.setString(sharedKey, notesId);
    }
  }

  // note isn't exist in list -> add note to list, else update note (key == 0)
  addNote({required Note note, required int key}) {
    String noteStr = jsonEncode(note);
    setPreference(
        shareKey: key == 0
            ? ShareKey.note + note.id.toString()
            : ShareKey.deleteNote + note.id.toString(),
        stringPreference: noteStr);

    if (key == 0) {
      int index =
          checkListOfMainNote.indexWhere((element) => element == note.id);
      if (index == -1) {
        notes.add(note);
      } else {
        updateNote(note: note);
        return false;
      }
    } else {
      deleteNotes.add(note);
    }

    return true;
  }

  updateNote({required Note note, int index = -1}) {
    if (index == -1) {
      index = notes.indexWhere((element) => element.id == note.id);
    }
    if (index != -1) {
      notes[index] = note;
      setExistPin();
    }
    notifyListeners();
  }

  removeNote({required int id, required int key}) {
    preferences.remove(key == 0
        ? ShareKey.note + id.toString()
        : ShareKey.deleteNote + id.toString());

    final index = key == 0
        ? notes.indexWhere((element) => element.id == id)
        : deleteNotes.indexWhere((element) => element.id == id);

    Note note;
    if (key == 0) {
      // remove note at main note
      note = notes.removeAt(index); // remove at main note
    } else {
      // remove note at deleted note
      note = deleteNotes.removeAt(index); // get id remove
    }
    return note;
  }

  setAddNote({required Note note}) {
    bool add = addNote(note: note, key: 0);

    if (add) {
      // not update note

      int index = addCheckList(id: note.id, key: 0);

      if (index != -1) {
        // note exist in deleted notes -> remove it in deleted notes
        removeNote(id: note.id, key: 1);
      }

      if (note.pin) {
        // note is pin note -> add to pin notes
        pinNotes.add(note);
      }

      if (_removeList.isEmpty) {
        maxId = minId;
        minId++;
      } else {
        _removeList.remove(minId);
        minId = _removeList.isEmpty ? maxId + 1 : findMinId(list: _removeList);
      }

      // preferences data
      setAddPreferences(key: 0, id: note.id);
    } else { // update note -> check pin
      int index = pinNotes.indexWhere((element) => element.id == note.id);
      if (index == -1) {    // note has pin and not exist in pin notes-> add it to pin notes
        if (note.pin) {
          pinNotes.add(note);
        }
      } else {
        if (!note.pin) {
          pinNotes.remove(note);
        }
      }
    }

    // check pin
    setExistPin();

    notifyListeners();
  }

  setRemoveNote({required int id, required int key}) {
    Note note = removeNote(id: id, key: key);

    if (key == 0) {

      // add to deleted note
      addNote(note: note, key: 1);
      addCheckList(id: id, key: 1);

      // remove size
      if (note.pin) {
        // remove size at pin note
        int index = pinNotes.indexWhere((element) => element.id == note.id);
        pinNotes.removeAt(index);
        sizeOfPinNotes.removeAt(index);
      }
      // remove size at main note
      int index = sizeOfMainNotes.indexWhere((element) => element.id == note.id);
      sizeOfMainNotes.removeAt(index);
      setListSize();
    } else {
      // remove id at check list of deleted notes
      checkListOfDeletedNotes
          .remove(id);

      if (!isMaxId(id: id)) {
        // add !maxId to removeList
        _removeList.add(id);
        minId = minId > id ? id : minId;
      } else {
        maxId = findMaxId(list: checkListOfMainNote);
      }

      setMinMaxPreferences();
    }

    setPreferencesCheckList(key: key);

    setExistPin();

    notifyListeners();
  }

  setAddPreferences({required int key, required int id}) {
    setMinMaxPreferences();
    addPreferencesCheckList(key: key, id: id);
  }

  setMinMaxPreferences() {
    preferences.setInt(ShareKey.maxId, maxId);
    preferences.setInt(ShareKey.minId, minId);
  }

  removeListIsEmpty() {
    return _removeList.isEmpty ? true : false;
  }

  setRemoveList(List<int> list) {
    _removeList = list;
  }

  WidgetHeight getMaxElement(List<WidgetHeight> list) {
    if (list.isEmpty) return WidgetHeight(id: -1, height: 0.0);
    WidgetHeight element = list[0];
    for (int i = 1; i < list.length; i++) {
      if (list[i].height > element.height) {
        element = list[i];
      }
    }
    return element;
  }

  WidgetHeight getMinElement(List<WidgetHeight> list) {
    WidgetHeight element = list[0];
    for (int i = 1; i < list.length; i++) {
      if (list[i].height < element.height) {
        element = list[i];
      }
    }
    return element;
  }

  bool isMaxId({required int id}) {
    return max(maxId, id) == id;
  }

  bool minElement(List<int> list, int element) {
    for (int i = 0; i < list.length; i++) {
      if (list[i] < element) {
        return false;
      }
    }
    return true;
  }

  getMaxSizeNote({required bool pin}) {
    WidgetHeight max = WidgetHeight(id: -1, height: -1);
    if (pin) {
      for (int i = 0; i < sizeOfPinNotes.length; i++) {
        if (sizeOfPinNotes[i].height >= max.height) {
          max = sizeOfPinNotes[i];
        }
      }
    } else {
      for (int i = 0; i < sizeOfMainNotes.length; i++) {
        if (sizeOfMainNotes[i].height >= max.height) {
          max = sizeOfMainNotes[i];
        }
      }
    }
    return max;
  }

  setNotes(List<Note> list) {
    notes = list;
    notifyListeners();
  }

  setExistPin() {
    int index = notes.indexWhere((element) => element.pin);
    pin = index == -1 ? false : true;
    notifyListeners();
  }

  bool existNote({required int id}) {
    Note? note = findById(id);
    if (note == null) {
      return false;
    }
    return true;
  }

  removeListMin() {
    int min = _removeList[0];
    for (int i = 1; i < _removeList.length; i++) {
      if (_removeList[i] < min) {
        min = _removeList[i];
      }
    }
    return min;
  }

  setHasLabel({required bool value, required int label}) {
    hasLabel = value;
    this.label = label;
    setNoteLabels();
    notifyListeners();
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

  List<Note> findByLabel({required int id}) {
    List<Note> list = [];
    for (int i = 0; i < counterNote; i++) {
      List<int> labels = notes[i].label ?? [];
      if (labels != []) {
        if (labels.indexWhere((element) => element == id) != -1) {
          list.add(notes[i]);
        }
      }
    }
    return list;
  }

  List<String> getCheckList({required int key}) {
    String notesId = getCheckString(key: key);
    List<String> checkList = notesId.split(" ");
    return checkList;
  }

  String getCheckString({required int key}) {
    String notesId = preferences
            .getString(key == 0 ? ShareKey.notesId : ShareKey.deleteNotesId) ??
        '';
    return notesId;
  }

  setPreference({required String shareKey, required String stringPreference}) {
    preferences.setString(shareKey, stringPreference);
  }

  setRemoveListReference({int? idRemove}) {
    String temp = '';
    if (_removeList.isNotEmpty) {
      if (_removeList[0] != '') {
        _removeList.remove(idRemove);
        for (int i = 0; i < _removeList.length; i++) {
          temp += i == 0
              ? _removeList[i].toString()
              : ' ${_removeList[i].toString()}';
        }
        preferences.setString(ShareKey.removeList, temp);
      } else {}
    }
  }

  // remove size not exist note
  removeSize({required bool pin}) {
    if (pin) {
      for (int i = 0; i < sizeOfPinNotes.length; i++) {
        int index = pinNotes
            .indexWhere((element) => element.id == sizeOfPinNotes[i].id);
        if (index == -1) {
          removeSizeOfMainNotes(pin: true, position: i);
        }
      }
    } else {
      for (int i = 0; i < sizeOfMainNotes.length; i++) {
        int index =
            notes.indexWhere((element) => element.id == sizeOfMainNotes[i].id);
        if (index == -1) {
          removeSizeOfMainNotes(pin: false, position: i);
        }
      }
    }
    setListSize();
    notifyListeners();
  }

  addSizeOfMainNotes(
      {required double height, required bool pin, required int id}) {
    if (pin) {
      int exist = sizeOfPinNotes.indexWhere((element) => element.id == id);
      if (exist == -1) {
        WidgetHeight widgetHeight = WidgetHeight(id: id, height: height);
        sizeOfPinNotes.add(widgetHeight);
      } else {
        updateSizeOfMainNotes(height: height, pin: pin, id: id);
      }
    } else {
      int exist = sizeOfMainNotes.indexWhere((element) => element.id == id);
      if (exist == -1) {
        WidgetHeight widgetHeight = WidgetHeight(id: id, height: height);
        sizeOfMainNotes.add(widgetHeight);
      } else {
        updateSizeOfMainNotes(height: height, pin: pin, id: id);
      }
    }
    changeStyle = false;
    setListSize();
    notifyListeners();
  }

  updateSizeOfMainNotes(
      {required double height, required bool pin, required int id}) {
    if (pin) {
      int index = sizeOfPinNotes.indexWhere((element) => element.id == id);
      if (index != -1) {
        sizeOfPinNotes[index] = WidgetHeight(id: id, height: height);
      }
    } else {
      int index = sizeOfMainNotes.indexWhere((element) => element.id == id);
      if (index != -1) {
        sizeOfMainNotes[index] = WidgetHeight(id: id, height: height);
      }
    }
    changeStyle = false;
    setListSize();
    notifyListeners();
  }

  removeSizeOfMainNotes({required position, required bool pin}) {
    if (pin) {
      sizeOfPinNotes.removeAt(position);
    } else {
      sizeOfMainNotes.removeAt(position);
    }
    notifyListeners();
  }

  setListSize() {
    heightOfPinList = setSizeOfMainNotes(type: type, pin: true);
    heightOfNoteList = setSizeOfMainNotes(type: type, pin: false);
  }

  double setSizeOfMainNotes(
      {required int type, required bool pin, int? label = -1}) {
    List<WidgetHeight> labelHeights = [];
    if (label != -1) {
      int count = pin ? counterPinLabel : counterNoteLabel;
      for (int i = 0; i < count; i++) {
        if (notesLabel[i].id == 4) {}
        if (notesLabel[i].id == 17) {}
        if (pin) {
          int index = sizeOfPinNotes
              .indexWhere((element) => element.id == pinsLabel[i].id);
          if (index != -1) {
            labelHeights.add(sizeOfPinNotes[index]);
          }
        } else {
          int index = sizeOfMainNotes
              .indexWhere((element) => element.id == notesLabel[i].id);
          if (index != -1) {
            labelHeights.add(sizeOfMainNotes[index]);
          }
        }
      }
    }
    switch (type) {
      case NoteTile.TYPE_LIST:
        {
          if (label == -1) {
            return pin
                ? getHeightList(sizeOfPinNotes)
                : getHeightList(sizeOfMainNotes);
          } else {
            return getHeightList(labelHeights);
          }
        }
      case NoteTile.TYPE_GRID:
        {
          if (label == -1) {
            return getHeightGrid(
                heights: pin ? sizeOfPinNotes : sizeOfMainNotes, pin: pin);
          } else {
            return getHeightGrid(heights: labelHeights, pin: pin);
          }
        }
      case NoteTile.TYPE_STAGGERED:
        {
          int counter = -1;
          if (pin) {
            counter = counterPin;
          } else {
            counter = counterNote;
          }
          if (counter == 0) {
            return 0.0;
          }
          if (label == -1) {
            if (counter == 1) {
              return getHeightColumn(1, pin ? sizeOfPinNotes : sizeOfMainNotes);
            }

            return getStaggeredHeight(
              widgetHeights: pin ? sizeOfPinNotes : sizeOfMainNotes,
            );
          } else {
            if (labelHeights.length == 1) {
              return getHeightColumn(1, labelHeights);
            }
            return labelHeights.isNotEmpty
                ? getStaggeredHeight(
                    widgetHeights: labelHeights,
                  )
                : 0.0;
          }
        }
      default:
        {
          return getHeightList(pin ? sizeOfPinNotes : sizeOfMainNotes);
        }
    }
  }

  double getHeightColumn(int column, List<WidgetHeight> heights) {
    double height = 0;
    for (int i = 0; i < heights.length; i++) {
      if (column == 1) {
        if (i == 0 || i % 2 == 0) {
          height += heights[i].height;
        }
      } else {
        if (i != 0 && i % 2 != 0) {
          height += heights[i].height;
        }
      }
    }
    return height;
  }

  double getHeightGrid(
      {required List<WidgetHeight> heights, required bool pin}) {
    if (heights.isEmpty) return 0.0;
    double height1 = 0.0;
    double height2 = 0.0;
    height1 = getHeightColumn(1, heights);
    height2 = getHeightColumn(2, heights);
    return height1 >= height2 ? height1 : height2;
  }

  double getHeightList(List<WidgetHeight> heights) {
    double height = 0;
    if (heights.isEmpty) return 0.0;
    for (int i = 0; i < heights.length; i++) {
      height += heights[i].height;
    }
    return height;
  }

  setUpdateHeight({required int id}) {
    updateHeightId = id;
  }

  //delete all data preferences
  void deleteAll() {
    notes = [];
    pinNotes = [];
    sizeOfMainNotes = [];
    sizeOfPinNotes = [];
    checkListOfMainNote = [];
    checkListOfDeletedNotes = [];
    deleteNotes = [];
    _removeList = [];
    maxId = 1;
    minId = 1;
    preferences.remove(ShareKey.minId);
    preferences.remove(ShareKey.maxId);
    preferences.remove(ShareKey.notesId);
    preferences.remove(ShareKey.deleteNotesId);
    preferences.remove(ShareKey.removeList);
    setListSize();
    notifyListeners();
  }

  double getStaggeredHeight({required List<WidgetHeight> widgetHeights}) {
    if (widgetHeights.isEmpty) {
      return 0.0;
    }
    List<WidgetHeight> list = [];
    list.addAll(widgetHeights);
    WidgetHeight max = getMaxElement(list);
    double sizeCheck = getHeightList(list);

    if (sizeCheck - max.height <= max.height) {
      return max.height;
    }
    int counter = widgetHeights.length;

    double column1 = widgetHeights[0].height;
    double column2 = 0.0;

    for (int i = 1; i < counter; i++) {
      if (column1 >= column2) {
        column2 += widgetHeights[i].height;
      } else {
        column1 += widgetHeights[i].height;
      }
    }
    return column1 >= column2 ? column1 : column2;
  }

  setNoteLabels() {
    pinsLabel.clear();
    notesLabel.clear();
    List<Note> noteLabels = [];
    noteLabels.addAll(findByLabel(id: label));
    for (int i = 0; i < noteLabels.length; i++) {
      int pinIndex =
          pinNotes.indexWhere((element) => element.id == noteLabels[i].id);
      int noteIndex =
          notes.indexWhere((element) => element.id == noteLabels[i].id);

      if (pinIndex != -1) {
        pinsLabel.add(pinNotes[pinIndex]);
      }

      if (noteIndex != -1) {
        notesLabel.add(notes[noteIndex]);
      }
    }
  }

  counterCurrent(bool pin) {
    if (hasLabel) {
      return pin ? counterPinLabel : counterNoteLabel;
    } else {
      return pin ? counterPin : counterNote;
    }
  }

  Widget buildNote(Note note) {
    return MiniNoteWidget(
      note: note,
      pin: pin,
      keyCheck: 0,
    );
  }

  setChangeStyle({required bool style}) {
    changeStyle = style;
  }

  void setType(int tile) {
    type = tile;
    notifyListeners();
  }

  void setMaxId({required int id, bool max = false}) {
    if (max) {
      maxId = id;
    } else {
      minId = id;
    }
  }

  int findMaxId({required List<int> list}) {
    int max = list[0];
    for (int i = 1; i < list.length; i++) {
      if (max < list[i]) {
        max = list[i];
      }
    }
    return max;
  }

  int findMinId({required List<int> list}) {
    int min = list[0];
    for (int i = 1; i < list.length; i++) {
      if (min > list[i]) {
        min = list[i];
      }
    }
    return min;
  }
}
