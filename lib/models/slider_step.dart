import 'package:another_xlider/models/range_step.dart';

class FlutterSliderStep {
  final double step;
  final bool isPercentRange;
  final List<FlutterSliderRangeStep>? rangeList;

  const FlutterSliderStep({
    this.step = 1,
    this.isPercentRange = true,
    this.rangeList,
  });

  @override
  String toString() {
    return '$step-$isPercentRange-$rangeList';
  }
}
