

import 'package:flutter/cupertino.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/values/share_keys.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LabelManager with ChangeNotifier {
  List<String> _labels = [];

  LabelManager() {
  }

  LabelManager.fromString(String labelStr) {
    List<String> listLabel = labelStr.split(",");
    _labels.clear();
    _labels.addAll(listLabel);
    notifyListeners();
  }

  set labels(List<String> labels) {
    _labels = labels;
    notifyListeners();
  }

  List<String> get labels {
    var labels = _labels;
    return labels;
  }

  int get count => labels.length;

  bool add({required String text, required SharedPreferences preferences}) {
    int index = _labels.indexWhere((element) => element.trim() == text.trim());
    if (index == -1) {
      _labels.add(text.trim());
      setPreference(shareKey: ShareKey.labels, preferences: preferences, stringPreference: preferenceData());
      notifyListeners();
      return true;
    }
    return false;
  }

  void update({required String text, required int id, required SharedPreferences preferences, required BuildContext context}) {

    int index = _labels.indexWhere((element) => element == text);

    if (index == -1) {
      if (text.isEmpty) {
        remove(position: id, preferences: preferences, context: context);
      } else {
        _labels[id] = text;
      }
    } else {
      remove(position: id, preferences: preferences, context: context);
    }

    setPreference(shareKey: ShareKey.labels, preferences: preferences, stringPreference: preferenceData());
    notifyListeners();
  }

  void remove({required int position, required SharedPreferences preferences, required BuildContext context}) {
    context.read<NoteManager>().removeDeadLabel(context: context, position: position);
    _labels.removeAt(position);

    setPreference(shareKey: ShareKey.labels, preferences: preferences, stringPreference: preferenceData());
    notifyListeners();
  }

  setPreference({required String shareKey, required String stringPreference, required SharedPreferences preferences})  {
    preferences.setString(shareKey, stringPreference);
  }

  preferenceData() {
    String label = '';
    for(int i = 0; i < labels.length; i++) {
      if (i == 0) {
        label += labels[i];
      } else {
        label += ' ,${labels[i]}';
      }
    }
    return label;
  }

  void deleteAll({required SharedPreferences preferences}) {
    _labels.clear();
    preferences.remove(ShareKey.labels);
  }
}