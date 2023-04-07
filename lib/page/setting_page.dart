import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note/models/font_size_change_notifier.dart';
import 'package:note/presenter/media_size_presenter.dart';
import 'package:note/presenter_view/media_size_view.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';
import 'package:note/values/share_keys.dart';
import 'package:note/widget/app_drawer/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> implements MediaSizeView {
  late SharedPreferences preferences;
  double sizeOfHeight = 0;
  double sizeOfWidth = 0;
  double sliderValueLabel = 25;
  double sliderValueContent = 18;
  late MediaSizePresenter mediaSizePresenter;


  _SettingPageState() {
    mediaSizePresenter = MediaSizePresenter();
    mediaSizePresenter.attachView(this);
  }


  @override
  void initState() {
    super.initState();
    initPreference();
  }

  void initPreference() async {
    preferences = await SharedPreferences.getInstance();
    int sizeLabel = preferences.getInt(ShareKey.sizeLabel) ?? 25;
    int sizeContent = preferences.getInt(ShareKey.sizeContent) ?? 18;
    setState(() {
      sliderValueLabel = sizeLabel.toDouble();
      sliderValueContent = sizeContent.toDouble();
    });
    setSizeOfMedia();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: List.empty());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cài đặt',
          style: AppStyle.senH4.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColor.appBarColor,
        leading: InkWell(
          onTap: () async {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: buildBodyLayout(),
      drawer: const AppDrawer(),
    );
  }

  Widget buildBodyLayout() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            height: sizeOfHeight * 0.15,
            child: buildSlierText(text: 'Cỡ tiêu đề: ', sliderValue: 0),
          ),
          SizedBox(
            height: sizeOfHeight * 0.15,
            child: buildSlierText(text: 'Cỡ chữ: ', sliderValue: 1),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  buildSlierText({required String text, required int sliderValue}) {
    return Consumer<FontSizeChangnotifier>(builder: (ctx, myModel, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                text,
                style: AppStyle.senH4.copyWith(fontWeight: FontWeight.w400),
              ),
              Text(
                '${(sliderValue == 0) ? sliderValueLabel.toInt() : sliderValueContent.toInt()}',
                style: AppStyle.senH4.copyWith(
                    fontWeight: FontWeight.w400, color: AppColor.deepRedColor),
              ),
            ],
          ),
          Slider(
            value: (sliderValue == 0) ? sliderValueLabel : sliderValueContent,
            min: 10,
            max: 100,
            divisions: 100,
            activeColor: AppColor.appBarColor,
            inactiveColor: AppColor.selectButtonColor,
            onChanged: (value) async {
              double contentSize = myModel.contentSize;
              double labelSize = myModel.labelSize;
              if (sliderValue == 0) {
                labelSize = value;
              } else {
                contentSize = value;
              }
              await context.read<FontSizeChangnotifier>().changeFontSize(
                  labelSize: labelSize, contentSize: contentSize);

              setState(() {
                sliderValueLabel = myModel.labelSize;
                sliderValueContent = myModel.contentSize;
              });

              await preferences.setInt(
                  ShareKey.sizeLabel, myModel.labelSize.toInt());
              await preferences.setInt(
                  ShareKey.sizeContent, myModel.contentSize.toInt());
              context.read<FontSizeChangnotifier>().changeFontSize(
                  labelSize: sliderValueLabel, contentSize: sliderValueContent);
            },
          ),
        ],
      );
    });
  }

  setSizeOfMedia() {
    mediaSizePresenter.getMediaSize(context);
  }

  @override
  onGetMediaSize(Size size) {
    setState(() {
      sizeOfHeight = size.height;
      sizeOfWidth = size.width;
    });
  }
}
