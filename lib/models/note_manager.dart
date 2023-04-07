import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:note/models/widget_height.dart';
import 'package:note/values/share_keys.dart';
import 'package:note/widget/custom_widget/note_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'note.dart';

class NoteManager with ChangeNotifier {
  List<Note> notes = [];

  List<Note> pinNotes = [];

  List<Note> deleteNotes = [];

  List<int> _removeList = [];

  List<WidgetHeight> miniNotesSize = [];

  List<WidgetHeight> pinNotesSize = [];

  List<Note> pinsLabel = [];

  List<Note> notesLabel = [];

  bool pin = false;

  bool hasLabel = false;

  bool changeStyle = false;

  int updateHeightId = -1;

  int label = -1;

  int get counterPinLabel => pinsLabel.length;

  int get counterNoteLabel => notesLabel.length;

  int get counterPin => pinNotes.length;

  int get counterNote => notes.length;

  int get deleteNotesCount => deleteNotes.length;

  // set pin notes from notes
  setPinNotes() {
    pinsLabel.clear();
    notesLabel.clear();
    List<Note> list = [];
    for (int i = 0; i < counterNote; i++) {
      if (notes[i].pin) {
        list.add(notes[i]);
        if (hasLabel) {
          int index = notes[i].label!.indexWhere((element) => element == label);
          if (index != -1) {
            pinsLabel.add(notes[i]);
          }
        }
      }
      if (hasLabel) {
        int index = notes[i].label!.indexWhere((element) => element == label);
        if (index != -1) {
          notesLabel.add(notes[i]);
        }
      }
    }
    pinNotes = list;
    removeSize(pin: true);
    notifyListeners();
  }

