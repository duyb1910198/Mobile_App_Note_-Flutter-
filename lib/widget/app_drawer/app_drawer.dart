import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note/models/label_manager.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/models/route_manager.dart';
import 'package:note/page.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';
import 'package:note/widget/app_button/app_button.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  // final int page;

  const AppDrawer({
    super.key,
    /*this.page*/
  });

  @override
  _DrawerWidget createState() => _DrawerWidget();
}

class _DrawerWidget extends State<AppDrawer> {
  double labelsHeight = -1;

  @override
  Widget build(BuildContext context) {
    rebuild();
    return Drawer(
      backgroundColor: AppColor.white,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        child: Consumer<RouteManager>(builder: (context, myModal, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Ghi chú',
                  style: AppStyle.senH3,
                ),
              ),
              AppButton(
                label: "Ghi chú",
                onTap: () {
                  if (!stay(0, myModal.select)) {
                    myModal.changeSelect(0);
                    context.read<NoteManager>().setHasLabel(value: false, label: -1);
                    Navigator.of(context)
                        .pushReplacementNamed(NoteOverviewPage.routeName);
                  }
                },
                select: (myModal.select == 0) ? true : false,
                iconSelect: Icons.lightbulb,
                iconUnSelect: Icons.lightbulb_outline,
                height: 40,
              ),
              const Divider(
                color: AppColor.black,
              ),
              Container(
                  margin: const EdgeInsets.only(left: 18),
                  child: Text(
                    'Nhãn',
                    style: AppStyle.senH4,
                  )),
              AppButton(
                label: "Tạo nhãn mới",
                onTap: () {
                  if (!stay(1, myModal.select)) {
                    myModal.changeSelect(1);
                    context.read<NoteManager>().setHasLabel(value: false, label: -1);
                    Navigator.of(context)
                        .pushReplacementNamed(LabelsPage.routeName);
                  }
                },
                select: (myModal.select == 1) ? true : false,
                iconSelect: Icons.add,
                height: 40,
              ),
              context.read<LabelManager>().labels.isNotEmpty
                  ? Container(
                      height: labelsHeight == -1 ? 0 : labelsHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: MasonryGridView.count(
                          scrollDirection: Axis.vertical,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          crossAxisCount: 1,
                          itemCount: context.read<LabelManager>().labels.length,
                          itemBuilder: (ctx, i) => buildLabelView(
                              label: context.read<LabelManager>().labels[i],
                              select: myModal.select,
                              id: i)),
                    )
                  : Container(),
              const Divider(
                color: AppColor.black,
              ),
              AppButton(
                label: "Thùng rác",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NoteRecycleBinPage()));
                },
                select: false,
                iconSelect: Icons.delete_outline,
                height: 40,
              ),
              AppButton(
                label: "Cài đặt",
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingPage()));
                },
                select: false,
                iconSelect: Icons.settings_outlined,
                height: 40,
              ),
            ],
          );
        }),
      ),
    );
  }

  bool stay(int i, int select) {
    return (select == i) ? true : false;
  }

  buildLabelView(
      {required String label, required int select, required int id}) {
    // return LabelButton(
    //     label: label,
    //     onTap: () {
    //       setState(() {
    //         Future.delayed(const Duration(milliseconds: 260), () {
    //           Navigator.of(context).pop();
    //         });
    //         if (context.read<RouteManager>().select != 1) {
    //           context.read<NoteManager>().setHasLabel(value: true, label: id);
    //           context.read<RouteManager>().changeSelect(id + 2);
    //         }
    //       });
    //     },
    //     select: select == id + 2);

    return AppButton(
      label: label,
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          if (context.read<RouteManager>().select != 1) {
            context.read<NoteManager>().setHasLabel(value: true, label: id);
            context.read<RouteManager>().changeSelect(id + 2);
          }
        });
      },
      select: select == id + 2,
      iconSelect: Icons.label,
      iconUnSelect: Icons.label_outline,
      height: 40,
      textStyle: AppStyle.senH5.copyWith(color: AppColor.black),
    );
  }

  Future<bool> rebuild() async {
    if (!mounted) return false;

    // if there's a current frame,
    if (labelsHeight == -1) {
      if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
        // wait for the end of that frame.
        await SchedulerBinding.instance.endOfFrame;
        if (!mounted) return false;
      }
      setState(() {
        log('size is ${context.read<LabelManager>().labels.isNotEmpty}');
        labelsHeight =
            (40 * context.read<LabelManager>().count()).toDouble() + 16;
      });
    }
    return true;
  }
}
