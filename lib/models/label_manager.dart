
import 'package:flutter/cupertino.dart';
import 'package:note/values/share_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LabelManager with ChangeNotifier {
  List<String> _labels =

  [
    'label 1',
    'label 2',
    'label 3',
    'label 4',
    'label 5',
    'label 6',
    'label 7',
    'label 8',
    'label 9'
  ];

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

  count() {
    return labels.length;
  }

  isEmpty(){
    if (labels == null) return true;
    if (count() == 1 && labels[0] == '') return true;
    return false;
  }

  void add({required String text, required SharedPreferences preferences}) {
    int index = _labels.indexWhere((element) => element == text);
    if (index == -1) {
      _labels.add(text);
      setPreference(shareKey: ShareKey.labels, preferences: preferences, stringPreference: preferenceData());
      notifyListeners();
    }
  }

  void update({required String text, required int id, required SharedPreferences preferences}) {

    print('update function: id $id text $text');
    int index = _labels.indexWhere((element) => element == text);

    if (index == -1) {
      if (text.isEmpty) {
        remove(position: id, preferences: preferences);
      } else {
        _labels[id] = text;
      }
    } else {
      remove(position: id, preferences: preferences);
    }

    setPreference(shareKey: ShareKey.labels, preferences: preferences, stringPreference: preferenceData());
    notifyListeners();
  }

  void remove({required int position, required SharedPreferences preferences}) {
    print('remove function:');
    print('remove function: text $position');
    // final index = _labels.indexWhere((element) => element == text);
    _labels.removeAt(position);
    setPreference(shareKey: ShareKey.labels, preferences: preferences, stringPreference: preferenceData());
    notifyListeners();
  }

  // findById({required String id}) {
  //   int index = labels.indexWhere((element) => )
  // }



  setPreference({required String shareKey, required String stringPreference, required SharedPreferences preferences})  {
    print('setPreference function: $stringPreference');
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
    print('toString lables function: lables String return $label');
    return label;
  }

  @override
  String toString() {
    print('toString lables function:');
    String label = '';
    for(int i = 0; i < labels.length; i++) {
      if (i == 0) {
        label += labels[i];
      } else {
        label += ' ${labels[i]}';
      }
    }
    print('toString lables function: lables String return $label');
    return label;
  }

  void deleteAll({required SharedPreferences preferences}) {
    _labels.clear();
    preferences.remove(ShareKey.labels);
  }
}