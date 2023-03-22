import 'package:flutter/material.dart';

class FlutterSliderHandler {
  /// The widget to place inside the handler.
  Widget? child;

  /// The decoration to paint behind the handler.
  BoxDecoration? decoration;

  /// The decoration to paint in front of the handler.
  BoxDecoration? foregroundDecoration;

  /// The transform to apply to the handler.
  Matrix4? transform;

  /// Whether the handler is disabled.
  bool disabled;

  /// The opacity to apply to the handler.
  double opacity;

  FlutterSliderHandler({
    this.child,
    this.decoration,
    this.foregroundDecoration,
    this.transform,
    this.disabled = false,
    this.opacity = 1,
  });

  @override
  String toString() {
    return '$child-$disabled-$decoration-$foregroundDecoration-$transform-$opacity';
  }
}
