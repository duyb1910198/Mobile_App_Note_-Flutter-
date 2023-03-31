// ignore: file_names
// ignore_for_file: file_names, duplicate_ignore

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:note/app_path/assets_path.dart';
import 'package:note/page.dart';
import 'package:note/values/fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../values/colors.dart';

class LandingPage extends StatefulWidget {
  static const routeName = '/page_landing';

  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPage createState() => _LandingPage();
}

class _LandingPage extends State<LandingPage> {
  bool granted = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: List.empty());

    if (Platform.isAndroid) {
      requestPermission(Permission.storage);
    }

    return Scaffold(
      backgroundColor: AppColor.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
                flex: 4,
                child: InkWell(
                  onTap: () {},
                  child: Ink(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        image: DecorationImage(
                            image: AssetImage(AssetsPath.imageLogo),
                            fit: BoxFit.fitWidth)),
                  ),
                )),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: RawMaterialButton(
                  highlightColor: AppColor.backgroundColor,
                  shape: const CircleBorder(),
                  fillColor: AppColor.fillColor,
                  onPressed: () {
                    granted
                        ? Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NoteOverviewPage()),
                            (route) => false)
                        : Fluttertoast.showToast(msg: 'Vui lòng cấp quền lưu trữ ở phần cài đặt', toastLength: Toast.LENGTH_LONG);
                  },
                  child: const Icon(
                    Icons.navigate_next,
                    size: 50,
                    color: AppColor.appBarColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      granted = true;
    }
    var result = await permission.request();
    granted = result == PermissionStatus.granted ? true : false;
  }
}
