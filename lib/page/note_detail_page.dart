import 'dart:async';
import 'dart:io';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note/app_path/assets_path.dart';
import 'package:note/manager/background_colors_manager.dart';
import 'package:note/models/check_box.dart';
import 'package:note/models/font_size_change_notifier.dart';
import 'package:note/models/label_manager.dart';
import 'package:note/models/note.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/presenter/media_size_presenter.dart';
import 'package:note/presenter/width_image_presenter.dart';
import 'package:note/presenter_view/media_size_view.dart';
import 'package:note/presenter_view/width_image_view.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';
import 'package:note/values/share_keys.dart';
import 'package:note/widget/app_button/icon_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../manager/background_manager.dart';

class DetailNotePage extends StatefulWidget {
  Note notes;

  DetailNotePage({required this.notes, super.key});

  TextEditingController controllerLabelImage = TextEditingController();
  TextEditingController controllerContent = TextEditingController();

  @override
  _DetailNotePageState createState() => _DetailNotePageState();
}

class _DetailNotePageState extends State<DetailNotePage> implements MediaSizeView,WidthImageView {
  late int imagesSize;
  bool? check = false;
  double sizeOfHeight = 0;
  double sizeOfWidth = 0;
  late SharedPreferences preferences;
  int labelSize = 25;
  int contentSize = 18;
  double w = 0;
  double imageHeight = 300;
  List<String> imageWidth = [];
  List<double> imagesWidth = [];
  List<CheckBoxModal> checkBoxModals = [];
  bool updateHeight = false;
  late MediaSizePresenter mediaSizePresenter;
  late WidthImagePresenter widthImagePresenter;

  _DetailNotePageState() {
    mediaSizePresenter = MediaSizePresenter();
    mediaSizePresenter.attachView(this);
    widthImagePresenter = WidthImagePresenter();
    widthImagePresenter.attachView(this);
  }

  Note get note => widget.notes;

