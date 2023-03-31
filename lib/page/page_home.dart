// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:note/models/image_love.dart';
import 'package:note/packages/love/love.dart';
import 'package:note/values/colors.dart';
import 'package:note/widget/app_drawer/app_drawer.dart';

import '../values/fonts.dart';

class HomePage extends StatefulWidget{
  static const routeName = '/page_home';
  const HomePage  ({Key ? key}) : super(key : key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends  State<HomePage>{

  int _currentIndex = 0;
  int _select       = 1;
  late PageController _pageController = PageController();
  List<LoveImage> loveImages = [];

  @override
  void initState() {
    getListImage();
    loveImages[2];
    _pageController = PageController(viewportFraction: 0.9);  // width size of card
  }

  List<int> getIDList() {
    Random random = Random();
    List<int> list = [];

    int value = 0;
    while( list.length < 5) {
      value = random.nextInt(42);
      if ( !list.contains(value)) {
        list.add(value);
      }
    }
    return list;
  }


  getListImage() {
    setState(() {
      List<LoveImage> listImage = [];
      List<int> listID = getIDList();
      listID.forEach((element) {
        listImage.add(Loves.datas[element]);
      });
      loveImages.clear();
      loveImages.addAll(listImage);
    });
  }



  selected( int select){
    setState(() {
      _select = select;
    });
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return  Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        title: Text(
          'My Love',
          style: AppStyle.senH4.copyWith( color: Colors.white),
        ),
        backgroundColor: AppColor.appBarColor,
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              height: size.height * 1 / 10,
              alignment: Alignment.center,
              child: Text(
                'Love you forever Thuy',
                style: AppStyle.zeyadaH3,
              ),
            ),
            Container(
              height: size.height * 0.75,
              child: PageView.builder(
                itemCount: 5,
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(top: 15, bottom: 15,left: 8),
                    decoration: BoxDecoration(
                      color: AppColor.black,
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      image: DecorationImage(
                        image: AssetImage('${loveImages.elementAt(index).image}'),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          offset:  Offset(3, 6),
                          blurRadius:  3,
                        ),
                      ]
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(FontAwesomeIcons.heart, color: Colors.white,size: 40,)
                        ],
                      ),
                    )
                  );
                }),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              height: 12,
              margin: const EdgeInsets.only(left: 25),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: NeverScrollableScrollPhysics(),  // in case a lot of elemnt ( or over size) list never can scroll
                itemCount: 5,
                itemBuilder: (context, index) {
                  return  buildIndicator( index == _currentIndex, size);
                }
              ),
            )

          ],
        ),
      ),
      drawer: AppDrawer(),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getListImage();
        },
        backgroundColor: AppColor.appBarColor,
        child: Icon(Icons.refresh_outlined),
      ),
    );
  }

  Widget  buildIndicator( bool isActive, Size size) {

    return  Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: isActive ? size.width * 1/6 : 12,
      decoration: BoxDecoration(
        color: isActive ? AppColor.appBarColor : AppColor.deepRedColor,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset:  Offset(2,3),
            blurRadius:  3,
          )
        ]
      ),
    );
  }
}