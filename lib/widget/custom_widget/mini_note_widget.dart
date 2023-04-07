import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note/app_path/assets_path.dart';
import 'package:note/models/font_size_change_notifier.dart';
import 'package:note/models/label_manager.dart';
import 'package:note/models/note.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/page/note_detail_page.dart';
import 'package:note/presenter/width_image_presenter.dart';
import 'package:note/presenter_view/width_image_view.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MiniNoteWidget extends StatefulWidget {
  final Note note;
  final bool? pin;
  final int keyCheck;

  const MiniNoteWidget(
      {super.key, required this.note, this.pin, required this.keyCheck});

  @override
  MiniNoteWidgetState createState() => MiniNoteWidgetState();
}

class MiniNoteWidgetState extends State<MiniNoteWidget>
    implements WidthImageView {
  late SharedPreferences preferences;

  double get heightImages => widget.note.images!.isEmpty ? 0 : 100;

  double sizeOfHeight = 0;
  double sizeOfWidth = 0;

  List<double> imagesWidth = [];

  double heightTest = 0;
  Size sizePinNote = const Size(0, 0);
  final keyMiniNote = GlobalKey();

  late WidthImagePresenter widthImagePresenter;

  MiniNoteWidgetState() {
    widthImagePresenter = WidthImagePresenter();
    widthImagePresenter.attachView(this);
  }

  @override
  void initState() {
    setImageWidthItem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    rebuild();
    return FutureBuilder(
        future: initData(),
        builder: (context, snapshot) {
          return Consumer<NoteManager>(builder: (context, myModelNote, child) {
            int index = widget.keyCheck == 0
                ? context
                    .read<NoteManager>()
                    .notes
                    .indexWhere((element) => element.id == widget.note.id)
                : context
                    .read<NoteManager>()
                    .deleteNotes
                    .indexWhere((element) => element.id == widget.note.id);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              key: keyMiniNote,
              decoration: index == -1 &&
                      snapshot.connectionState == ConnectionState.done
                  ? const BoxDecoration()
                  : BoxDecoration(
                      color: Color(myModelNote
                              .findById(widget.note.id)!
                              .backgroundColor ??
                          0xffffffff),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColor.black,
                          offset: Offset(2, 3),
                          blurRadius: 10,
                        )
                      ],
                      image: DecorationImage(
                          image: AssetImage(myModelNote
                                  .findById(widget.note.id)!
                                  .backgroundImage ??
                              AssetsPath.empty1),
                          fit: BoxFit.cover),
                    ),
              child: index == -1 &&
                      snapshot.connectionState == ConnectionState.done
                  ? Container()
                  : ClipRRect(
                      child: GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Consumer<NoteManager>(
                                    builder: (context, myModel, child) {
                                  return SizedBox(
                                      height: heightImages,
                                      child: buildImagesView(
                                          images: (myModel
                                                  .findById(widget.note.id)!
                                                  .images ??
                                              [])));
                                }),
                                myModelNote
                                            .findById(widget.note.id)!
                                            .labelImages ==
                                        ''
                                    ? Container()
                                    : SizedBox(
                                        width: double.infinity,
                                        child: Consumer<FontSizeChangnotifier>(
                                          builder: (context, myModel, child) {
                                            return Text(
                                              '${myModelNote.findById(widget.note.id)!.labelImages}',
                                              style: AppStyle.senH4.copyWith(
                                                  fontSize: myModel.labelSize),
                                            );
                                          },
                                        ),
                                      ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Consumer<FontSizeChangnotifier>(
                                    builder: (context, myModel, child) {
                                      return Text(
                                          myModelNote
                                                  .findById(widget.note.id)!
                                                  .content ??
                                              '',
                                          style: AppStyle.senH4.copyWith(
                                              fontSize: myModel.contentSize));
                                    },
                                  ),
                                ),
                                checkExist()
                                    ? Container()
                                    : SizedBox(
                                        height: 26,
                                        child: Consumer<NoteManager>(
                                          builder: (context, myModel, child) {
                                            int index = myModel.notes
                                                .indexWhere((element) =>
                                                    element.id ==
                                                    widget.note.id);
                                            return MasonryGridView.count(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                crossAxisSpacing: 2,
                                                mainAxisSpacing: 10,
                                                crossAxisCount: 1,
                                                itemCount: index != -1
                                                    ? myModel.notes
                                                        .firstWhere((element) =>
                                                            element.id ==
                                                            widget.note.id)
                                                        .label
                                                        ?.length
                                                    : 0,
                                                shrinkWrap: true,
                                                itemBuilder: (ctx, i) =>
                                                    buildLabelView(
                                                        l: context
                                                                .read<
                                                                    LabelManager>()
                                                                .labels[
                                                            widget.note
                                                                .label![i]]));
                                          },
                                        )),
                              ]),
                        ),
                        onTap: () {
                          if (widget.keyCheck == 0) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => DetailNotePage(
                                    note: myModelNote
                                        .findById(widget.note.id)!)));
                          }
                        },
                      ),
                    ),
            );
          });
        });
  }

  setSizeOfMedia() {
    sizeOfHeight = MediaQuery.of(context).size.height;
    sizeOfWidth = MediaQuery.of(context).size.width;
  }

  setSizeOfWidthImage(dynamic file, double sizeParent) {
    widthImagePresenter.widthOfImage(file, sizeParent);
  }

  buildImagesView({required List<String> images}) {
    return Consumer<NoteManager>(builder: (ctx, myModel, child) {
      return MasonryGridView.count(
          scrollDirection: Axis.horizontal,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          crossAxisCount: 1,
          itemCount: myModel.findById(widget.note.id)!.images!.length,
          shrinkWrap: true,
          itemBuilder: (ctx, i) {
            return buildImageView(
                myModel.findById(widget.note.id)!.images![i], i);
          });
    });
  }

  buildImageView(String image, int position) {
    final file = File(image);
    return Consumer<NoteManager>(
      builder: (ctx, myModel, child) {
        return Container(
          height: myModel.findById(widget.note.id)!.images != [] ? 100 : 10,
          width: position >= imagesWidth.length ? 0 : imagesWidth[position],
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              image: DecorationImage(
                  scale: 1, image: FileImage(file), fit: BoxFit.cover)),
        );
      },
    );
  }

  Widget buildLabelView({required String l}) {
    String label = l;
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: AppColor.labelColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          label,
          style: AppStyle.senH5.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  setImageWidthItem() {
    if (widget.note.images!.isNotEmpty) {
      for (int i = 0; i < widget.note.images!.length; i++) {
        String image = widget.note.images![i];
        final file = File(image);
        setSizeOfWidthImage(file, heightImages);
      }
    }
  }

  Future<bool> rebuild() async {
    int index = context
        .read<NoteManager>()
        .notes
        .indexWhere((element) => element.id == widget.note.id);
    if (index != -1) {
      if (!mounted) return false;
      // if there's a current frame,
      if (heightTest == 0 ||
          context.read<NoteManager>().updateHeightId == widget.note.id ||
          context.read<NoteManager>().changeStyle) {
        if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
          // wait for the end of that frame.
          await SchedulerBinding.instance.endOfFrame;
          if (!mounted) return false;
        }
        caculateSize();
      }
    }
    return true;
  }

  void caculateSize() => WidgetsBinding.instance.addPostFrameCallback((_) {
        final RenderBox box =
            keyMiniNote.currentContext!.findRenderObject() as RenderBox;
        setState(() {
          print('update yes');
          sizePinNote = box.size;
          bool add = false;
          if (heightTest == 0) {
            add = true;
          }
          heightTest = sizePinNote.height + 14;
          add
              ? context.read<NoteManager>().addMiniNotesSize(
                  height: heightTest,
                  pin: widget.pin ?? false,
                  id: widget.note.id)
              : context.read<NoteManager>().updateMiniNotesSize(
                  height: heightTest,
                  pin: widget.pin ?? false,
                  id: widget.note.id);

          context.read<NoteManager>().changeStyle = false;
          context.read<NoteManager>().updateHeightId = -1;
        });
      });

  initData() async {
    setImageWidthItem();
    preferences = await SharedPreferences.getInstance();
  }

  checkExist() {
    int index = context
        .read<NoteManager>()
        .notes
        .indexWhere((element) => element.id == widget.note.id);
    if (index != -1) {
      return widget.keyCheck == 0
          ? context
                  .read<NoteManager>()
                  .notes
                  .firstWhere((element) => element.id == widget.note.id)
                  .label
                  ?.isEmpty ??
              false
          : context
                  .read<NoteManager>()
                  .deleteNotes
                  .firstWhere((element) => element.id == widget.note.id)
                  .label
                  ?.isEmpty ??
              false;
    }
    return false;
  }

  @override
  onWidthOfImage(double width) {
    if (mounted) {
      setState(() {
        imagesWidth.add(width);
      });
    }
  }
}