  setDeleteNotes(List<Note> list) {
    deleteNotes = list;
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

  addNote(
      {required Note note,
      required SharedPreferences preferences,
      required int key}) {
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
      if (key == 0) {
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
          if (key == 0) {
            int index =
                deleteNotes.indexWhere((element) => element.id == note.id);
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

  updateNote({required Note note}) {
    final index = notes.indexWhere((element) => element.id == note.id);
    if (index >= 0) {
      notes[index] = note;
      pin = existPin();
    }
    notifyListeners();
  }

  removeNote(
      {required int id,
      required SharedPreferences preferences,
      required int key}) {
    final index = key == 0
        ? notes.indexWhere((element) => element.id == id)
        : deleteNotes.indexWhere((element) => element.id == id);
    String checkListString = '';
    int removeElement = -1;
    List<String> checkList = getCheckList(preferences: preferences, key: key);
    for (int i = 0; i < checkList.length; i++) {
      if (int.parse(checkList[i]) == id) {
        if (key == 0) {
          removeElement = int.parse(checkList.removeAt(i));
          addNote(note: notes[index], preferences: preferences, key: 1);
          Note temp = notes.removeAt(index);
          notesLabel.remove(temp);
          if (temp.pin) {
            pinsLabel.remove(temp);
          }
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
    preferences.remove(key == 0
        ? ShareKey.note + id.toString()
        : ShareKey.deleteNote + id.toString());
    setPinNotes();

    notifyListeners();
  }

  removeListIsEmpty() {
    return _removeList.isEmpty ? true : false;
  }

  setRemoveList(List<int> list) {
    _removeList = list;
  }

  int firstIdRemove() {
    if (notes.isEmpty) {
      return removeListIsEmpty() ? 1 : removeListMin();
    } else {
      return removeListIsEmpty() ? getMaxId() + 1 : removeListMin();
    }
  }

  int getMaxId() {
    int id = notes[0].id;
    int length =
        counterNote >= deleteNotesCount ? counterNote : deleteNotesCount;
    for (int i = 1; i < length; i++) {
      if (counterNote > i) {
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

  WidgetHeight getMaxElement(List<WidgetHeight> list) {
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

  bool maxElement(List<String> list, int element) {
    for (int i = 0; i < list.length; i++) {
      if (int.parse(list[i]) > element) {
        return false;
      }
    }
    return true;
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
      for (int i = 0; i < pinNotesSize.length; i++) {
        if (pinNotesSize[i].height >= max.height) {
          max = pinNotesSize[i];
        }
      }
    } else {
      for (int i = 0; i < miniNotesSize.length; i++) {
        if (miniNotesSize[i].height >= max.height) {
          max = miniNotesSize[i];
        }
      }
    }
    return max;
  }

  setNotes(List<Note> list) {
    notes = list;
    pin = existPin();
    notifyListeners();
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

  List<String> getCheckList(
      {required SharedPreferences preferences, required int key}) {
    String notesId = getCheckString(preferences: preferences, key: key);
    List<String> checkList = notesId.split(" ");
    return checkList;
  }

  String getCheckString(
      {required SharedPreferences preferences, required int key}) {
    String notesId = preferences
            .getString(key == 0 ? ShareKey.notesId : ShareKey.deleteNotesId) ??
        '';
    return notesId;
  }

  setPreference(
      {required String shareKey,
      required String stringPreference,
      required SharedPreferences preferences}) {
    preferences.setString(shareKey, stringPreference);
  }

  setRemoveListReference(
      {required SharedPreferences preferences, int? idRemove}) {
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
    notifyListeners();
  }

  addMiniNotesSize(
      {required double height, required bool pin, required int id}) {
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
    if (pin) {
      pinNotesSize.removeAt(position);
    } else {
      miniNotesSize.removeAt(position);
    }
    notifyListeners();
  }

  updateMiniNotesSize(
      {required double height, required bool pin, required int id}) {
    if (pin) {
      int index = pinNotesSize.indexWhere((element) => element.id == id);
      if (index != -1) {
        pinNotesSize[index] = WidgetHeight(id: id, height: height);
      }
    } else {
      int index = miniNotesSize.indexWhere((element) => element.id == id);
      if (index != -1) {
        miniNotesSize[index] = WidgetHeight(id: id, height: height);
      }
    }
    notifyListeners();
  }

  double getMiniNotesSize(
      {required int type, required bool pin, int? label = -1}) {
    if (miniNotesSize.isNotEmpty && pinNotesSize.isNotEmpty) {
      List<WidgetHeight> labelHeights = [];
      if (label != -1) {
        int count = pin ? counterPinLabel : counterNoteLabel;
        for (int i = 0; i < count; i++) {
          if (notesLabel[i].id == 4) {
          }
          if (notesLabel[i].id == 17) {
          }
          if (pin) {
            int index = pinNotesSize.indexWhere((element) => element.id == pinsLabel[i].id);
            if (index != -1) {
              labelHeights.add(pinNotesSize[index]);
            }
          } else {
            int index = miniNotesSize.indexWhere((element) => element.id == notesLabel[i].id);
            if (index != -1) {
              labelHeights.add(miniNotesSize[index]);
            }
          }
        }
      }
      switch (type) {
        case NoteTile.TYPE_LIST:
          {
            if (label == -1) {
              return pin
                  ? getHeightList(pinNotesSize)
                  : getHeightList(miniNotesSize);
            } else {
              return getHeightList(labelHeights);
            }
          }
        case NoteTile.TYPE_GRID:
          {
            if (label == -1) {
              return getHeightGrid(
                  heights: pin ? pinNotesSize : miniNotesSize, pin: pin);
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

            if (label == -1) {
              if (counter == 1) {
                return getHeightColumn(1, pin ? pinNotesSize : miniNotesSize);
              }
              return getStaggeredHeight(
                widgetHeights: pin ? pinNotesSize : miniNotesSize,
              );
            } else {
              if (labelHeights.length == 1) {
                return getHeightColumn(1, labelHeights);
              }
              return labelHeights.isNotEmpty
                  ? getStaggeredHeight(
                      widgetHeights: labelHeights,
                    )
                  : 0;
            }
          }
        default:
          {
            return getHeightList(pin ? pinNotesSize : miniNotesSize);
          }
      }
    }
    return 0;
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
    double height1 = 0;
    double height2 = 0;
    height1 = getHeightColumn(1, heights);
    height2 = getHeightColumn(2, heights);
    return height1 >= height2 ? height1 : height2;
  }

  double getHeightList(List<WidgetHeight> heights) {
    double height = 0;
    for (int i = 0; i < heights.length; i++) {
      height += heights[i].height;
    }
    return height;
  }

  setUpdateHeight({required int id}) {
    updateHeightId = id;
  }

  //delete all data preferences
  deleteAll({required SharedPreferences preferences}) {
    notes = [];
    deleteNotes = [];
    _removeList = [];
    preferences.remove(ShareKey.notesId);
    preferences.remove(ShareKey.deleteNotesId);
    preferences.remove(ShareKey.removeList);
    notifyListeners();
  }

  getStaggeredHeight({required List<WidgetHeight> widgetHeights}) {
    List<WidgetHeight> list = [];
    list.addAll(widgetHeights);
    WidgetHeight max = getMaxElement(list);
    double sizeCheck = getHeightList(list);

    if (sizeCheck - max.height <= max.height) {
      return max.height;
    }
    int counter = widgetHeights.length;

    double column1 = widgetHeights[0].height;
    double column2 = 0;

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
      int pinIndex = pinNotes.indexWhere((element) => element.id == noteLabels[i].id);
      int noteIndex = notes.indexWhere((element) => element.id == noteLabels[i].id);

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
}
