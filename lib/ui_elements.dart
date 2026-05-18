import 'package:flutter/material.dart';

class RoundedElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double rounding;
  final double width;
  final double height;
  final Color? color;

  const RoundedElevatedButton(this.onPressed, this.child, this.rounding, this.width, this.height, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(rounding))),
            fixedSize: Size(width, height)
        ),
        child: child
    );
  }
}

class EasyText extends StatelessWidget {
  final String? text;
  final double size;
  final Color? color;

  const EasyText(this.text, this.size, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
        text!,
        style: TextStyle(
            fontSize: size,
            color: color
        )
    );
  }
}