import 'package:another_xlider/enums/hatch_mark_alignment_enum.dart';
import 'package:another_xlider/models/hatch_mark_label.dart';
import 'package:another_xlider/widgets/sized_box.dart';

class FlutterSliderHatchMark {
  bool disabled;
  double density;
  double? linesDistanceFromTrackBar;
  double? labelsDistanceFromTrackBar;
  List<FlutterSliderHatchMarkLabel>? labels;
  FlutterSliderSizedBox? smallLine;
  FlutterSliderSizedBox? bigLine;

  /// How many small lines to display between two big lines
  int smallDensity;
  FlutterSliderSizedBox? labelBox;
  FlutterSliderHatchMarkAlignment linesAlignment;
  bool? displayLines;

  FlutterSliderHatchMark(
      {this.disabled = false,
      this.density = 1,
      this.smallDensity = 4,
      this.linesDistanceFromTrackBar,
      this.labelsDistanceFromTrackBar,
      this.labels,
      this.smallLine,
      this.bigLine,
      this.linesAlignment = FlutterSliderHatchMarkAlignment.right,
      this.labelBox,
      this.displayLines})
      : assert(density > 0 && density <= 2),
        assert(smallDensity >= 0);

  @override
  String toString() {
    return '$disabled-$density-$linesDistanceFromTrackBar-$labelsDistanceFromTrackBar-$labels-$smallLine-$bigLine-$labelBox-$linesAlignment-$displayLines';
  }
}