  @override
  void initState() {
    super.initState();
    widget.controllerContent.text = widget.notes.content ?? '';
    widget.controllerContent.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.controllerContent.text.length));
    widget.controllerLabelImage.text = widget.notes.labelImages ?? '';
    widget.controllerLabelImage.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.controllerLabelImage.text.length));
  }

  initData() {
    setPreference();
    imagesSize = widget.notes.images!.length;
    setImageWidthItem();
    setSizeOfMedia();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: List.empty());
    return FutureBuilder(
      future: initData(),
      builder: (context, snapshot) {
        return WillPopScope(
          onWillPop: isBackPreviousPage,
          child: Scaffold(
            body: DecoratedBox(
              decoration: BoxDecoration(
                  color:
                      Color(widget.notes.backgroundColor ?? ShareKey.white),
                  image: DecorationImage(
                      image: AssetImage(
                          widget.notes.backgroundImage ?? AssetsPath.empty1),
                      fit: BoxFit.cover)),
              child: SizedBox(
                  height: sizeOfHeight,
                  width: sizeOfWidth,
                  child: buildDetailNoteLayout(
                    size: imagesSize,
                    images: widget.notes.images ?? [],
                  )),
            ),
            // buildBodyLayout(
            //   size: imagesSize, images: images,),
            // bottomNavigationBar: buildBottomAppBar(),
          ),
        );
      },
    );
  }

  //Build Widget Part

  buildDetailNoteLayout({required int size, required List<String> images}) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildAppBarLayout(),
          buildBodyLayout(images: images, size: size),
          buildBottomAppBar(),
        ],
      ),
    );
  }

  Widget buildAppBarLayout() {
    return SizedBox(
      height: sizeOfHeight * 0.1,
      width: sizeOfWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildBackIcon(),
          Row(
            children: [buildPinIcon()],
          )
        ],
      ),
    );
  }

  buildBodyLayout({required List<String> images, required int size}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: sizeOfHeight * 0.8,
        width: sizeOfWidth,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                widget.notes.images!.isNotEmpty
                    ? Container(
                        height: imageHeight,
                        child: buildImagesView(images: images, size: size),
                      )
                    : Container(),
                Consumer<FontSizeChangnotifier>(
                  builder: (context, myModel, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: AppColor.labelImageColor,
                      child: TextField(
                        style:
                            AppStyle.senH4.copyWith(fontSize: myModel.labelSize),
                        controller: widget.controllerLabelImage,
                        onChanged: (value) {
                          setState(() {
                            widget.notes.labelImages =
                                widget.controllerLabelImage.text;
                            context
                                .read<NoteManager>()
                                .setUpdateHeight(id: widget.notes.id);
                          });
                        },
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Nhãn',
                          focusColor: AppColor.appBarColor,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    );
                  },
                ),
                Consumer<FontSizeChangnotifier>(
                  builder: (context, myModel, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          style: AppStyle.senH5
                              .copyWith(fontSize: myModel.contentSize),
                          controller: widget.controllerContent,
                          onChanged: (value) {
                            setState(() {
                              widget.notes.content =
                                  widget.controllerContent.text;
                              context
                                  .read<NoteManager>()
                                  .setUpdateHeight(id: widget.notes.id);
                            });
                          },
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'Ghi chú',
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                        SizedBox(
                            height: 26,
                            child: Consumer<NoteManager>(
                              builder: (context, myModel, child) {
                                int index = myModel.notes.indexWhere(
                                    (element) => element.id == widget.notes.id);
                                // print('leng is: ${index != -1 ? myModel.notes.firstWhere((element) => element.id == widget.notes.id).label?.length : 0}');
                                return MasonryGridView.count(
                                    scrollDirection: Axis.horizontal,
                                    crossAxisSpacing: 2,
                                    mainAxisSpacing: 10,
                                    crossAxisCount: 1,
                                    itemCount: index != -1
                                        ? myModel.notes
                                            .firstWhere((element) =>
                                                element.id == widget.notes.id)
                                            .label
                                            ?.length
                                        : 0,
                                    shrinkWrap: true,
                                    itemBuilder: (ctx, i) => buildLabelView(
                                        l: context
                                            .read<LabelManager>()
                                            .labels[widget.notes.label![i]]));
                              },
                            )),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildBottomAppBar() {
    return SizedBox(
      height: sizeOfHeight * 0.1,
      width: sizeOfWidth,
      child: DecoratedBox(
        decoration: const BoxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    buildAddImageIcon(), //palette
                    buildSetBackgroundIcon(),
                  ],
                ),
              ],
            ),
            Expanded(child: Container()),
            buildToolIcon(),
          ],
        ),
      ),
    );
  }

  Widget buildBackIcon() {
    return MaterialButton(
      onPressed: () {
        backPreviousPage();
      },
      minWidth: 20,
      child: const Icon(
        Icons.arrow_back_rounded,
        color: AppColor.graylight,
      ),
    );
  }

  Widget buildPinIcon() {
    return IconButton(
      icon: widget.notes.pin
          ? const Icon(CommunityMaterialIcons.pin)
          : const Icon(CommunityMaterialIcons.pin_outline),
      onPressed: () {
        setState(() {
          widget.notes.pin = !widget.notes.pin;
        });
      },
      color: AppColor.graylight,
    );
  }

  Widget buildAddImageIcon() {
    return IconButton(
      icon: const Icon(Icons.add_box_outlined),
      onPressed: () {
        buildBottomSheet();
      },
      color: AppColor.graylight,
    );
  }

  Widget buildSetBackgroundIcon() {
    return IconButton(
      icon: const Icon(Icons.palette_outlined),
      onPressed: () {
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: sizeOfHeight * 0.4,
                child: Column(
                  children: [
                    SizedBox(
                      height: sizeOfHeight * 0.2,
                      width: double.maxFinite,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: AppColor.appBarColor,
                        ),
                        child: buildOptionBackground(
                            label: 'Màu',
                            list: BackgroundColorsManager.backgroundColor,
                            size: sizeOfHeight * 0.08),
                      ),
                    ),
                    SizedBox(
                      height: sizeOfHeight * 0.2,
                      width: double.maxFinite,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: AppColor.appBarColor,
                        ),
                        child: buildOptionBackground(
                            label: 'Ảnh',
                            list: BackgroundImagesManager.backgroundImages,
                            size: sizeOfHeight * 0.1),
                      ),
                    ),
                  ],
                ),
              );
            });
      },
      color: AppColor.graylight,
    );
  }

  Widget buildToolIcon() {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: sizeOfHeight * 0.2,
                child: Column(
                  children: <Widget>[
                    IconTextButton(
                        label: 'Xoá',
                        onTap: () {
                          showMessage(mess: 'Xoá');
                          deleteNote();
                          Navigator.pop(context);
                        },
                        icon: Icons.delete_outline,
                        size: sizeOfHeight * 0.1),
                    IconTextButton(
                        label: 'Nhãn',
                        onTap: () {
                          showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(// this is new
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                  return SingleChildScrollView(
                                      child: SizedBox(
                                          height: sizeOfHeight * 0.6,
                                          child: MasonryGridView.count(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              crossAxisSpacing: 2,
                                              mainAxisSpacing: 2,
                                              crossAxisCount: 1,
                                              itemCount: context
                                                  .read<LabelManager>()
                                                  .labels
                                                  .length,
                                              shrinkWrap: true,
                                              itemBuilder: (ctx, i) {
                                                int index = widget.notes.label!
                                                    .indexWhere((element) =>
                                                        element == i);
                                                CheckBoxModal checkBoxModal =
                                                    CheckBoxModal(
                                                        title: context
                                                            .read<
                                                                LabelManager>()
                                                            .labels[i],
                                                        check: index == -1
                                                            ? false
                                                            : true);
                                                checkBoxModals
                                                    .add(checkBoxModal);
                                                return SizedBox(
                                                    height: 40,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: <Widget>[
                                                        checkBoxModals[i].check
                                                            ? const Icon(
                                                                Icons.label)
                                                            : const Icon(Icons
                                                                .label_outline),
                                                        Expanded(
                                                          child:
                                                              CheckboxListTile(
                                                            title: Text(
                                                                checkBoxModals[
                                                                        i]
                                                                    .title),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                checkBoxModals[
                                                                            i]
                                                                        .check =
                                                                    value ??
                                                                        false;
                                                                if (value ??
                                                                    false) {
                                                                  widget.notes
                                                                      .label!
                                                                      .add(i);
                                                                  context
                                                                      .read<
                                                                          NoteManager>()
                                                                      .updateNote(
                                                                          note:
                                                                              widget.notes);
                                                                } else {
                                                                  widget.notes
                                                                      .label!
                                                                      .remove(
                                                                          i);
                                                                  context
                                                                      .read<
                                                                          NoteManager>()
                                                                      .updateNote(
                                                                          note:
                                                                              widget.notes);
                                                                }
                                                                context
                                                                    .read<
                                                                        NoteManager>()
                                                                    .setUpdateHeight(
                                                                        id: widget
                                                                            .notes
                                                                            .id);
                                                              });
                                                            },
                                                            value:
                                                                checkBoxModals[
                                                                        i]
                                                                    .check,
                                                          ),
                                                        )
                                                      ],
                                                    ));
                                              })));
                                });
                              });
                        },
                        icon: Icons.label,
                        size: sizeOfHeight * 0.1),
                  ],
                ),
              );
            });
      },
      icon: const Icon(FontAwesomeIcons.ellipsisVertical),
      color: AppColor.graylight,
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

  Widget buildOptionBackground(
      {required String label,
      required List<dynamic> list,
      required double size}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 20),
          child: Text(
            label,
            style: AppStyle.senH5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20),
          child: SizedBox(
            height: size,
            child: buildCircleImagesView(images: list, size: size),
          ),
        )
      ],
    );
  }

  void buildBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: sizeOfHeight * 0.2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconTextButton(
                    label: 'Chụp ảnh',
                    onTap: () {
                      _pickImage(source: ImageSource.camera);
                      if (widget.notes.images!.isEmpty) {
                        context
                            .read<NoteManager>()
                            .setUpdateHeight(id: widget.notes.id);
                      }
                    },
                    icon: Icons.camera_alt_outlined,
                    size: sizeOfHeight * 0.1),
                IconTextButton(
                    label: 'Thêm hình ảnh',
                    onTap: () {
                      _pickImage(source: ImageSource.gallery);
                      if (widget.notes.images!.isEmpty) {
                        context
                            .read<NoteManager>()
                            .setUpdateHeight(id: widget.notes.id);
                      }
                    },
                    icon: Icons.image_outlined,
                    size: sizeOfHeight * 0.1),
              ],
            ),
          );
        });
  }

  setSizeOfMedia() {
    mediaSizePresenter.getMediaSize(context);
  }

  setNote({required String file}) {
    setState(() {
      widget.notes.images!.add(file);
    });
    context
        .read<NoteManager>()
        .addNote(note: widget.notes, preferences: preferences, key: 0);
  }

  // set list width of image = width(original image) * height(size of parent widget) / height (original image)
  setSizeOfWidthImage(dynamic file, double sizeParent) {
    widthImagePresenter.widthOfImage(file, sizeParent);
  }

  buildImageView(String image, double size, int position) {
    final file = File(image);
    return Container(
      height: 300,
      width: position >= imagesWidth.length ? 0 : imagesWidth[position],
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          image: DecorationImage(
              scale: 1, image: FileImage(file), fit: BoxFit.cover)),
    );
  }

  buildImagesView({required List<String> images, required int size}) {
    return MasonryGridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
      crossAxisCount: 1,
      itemCount: size,
      shrinkWrap: true,
      itemBuilder: (ctx, i) => buildImageView(images[i], 300, i),
    );
  }

  buildCircleImageView(dynamic image, double size) {
    bool type = (image.runtimeType == String) ? true : false;
    return SizedBox(
        width: size,
        child: InkWell(
          onTap: () {
            setState(() {
              if (type) {
                if (image != AssetsPath.empty) {
                  if (widget.notes.backgroundImage != image) {
                    widget.notes.backgroundImage = image;
                  }
                } else {
                  widget.notes.backgroundImage = null;
                }
              } else if (widget.notes.backgroundColor != image) {
                widget.notes.backgroundColor = image;
              }
            });
          },
          child: CircleAvatar(
            backgroundImage: type ? AssetImage(image) : null,
            backgroundColor: !type ? Color(image) : AppColor.white,
          ),
        ));
  }

  buildCircleImagesView({required List<dynamic> images, required double size}) {
    return MasonryGridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisSpacing: 2,
      mainAxisSpacing: 20,
      crossAxisCount: 1,
      itemCount: images.length,
      shrinkWrap: true,
      itemBuilder: (ctx, i) => buildCircleImageView(images[i], size),
    );
  }

  _pickImage({required source}) async {
    XFile? xFile = await ImagePicker().pickImage(source: source);
    if (xFile == null) {
      return;
    } else {
      final file = File(xFile.path);
      await setSizeOfWidthImage(file, imageHeight);
      double width = w;
      imagesWidth.add(width);
      setNote(file: xFile.path);
    }
  }

  showMessage({required String mess}) {}

  void setPreference() async {
    preferences = await SharedPreferences.getInstance();
    labelSize = preferences.getInt(ShareKey.sizeLabel) ?? 25;
    contentSize = preferences.getInt(ShareKey.sizeContent) ?? 18;
  }

  void setNotePreference() {
    context
        .read<NoteManager>()
        .addNote(note: widget.notes, preferences: preferences, key: 0);
  }

  deleteNote() {
    if (context.read<NoteManager>().existNote(id: widget.notes.id)) {
      context
          .read<NoteManager>()
          .removeNote(id: widget.notes.id, preferences: preferences, key: 0);
    }
    Navigator.pop(context);
  }

  chooseLabel({required position}) {}

  void setImageWidthItem() {
    imagesWidth.clear();
    if (widget.notes.images!.isNotEmpty) {
      for (int i = 0; i < widget.notes.images!.length; i++) {
        String image = widget.notes.images![i];
        final file = File(image);
        setSizeOfWidthImage(file, imageHeight);
      }
    }
  }

  backPreviousPage()  {
    if (widget.notes.isVaild(note: widget.notes)) {
      setNotePreference();
      context.read<NoteManager>().setPinNotes();
      Navigator.pop(context);
    } else {
      deleteNote();
    }
  }

  Future<bool> isBackPreviousPage() async {
    if (widget.notes.isVaild(note: widget.notes)) {
      setNotePreference();
      context.read<NoteManager>().setPinNotes();
      Navigator.pop(context);
    } else {
      deleteNote();
    }
    return true;
  }

  @override
  onGetMediaSize(Size size) {
    setState(() {
      sizeOfHeight = size.height;
      sizeOfWidth = size.width;
    });
  }

  @override
  onWidthOfImage(double width) {
    setState(() {
      imagesWidth.add(width);
    });
  }
}
