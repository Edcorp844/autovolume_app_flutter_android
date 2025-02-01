import 'package:flutter/material.dart';

extension CustomUIFunction on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color? get textColor => Theme.of(this).textTheme.bodyLarge?.color;
  Color? get navColor => Theme.of(this).bottomNavigationBarTheme.backgroundColor;
  Color? get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
}
