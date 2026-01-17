import 'package:flutter/material.dart';
import 'package:open_mask/ui/widgets/blue_text_button.dart';

class StretchedButton extends StatelessWidget {
  const StretchedButton(this.text, this.onPressed, this.widthPercent,
      {super.key});

  final String text;
  final void Function()? onPressed;
  final double widthPercent;

  @override
  Widget build(final BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthPercent,
      child: BlueTextButton(
        text,
        onPressed: onPressed,
        stretch: true,
      ),
    );
  }
}
