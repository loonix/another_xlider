import 'package:flutter/material.dart';

class FlutterSliderHatchMarkLabel {
  final double? percent;
  final Widget? label;

  FlutterSliderHatchMarkLabel({
    this.percent,
    this.label,
  }) : assert((label == null && percent == null) || (label != null && percent != null && percent >= 0));

  @override
  String toString() {
    return '$percent-$label';
  }
}
