
import 'package:flutter/material.dart';
import 'package:note/models/animation_model.dart';
import 'package:note/models/font_size_change_notifier.dart';
import 'package:note/models/label_manager.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/models/route_manager.dart';
import 'package:note/page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Loves.datas.forEach((element) {
  //   print(element.image);
  // });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => NoteManager()),
        ChangeNotifierProvider(create: (ctx) => LabelManager()),
        ChangeNotifierProvider(create: (ctx) => FontSizeChangnotifier()),
        ChangeNotifierProvider(create: (ctx) => RouteManager()),
        ChangeNotifierProvider(create: (ctx) => AnimationModel()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home:  const LandingPage(),
        routes: {
          LandingPage.routeName:
            (ctx) => const LandingPage(),
          NoteOverviewPage.routeName:
            (ctx) => const NoteOverviewPage(),
          LabelsPage.routeName:
              (ctx) => const LabelsPage(),
          NoteRecycleBinPage.routeName:
              (ctx) => const NoteRecycleBinPage(),
        },
      ),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//
//   static double  deviceWidth = 0;
//   late double _imageWidth;
//
//   void _changeSizeImage() {
//     setState(() {
//       _imageWidth = (_imageWidth >= deviceWidth) ? 100.0 : deviceWidth;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//
//       deviceWidth  = ( deviceWidth >= MediaQuery.of(context).size.width) ? 200 : MediaQuery.of(context).size.width;
//       _imageWidth  = deviceWidth;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         leading: IconButton(
//           icon: const Icon(Icons.account_circle_sharp),
//           onPressed: () {
//             _changeSizeImage();
//           },
//         ),
//       ),
//       body:  Center(
//           child: Column (
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Text.rich(
//                 TextSpan(
//                   text: 'Yeu Nguyen Thi Thanh Thuy',
//                   style: GoogleFonts.zeyada(fontSize: 35, fontWeight: FontWeight.w900),
//                 ),
//               ),
//               Image(
//                 image:  AssetImage(AssetsPath.imageLove),
//                 width:  _imageWidth,
//               ),
//             ],
//           )
//       ),
//     );
//   }
// }
