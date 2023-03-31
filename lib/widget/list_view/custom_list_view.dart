
import 'package:flutter/cupertino.dart';
import 'package:note/widget/decorated_box/decorateted_box.dart';

class CustomListView extends StatefulWidget {

  final List<int>? labels;
  const CustomListView({super.key, this.labels});

  @override
  _CustomListViewState createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {
  @override
  Widget build(BuildContext context) {

    List<int> labels = widget.labels ?? [];
    int size = labels.length;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: size,
      itemBuilder: (context, i) => CustomDecoratedBox( label: labels[i],)
    );
  }


}