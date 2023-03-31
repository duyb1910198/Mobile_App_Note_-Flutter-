import 'package:flutter/material.dart';
import 'package:note/app_path/assets_path.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';
import 'package:note/widget/list_view/custom_list_view.dart';

import 'note.dart';

class NoteGridTile extends StatelessWidget {
  final Note note;

  const NoteGridTile(this.note, {super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: buildGridFooterBar(context),
        child: GestureDetector(
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(note.backgroundImage ?? AssetsPath.empty1),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only( top: 8.0, bottom: 26, left: 8, right: 8),
              child: Text(
                note.content ?? '',
                style: AppStyle.senH4,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
          onTap: () {
            // Navigator.of(context).pushNamed(
            //   ProductDetailScreen.routeName,
            //   arguments: product.id,
            // );
          },
        ),
      ),
    );
  }

  Widget buildGridFooterBar(BuildContext context) {
    return GridTileBar(
      leading: IconButton(
        icon: const Icon(
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
        color: Theme.of(context).colorScheme.secondary,
        onPressed: () {},
      ),
      title: SizedBox(
          height: 24,
          child: CustomListView(
            labels: note.label,
          )),
    );
  }
}
