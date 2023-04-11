import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note/models/label_manager.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';
import 'package:note/widget/app_drawer/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LabelsPage extends StatefulWidget {
  const LabelsPage({super.key});

  static const String routeName = '/labels_page';

  @override
  _LabelsPageState createState() => _LabelsPageState();
}

class _LabelsPageState extends State<LabelsPage> {
  final List<bool> positions = [];
  List<FocusNode> focusList = [];
  late TextEditingController controller;
  late int previousPosition;
  late SharedPreferences preferences;
  String oldLabel = '';

  @override
  void initState() {
    super.initState();
    previousPosition = -1;
    List<String> list = context.read<LabelManager>().labels;
    for (int i = 0; i < list.length; i++) {
      FocusNode focus = FocusNode();
      focusList.add(focus);
      // bool position = false;
      positions.add(false);
    }
    controller = TextEditingController();
  }

  Future initPreference() async {
    preferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: List.empty());
    return FutureBuilder(
        future: initPreference(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Nhãn',
                style: AppStyle.senH4.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColor.appBarColor,
            ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                setState(() {
                  if (previousPosition != -1) {
                    positions[previousPosition] = false;
                  }
                });
              },
              child: SizedBox(
                height: double.maxFinite,
                width: double.maxFinite,
                child: buildLabelsView(),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              color: AppColor.appBarColor,
              child: SizedBox(
                height: 40,
                child: Container(),
              ),
            ),
            floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked,
            floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                FocusNode focus = FocusNode();
                final label = await openDialog();
                if (label == null || label.isEmpty) {
                  openBlankErrorDialog();
                  return;
                }

                if (!label.contains(',')) {
                  if (label.length < 15){
                    context
                        .read<LabelManager>()
                        .add(text: label, preferences: preferences);
                    focusList.add(focus);
                    positions.add(false);
                    openSuccessDialog();
                  } else {
                    openOverLengthWarningDialog();
                  }
                } else {
                  openCommaWarringDialog();
                }
                controller.text = '';
              },
              // onPressed: () {
              //   context.read<LabelManager>().deleteAll(preferences: preferences);
              // },
              backgroundColor: AppColor.appBarColor,
              child: const Icon(Icons.add),
            ),
            drawer: const AppDrawer(),
          );
        });
  }

  buildLabelsView() {
    return Consumer<LabelManager>(builder: (context, myModal, child) {
      if (context.read<LabelManager>().labels.isNotEmpty) {
        return MasonryGridView.count(
          scrollDirection: Axis.vertical,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          crossAxisCount: 1,
          itemCount: myModal.labels.length,
          shrinkWrap: true,
          itemBuilder: (ctx, i) => buildLabelView(
              label: myModal.labels[i],
              focus: focusList.elementAt(i),
              position: i),
        );
      } else {
        return Container();
      }
    });
  }

  buildLabelView(
      {required String label,
      required FocusNode focus,
      required int position}) {
    TextEditingController controller = TextEditingController();
    controller = setController(label: label);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: IconButton(
            onPressed: () {
              if (positions.elementAt(position)) {
                delete(position: position, focus: focus);
                FocusScope.of(context).unfocus();
              }
            },
            icon: Icon(
              positions.elementAt(position)
                  ? Icons.delete_outline
                  : Icons.label_outline,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: TextField(
              focusNode: focus,
              controller: controller,
              style: AppStyle.senH5.copyWith(fontWeight: FontWeight.w700),
              onChanged: (value) {
                if (!value.contains(',')) {
                  context.read<LabelManager>().update(
                      text: controller.text,
                      id: position,
                      preferences: preferences);
                } else {
                  openCommaWarringDialog();
                }
              },
              onTap: () {
                editLabel(position: position, focus: focus);
              },
              maxLines: null,
              decoration: const InputDecoration(
                  focusColor: AppColor.appBarColor,
                  border: InputBorder.none,
                  focusedBorder: UnderlineInputBorder()),
            ),
          ),
        ),
        IconButton(
            icon: const Icon(Icons.mode_edit_outlined),
            onPressed: () {
              editLabel(position: position, focus: focus);
            }),
      ],
    );
  }

  TextEditingController setController({required String label}) {
    TextEditingController controller = TextEditingController();
    controller.text = label;
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
    return controller;
  }

  void editLabel({required int position, required FocusNode focus}) {
    setState(() {
      positions[(previousPosition != -1) ? previousPosition : position] = false;
      previousPosition = position;
      FocusScope.of(context).requestFocus(focus);
      positions[position] = true;
    });
  }

  void delete({required int position, required FocusNode focus}) {
    if (positions[position]) {
      setState(() {
        context
            .read<LabelManager>()
            .remove(position: position, preferences: preferences);
        positions.removeAt(position);
      });
    }
  }

  Future<String?> openDialog() => showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Nhãn'),
            content: TextField(
              autofocus: true,
              controller: controller,
              style: AppStyle.senH5,
              decoration: const InputDecoration(hintText: 'Nhập nhãn của bạn'),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    submit();
                  },
                  child: const Text('Thêm')),
              TextButton(
                  onPressed: () {
                    cancel();
                  },
                  child: const Text('Hủy'))
            ],
          ));

  void submit() {
    Navigator.of(context).pop(controller.text);
  }

  void cancel() {
    setState(() {
      controller.text = '';
    });
    Navigator.of(context).pop('');
  }

  openSuccessDialog() {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.topSlide,
      showCloseIcon: true,
      title: 'Đã Thêm',
      desc: 'Thêm nhãn thành công',
      btnOkOnPress: () {},
    ).show();
  }

  openCommaWarringDialog() {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.topSlide,
      showCloseIcon: true,
      title: 'Úi',
      desc: 'Nhãn không bao gồm dấy phẩy',
      btnCancelOnPress: () {},
    ).show();
  }

  openOverLengthWarningDialog() {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.topSlide,
      showCloseIcon: true,
      title: 'Úi',
      desc: 'Nhãn không vượt quá 15 ký tự( tính cả khoảng trắng)',
      btnCancelOnPress: () {},
    ).show();
  }

  openBlankErrorDialog() {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.topSlide,
      showCloseIcon: true,
      title: 'Lỗi',
      desc: 'Nhãn không được bỏ trống',
      btnCancelOnPress: () {},
    ).show();
  }
}
