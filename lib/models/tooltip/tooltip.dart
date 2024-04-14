import 'package:another_xlider/enums/tooltip_direction_enum.dart';
import 'package:another_xlider/models/tooltip/tooltip_box.dart';
import 'package:another_xlider/models/tooltip/tooltip_position_offset.dart';
import 'package:flutter/material.dart';

class FlutterSliderTooltip {
  Widget Function(dynamic value, String? size)? custom;
  String Function(String value)? format;
  TextStyle? textStyle;
  FlutterSliderTooltipBox? boxStyle;
  Widget? leftPrefix;
  Widget? leftSuffix;
  Widget? rightPrefix;
  Widget? rightSuffix;
  bool? alwaysShowTooltip;
  bool? disabled;
  bool? disableAnimation;
  FlutterSliderTooltipDirection? direction;
  FlutterSliderTooltipPositionOffset? positionOffset;

  FlutterSliderTooltip({
    this.custom,
    this.format,
    this.textStyle,
    this.boxStyle,
    this.leftPrefix,
    this.leftSuffix,
    this.rightPrefix,
    this.rightSuffix,
    this.alwaysShowTooltip,
    this.disableAnimation,
    this.disabled,
    this.direction,
    this.positionOffset,
  });

  @override
  String toString() {
    return '$textStyle-$boxStyle-$leftPrefix-$leftSuffix-$rightPrefix-$rightSuffix-$alwaysShowTooltip-$disabled-$disableAnimation-$direction-$positionOffset';
  }
}
