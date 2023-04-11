import 'package:flutter/material.dart';
import 'package:note/models/animation_model.dart';
import 'package:note/values/colors.dart';
import 'package:note/values/fonts.dart';
import 'package:provider/provider.dart';

class AnimatedFloatButtonBar extends StatefulWidget {
  final String textFirstButton;
  final String textSecondButton;
  final IconData firstButton;
  final IconData secondButton;
  final int duration;
  final double size;
  final VoidCallback ontapFirstButton;
  final VoidCallback ontapSecondButton;

  AnimatedFloatButtonBar(
      {required this.textFirstButton,
      required this.textSecondButton,
      required this.firstButton,
      required this.secondButton,
      required this.duration,
      required this.size,
      required this.ontapFirstButton,
      required this.ontapSecondButton});

  @override
  AnimatedFloatButtonBarState createState() => AnimatedFloatButtonBarState();
}

class AnimatedFloatButtonBarState extends State<AnimatedFloatButtonBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimationModel>(builder: (context, myModel, child) {
      return AnimatedContainer(
        duration: Duration(milliseconds: widget.duration),
        height: 50,
        width: myModel.animation ? widget.size : 0,
        decoration: const BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.all(Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                offset: Offset(1, 2),
                blurRadius: 2,
              )
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              visible: !context.read<AnimationModel>().delay &&
                  context.read<AnimationModel>().animation,
              child: MaterialButton(
                onPressed: () async {
                  context.read<AnimationModel>().changeAnimation(value: false);
                  Future.delayed(Duration(milliseconds: widget.duration + 1),
                      () {
                    widget.ontapFirstButton();
                    context.read<AnimationModel>().setNotePress(id: -1);
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.firstButton),
                    Flexible(
                        child: Text(widget.textFirstButton,
                            style: AppStyle.senH6
                                .copyWith(fontWeight: FontWeight.w400))),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: !context.read<AnimationModel>().delay &&
                  context.read<AnimationModel>().animation,
              child: MaterialButton(
                onPressed: () async {
                  context.read<AnimationModel>().changeAnimation(value: false);
                  Future.delayed(Duration(milliseconds: widget.duration + 1),
                      () {
                    widget.ontapSecondButton();
                    context.read<AnimationModel>().setNotePress(id: -1);
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.secondButton),
                    Text(
                      widget.textSecondButton,
                      style:
                          AppStyle.senH6.copyWith(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
