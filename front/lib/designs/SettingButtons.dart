import 'package:flutter/material.dart';

class SettingButtons extends StatelessWidget {
  final String? buttonText;
  final VoidCallback onPressed;
  final TextStyle? textStyle;
  final double? fontSize;

  const SettingButtons({
    required this.onPressed,
    this.buttonText,
    this.textStyle,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        buttonText ?? '', // buttonText가 null이면 빈 문자열 출력
        style: textStyle?.copyWith(fontSize: fontSize) ?? TextStyle(fontSize: fontSize ?? 16.0),
      ),
    );
  }
}
