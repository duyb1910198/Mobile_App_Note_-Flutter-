import 'package:flutter/material.dart';
import 'package:note/app_path/assets_path.dart';
import 'package:note/models/note.dart';
import 'package:note/models/note_manager.dart';
import 'package:note/page/note_detail_page.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';
import 'package:note/widget/list_view/custom_list_view.dart';
import 'package:provider/provider.dart';

class NoteStaggedTile extends StatelessWidget {
  final Note note;

  const NoteStaggedTile(this.note, {super.key});

  @override
  Widget build(BuildContext context) {
    List<int> labels = note.label ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Color(note.backgroundColor! ?? 0xffffffff) ?? AppColor.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: AppColor.black,
            offset: Offset(2, 3),
            blurRadius: 10,
          )
        ],
        image: DecorationImage(
            image: AssetImage(note.backgroundImage ?? AssetsPath.empty),
            fit: BoxFit.cover),
      ),
      child: ClipRRect(
        child: GestureDetector(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<NoteManager>(
                    builder: (context, myModel, child) {
                  return Text(
                    note.labelImages ?? '',
                    style: AppStyle.senH4,
                  );
                }),
                Consumer<NoteManager>(
                    builder: (context, myModel, child) {
                  return Text(
                    note.content ?? '',
                    style: AppStyle.senH4,
                  );
                }),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.stars,
                      color: AppColor.white,
                      shadows: [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(2, 3),
                          blurRadius: 3,
                        )
                      ],
                    ),
                    Flexible(
                      child: SizedBox(
                          height: 24,
                          width: double.maxFinite,
                          child: CustomListView(
                            labels: labels,
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DetailNotePage(notes: note)));
          },
        ),
      ),
    );
  }

  Widget buildStaggedFooterBar(BuildContext context) {
    return GridTileBar(
      leading: IconButton(
        icon: const Icon(
          Icons.stars,
          color: AppColor.white,
          shadows: [
            BoxShadow(
              color: AppColor.black,
              offset: Offset(2, 3),
              blurRadius: 3,
            )
          ],
        ),
        color: Theme.of(context).colorScheme.secondary,
        onPressed: () {},
      ),
      title: DecoratedBox(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: AppColor.appBarColor),
        child: Container(
          padding: const EdgeInsets.all(2),
          child: Text(
            'HAD LOVE THUY',
            style: AppStyle.blackHanSansH5.copyWith(color: AppColor.white),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
