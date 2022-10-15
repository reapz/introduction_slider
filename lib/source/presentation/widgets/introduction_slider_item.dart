import 'package:flutter/material.dart';
import './widgets.dart';

class IntroductionSliderItem {
  /// Logo of the introduction slider.
  final Widget child;

  /// Background color of the introduction slider.
  final Color? backgroundColor;

  /// Gradient background of the introduction slider.
  final Gradient? gradient;

  const IntroductionSliderItem({
    required this.child,
    this.backgroundColor,
    this.gradient,
  });
}
