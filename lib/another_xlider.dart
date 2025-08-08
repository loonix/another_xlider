/// A material design slider and range slider with horizontal and vertical axis, rtl support and lots of options and customizations for flutter

/*
* *
* * Initially written by Ali Azmoude <ali.azmoude@gmail.com>
* * Refactored by loonix and the internet :)
* *
* *
* * When he wrote this, only God and him understood what he was doing.
* * Now, God only knows "Karl Weierstrass"
* */

import 'package:another_xlider/enums/hatch_mark_alignment_enum.dart';
import 'package:another_xlider/enums/tooltip_direction_enum.dart';
import 'package:another_xlider/models/fixed_value.dart';
import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/handler_animation.dart';
import 'package:another_xlider/models/hatch_mark.dart';
import 'package:another_xlider/models/hatch_mark_label.dart';
import 'package:another_xlider/models/ignore_steps.dart';
import 'package:another_xlider/models/range_step.dart';
import 'package:another_xlider/models/slider_step.dart';
import 'package:another_xlider/models/tooltip/tooltip.dart';
import 'package:another_xlider/models/tooltip/tooltip_box.dart';
import 'package:another_xlider/models/trackbar.dart';
import 'package:another_xlider/widgets/make_handler.dart';
import 'package:another_xlider/widgets/sized_box.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class FlutterSlider extends StatefulWidget {
  /// The axis on which the slider should be displayed. Can be either vertical or horizontal.
  final Axis axis;

  /// The width of the slider handler.
  final double? handlerWidth;

  /// The height of the slider handler.
  final double? handlerHeight;

  /// The custom handler widget to use for the left handler.
  final FlutterSliderHandler? handler;

  /// The custom handler widget to use for the right handler, if this is a range slider.
  final FlutterSliderHandler? rightHandler;

  /// Callback function that is called when the user starts dragging one of the handlers.
  final Function(int handlerIndex, dynamic lowerValue, dynamic upperValue)? onDragStarted;

  /// Callback function that is called when the user stops dragging one of the handlers.
  final Function(int handlerIndex, dynamic lowerValue, dynamic upperValue)? onDragCompleted;

  /// Callback function that is called while the user is dragging one of the handlers.
  final Function(int handlerIndex, dynamic lowerValue, dynamic upperValue)? onDragging;

  /// The minimum value that can be selected on the slider.
  final double? min;

  /// The maximum value that can be selected on the slider.
  final double? max;

  /// The initial values for the slider handles. If the slider is a range slider, this should be a list with two values.
  final List<double> values;

  /// A list of fixed values that can be selected on the slider.
  final List<FlutterSliderFixedValue>? fixedValues;

  /// Determines whether this is a range slider or a single-value slider.
  final bool rangeSlider;

  /// Determines whether the slider should be displayed right-to-left.
  final bool rtl;

  /// Determines whether the slider should snap to fixed values.
  final bool jump;

  /// Determines whether a tap on the slider should set the nearest handle to that position.
  final bool selectByTap;

  /// A list of values that should be ignored when snapping to fixed values.
  final List<FlutterSliderIgnoreSteps> ignoreSteps;

  /// Determines whether the slider should be disabled.
  final bool disabled;

  /// The size of the touch area for each handler.
  final double? touchSize;

  /// Determines whether the touch area for each handler should be visible.
  final bool visibleTouchArea;

  /// The minimum distance between the two handles of a range slider.
  final double minimumDistance;

  /// The maximum distance between the two handles of a range slider.
  final double maximumDistance;

  /// The animation settings for the slider handlers.
  final FlutterSliderHandlerAnimation handlerAnimation;

  /// The settings for the slider tooltip.
  final FlutterSliderTooltip? tooltip;

  /// The settings for the slider track bar.
  final FlutterSliderTrackBar trackBar;

  /// The settings for the slider step.
  final FlutterSliderStep step;

  /// The settings for the slider hatch mark.
  final FlutterSliderHatchMark? hatchMark;

  /// Determines whether the slider should be centered at the origin of the slider axis.
  final bool centeredOrigin;

  /// Determines whether the handles should be locked together when dragging.
  final bool lockHandlers;

  /// The maximum distance between the two handles to lock the handles together.
  final double? lockDistance;

  /// The decoration to apply to the slider.
  final BoxDecoration? decoration;

  /// The foreground decoration to apply to the slider.
  final BoxDecoration? foregroundDecoration;

  /// This factor is timesed by the height of the height of the slider. It must be greater than 0.
  final double containerHeightFactor;

  FlutterSlider({
    Key? key,
    this.min,
    this.max,
    required this.values,
    this.fixedValues,
    this.axis = Axis.horizontal,
    this.handler,
    this.rightHandler,
    this.handlerHeight,
    this.handlerWidth,
    this.onDragStarted,
    this.onDragCompleted,
    this.onDragging,
    this.rangeSlider = false,
    this.rtl = false,
    this.jump = false,
    this.ignoreSteps = const [],
    this.disabled = false,
    this.touchSize,
    this.visibleTouchArea = false,
    this.minimumDistance = 0,
    this.maximumDistance = 0,
    this.tooltip,
    this.trackBar = const FlutterSliderTrackBar(),
    this.handlerAnimation = const FlutterSliderHandlerAnimation(),
    this.selectByTap = true,
    this.step = const FlutterSliderStep(),
    this.hatchMark,
    this.centeredOrigin = false,
    this.lockHandlers = false,
    this.lockDistance,
    this.decoration,
    this.foregroundDecoration,
    this.containerHeightFactor = 2,
  }) : assert(containerHeightFactor > 0, "containerHeightFactor should be greater than 0"),
       assert(touchSize == null || (touchSize >= 5 && touchSize <= 50)),
       assert((ignoreSteps.isNotEmpty && step.rangeList == null) || (ignoreSteps.isEmpty)),
       assert(
         (step.rangeList != null && minimumDistance == 0 && maximumDistance == 0) ||
             (minimumDistance > 0 && step.rangeList == null) ||
             (maximumDistance > 0 && step.rangeList == null) ||
             (step.rangeList == null),
       ),
       assert(
         centeredOrigin == false ||
             (centeredOrigin == true &&
                 rangeSlider == false &&
                 lockHandlers == false &&
                 minimumDistance == 0 &&
                 maximumDistance == 0),
       ),
       assert(
         lockHandlers == false ||
             (centeredOrigin == false &&
                 (ignoreSteps.isEmpty) &&
                 (fixedValues == null || fixedValues.isEmpty) &&
                 rangeSlider == true &&
                 values.length > 1 &&
                 lockHandlers == true &&
                 lockDistance != null &&
                 step.rangeList == null &&
                 lockDistance >= step.step /* && values[1] - values[0] == lockDistance*/ ),
       ),
       assert(
         fixedValues != null || (min != null && max != null && min <= max),
         "Min and Max are required if fixedValues is null",
       ),
       assert(
         rangeSlider == false || (rangeSlider == true && values.length > 1),
         "Range slider needs two values",
       ),
       //        assert( fixedValues == null || (fixedValues != null && values[0] >= 0 && values[0] <= 100), "When using fixedValues, you should set values within the range of fixedValues" ),
       //        assert( fixedValues == null || (fixedValues != null && values.length > 1 && values[1] >= values[0] && values[1] <= 100), "When using fixedValues, you should set values within the range of fixedValues" ),
       super(key: key);

  @override
  FlutterSliderState createState() => FlutterSliderState();
}

class FlutterSliderState extends State<FlutterSlider> with TickerProviderStateMixin {
  /// A boolean flag to determine if it is the first initialization call or not.
  bool __isInitCall = true;

  /// Size of the touch area around the handlers.
  double? _touchSize;

  /// Widgets for the left and right handlers.
  late Widget leftHandler;
  late Widget rightHandler;

  /// X and Y position of the left and right handlers.
  double? _leftHandlerXPosition = 0;
  double? _rightHandlerXPosition = 0;
  double? _leftHandlerYPosition = 0;
  double? _rightHandlerYPosition = 0;

  /// Lower and upper values selected by the user.
  double? _lowerValue = 0;
  double? _upperValue = 0;

  /// Selected lower and upper values after applying formatting and conversion.
  dynamic _outputLowerValue = 0;
  dynamic _outputUpperValue = 0;

  /// Minimum and maximum values of the slider.
  double? _realMin;
  double? _realMax;

  /// Divisions of the slider.
  late double _divisions;

  /// Padding around the handlers.
  double _handlersPadding = 0;

  /// Keys for the left and right handlers, container, and tooltips.
  GlobalKey leftHandlerKey = GlobalKey();
  GlobalKey rightHandlerKey = GlobalKey();
  GlobalKey containerKey = GlobalKey();
  GlobalKey leftTooltipKey = GlobalKey();
  GlobalKey rightTooltipKey = GlobalKey();

  /// Width and height of the handlers.
  double? _handlersWidth;
  double? _handlersHeight;

  // This variable holds the maximum width constraint value that is set for the widget
  late double _constraintMaxWidth;

  // This variable holds the maximum height constraint value that is set for the widget
  late double _constraintMaxHeight;

  // This variable holds the container width without padding
  double? _containerWidthWithoutPadding;

  // This variable holds the container height without padding
  double? _containerHeightWithoutPadding;

  // This variable holds the left position of the slider container
  double _containerLeft = 0;

  // This variable holds the top position of the slider container
  double _containerTop = 0;

  // This variable holds the tooltip data that is used to display the tooltip on the slider
  late FlutterSliderTooltip _tooltipData;

  // This list holds all the positioned widgets in the slider
  late List<Function> _positionedItems;

  // This variable holds the opacity of the right tooltip
  double _rightTooltipOpacity = 0;

  // This variable holds the opacity of the left tooltip
  double _leftTooltipOpacity = 0;

  // This animation controller is used for the right tooltip animation
  late AnimationController _rightTooltipAnimationController;

  // This animation is used for the right tooltip animation
  Animation<Offset>? _rightTooltipAnimation;

  // This animation controller is used for the left tooltip animation
  late AnimationController _leftTooltipAnimationController;

  // This animation is used for the left tooltip animation
  Animation<Offset>? _leftTooltipAnimation;

  // This animation controller is used for the left handler scale animation
  AnimationController? _leftHandlerScaleAnimationController;

  // This animation is used for the left handler scale animation
  Animation<Object>? _leftHandlerScaleAnimation;

  // This animation controller is used for the right handler scale animation
  AnimationController? _rightHandlerScaleAnimationController;

  // This animation is used for the right handler scale animation
  Animation<Object>? _rightHandlerScaleAnimation;

  // This variable holds the container height
  double? _containerHeight;

  // This variable holds the container width
  double? _containerWidth;

  // This variable holds the decimal scale value for the slider
  int _decimalScale = 0;

  // These variables hold the temporary X and Y drag positions
  double xDragTmp = 0;
  double yDragTmp = 0;

  // These variables hold the X and Y drag start positions
  double? xDragStart;
  double? yDragStart;

  // These variables hold the step, minimum and maximum values of the slider widget
  double? _widgetStep;
  double? _widgetMin;
  double? _widgetMax;

  // This list holds the ignore steps for the slider widget
  List<FlutterSliderIgnoreSteps> _ignoreSteps = [];

  // This list holds the fixed values for the slider widget
  final List<FlutterSliderFixedValue> _fixedValues = [];

  // This list holds the positioned points in the slider
  List<Positioned> _points = [];

  // This variable holds the flag indicating if the slider is being dragged
  bool __dragging = false;

  // These variables hold temporary Axis, Right Axis, Axis Drag and Axis Position values
  double? __dAxis,
      __rAxis,
      __axisDragTmp,
      __axisPosTmp,
      __containerSizeWithoutPadding,
      __rightHandlerPosition,
      __leftHandlerPosition,
      __containerSizeWithoutHalfPadding;

  // This variable holds the old orientation of the slider
  Orientation? oldOrientation;

  // This variable holds the locked handlers drag offset
  double __lockedHandlersDragOffset = 0;

  // Distance from the right and left handlers
  double? _distanceFromRightHandler, _distanceFromLeftHandler;
  // The distance between the two handlers
  double _handlersDistance = 0;

  // Flags for whether sliding is caused by active trackbar, left tap and slide, or right tap and slide
  bool _slidingByActiveTrackBar = false;
  bool _leftTapAndSlide = false;
  bool _rightTapAndSlide = false;

  // Flag for whether trackBarSlideOnDragStarted() was called
  bool _trackBarSlideOnDragStartedCalled = false;

  // Flags for selectByTap propery handring for Android actual devices
  bool isPointerDown = false;

  @override
  void initState() {
    initMethod();

    super.initState();
  }

  @override
  void didUpdateWidget(FlutterSlider oldWidget) {
    __isInitCall = false;

    initMethod();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _rightTooltipAnimationController.dispose();
    _leftTooltipAnimationController.dispose();
    _leftHandlerScaleAnimationController!.dispose();
    _rightHandlerScaleAnimationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        oldOrientation ??= MediaQuery.of(context).orientation;

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            _constraintMaxWidth = constraints.maxWidth;
            _constraintMaxHeight = constraints.maxHeight;

            _containerWidthWithoutPadding = _constraintMaxWidth - _handlersWidth!;
            _containerHeightWithoutPadding = _constraintMaxHeight - _handlersHeight!;

            double? sliderProperSize = _findProperSliderSize();
            if (widget.axis == Axis.vertical) {
              double layoutWidth = constraints.maxWidth;
              if (layoutWidth == double.infinity) {
                layoutWidth = 0;
              }
              __containerSizeWithoutPadding = _containerHeightWithoutPadding;
              _containerWidth = [(sliderProperSize! * 2), layoutWidth].reduce(max);
              _containerHeight = constraints.maxHeight;
            } else {
              double layoutHeight = constraints.maxHeight;
              if (layoutHeight == double.infinity) {
                layoutHeight = 0;
              }
              _containerWidth = constraints.maxWidth;
              _containerHeight = [
                (sliderProperSize! * widget.containerHeightFactor),
                layoutHeight,
              ].reduce(max);
              __containerSizeWithoutPadding = _containerWidthWithoutPadding;
            }

            if (MediaQuery.of(context).orientation != oldOrientation) {
              _leftHandlerXPosition = 0;
              _rightHandlerXPosition = 0;
              _leftHandlerYPosition = 0;
              _rightHandlerYPosition = 0;

              _renderBoxInitialization();

              _arrangeHandlersPosition();

              _drawHatchMark();

              oldOrientation = MediaQuery.of(context).orientation;
            }

            return Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                //..._points,
                Container(
                  key: containerKey,
                  height: _containerHeight,
                  width: _containerWidth,
                  foregroundDecoration: widget.foregroundDecoration,
                  decoration: widget.decoration,
                  child: Stack(clipBehavior: Clip.none, children: drawHandlers()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double? _findProperSliderSize() {
    List<double?> sizes = [
      widget.trackBar.activeTrackBarHeight,
      widget.trackBar.inactiveTrackBarHeight,
    ];
    if (widget.axis == Axis.horizontal) {
      sizes.add(_handlersHeight);
    } else {
      sizes.add(_handlersWidth);
    }

    return sizes.reduce((value, element) => max(value!, element!));
  }

  void initMethod() {
    _widgetMax = widget.max;
    _widgetMin = widget.min;

    _touchSize = widget.touchSize ?? 15;

    // validate inputs
    _validations();

    // to display min of the range correctly.
    // if we use fakes, then min is always 0
    // so calculations works well, but when we want to display
    // result numbers to user, we add ( _widgetMin ) to the final numbers

    //    if(widget.axis == Axis.vertical) {
    //      animationStart = Offset(0.20, 0);
    //      animationFinish = Offset(-0.52, 0);
    //    }

    if (__isInitCall) {
      _leftHandlerScaleAnimationController = AnimationController(
        duration: widget.handlerAnimation.duration,
        vsync: this,
      );
      _rightHandlerScaleAnimationController = AnimationController(
        duration: widget.handlerAnimation.duration,
        vsync: this,
      );
    }

    _leftHandlerScaleAnimation = Tween(begin: 1.0, end: widget.handlerAnimation.scale).animate(
      CurvedAnimation(
        parent: _leftHandlerScaleAnimationController!,
        reverseCurve: widget.handlerAnimation.reverseCurve,
        curve: widget.handlerAnimation.curve,
      ),
    );
    _rightHandlerScaleAnimation = Tween(begin: 1.0, end: widget.handlerAnimation.scale).animate(
      CurvedAnimation(
        parent: _rightHandlerScaleAnimationController!,
        reverseCurve: widget.handlerAnimation.reverseCurve,
        curve: widget.handlerAnimation.curve,
      ),
    );

    _setParameters();
    _setValues();

    if (widget.rangeSlider == true &&
        widget.maximumDistance > 0 &&
        (_upperValue! - _lowerValue!) > widget.maximumDistance) {
      throw 'lower and upper distance is more than maximum distance';
    }
    if (widget.rangeSlider == true &&
        widget.minimumDistance > 0 &&
        (_upperValue! - _lowerValue!) < widget.minimumDistance) {
      throw 'lower and upper distance is less than minimum distance';
    }

    Offset animationStart = const Offset(0, 0);
    if (widget.tooltip?.disableAnimation == true) {
      animationStart = const Offset(0, -1);
    }

    Offset? animationFinish;
    switch (_tooltipData.direction) {
      case FlutterSliderTooltipDirection.top:
        animationFinish = const Offset(0, -1);
        break;
      case FlutterSliderTooltipDirection.left:
        animationFinish = const Offset(-1, 0);
        break;
      case FlutterSliderTooltipDirection.right:
        animationFinish = const Offset(1, 0);
        break;
      default:
        animationFinish = Offset.zero;
        break;
    }

    if (__isInitCall) {
      _rightTooltipOpacity = (_tooltipData.alwaysShowTooltip == true) ? 1 : 0;
      _leftTooltipOpacity = (_tooltipData.alwaysShowTooltip == true) ? 1 : 0;

      _leftTooltipAnimationController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _rightTooltipAnimationController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
    } else {
      if (_tooltipData.alwaysShowTooltip!) {
        _rightTooltipOpacity = _leftTooltipOpacity = 1;
      }
    }

    _leftTooltipAnimation = Tween<Offset>(begin: animationStart, end: animationFinish).animate(
      CurvedAnimation(parent: _leftTooltipAnimationController, curve: Curves.fastOutSlowIn),
    );

    _rightTooltipAnimation = Tween<Offset>(begin: animationStart, end: animationFinish).animate(
      CurvedAnimation(parent: _rightTooltipAnimationController, curve: Curves.fastOutSlowIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _renderBoxInitialization();

      _arrangeHandlersPosition();

      _drawHatchMark();

      setState(() {});
    });
  }

  void _drawHatchMark() {
    if (widget.hatchMark == null || widget.hatchMark!.disabled) return;
    _points = [];

    // Calculates the maximum track bar height from the inactive and active track bar heights.
    double maxTrackBarHeight = (<double>[
      widget.trackBar.inactiveTrackBarHeight,
      widget.trackBar.activeTrackBarHeight,
    ]).reduce((a, b) => a > b ? a : b);

    FlutterSliderHatchMark hatchMark = FlutterSliderHatchMark();
    hatchMark.disabled = widget.hatchMark!.disabled;
    hatchMark.density = widget.hatchMark!.density;
    hatchMark.smallDensity = widget.hatchMark!.smallDensity;
    hatchMark.linesDistanceFromTrackBar = widget.hatchMark!.linesDistanceFromTrackBar ?? 0;
    hatchMark.labelsDistanceFromTrackBar = widget.hatchMark!.labelsDistanceFromTrackBar ?? 0;
    hatchMark.smallLine =
        widget.hatchMark!.smallLine ??
        const FlutterSliderSizedBox(
          height: 5,
          width: 1,
          decoration: BoxDecoration(color: Colors.black45),
        );
    hatchMark.bigLine =
        widget.hatchMark!.bigLine ??
        const FlutterSliderSizedBox(
          height: 9,
          width: 2,
          decoration: BoxDecoration(color: Colors.black45),
        );
    hatchMark.labelBox =
        widget.hatchMark!.labelBox ?? const FlutterSliderSizedBox(height: 50, width: 50);
    hatchMark.labels = widget.hatchMark!.labels;
    hatchMark.linesAlignment = widget.hatchMark!.linesAlignment;
    hatchMark.displayLines = widget.hatchMark!.displayLines ?? false;

    if (hatchMark.displayLines!) {
      double percent = 100 * hatchMark.density;
      double barWidth, barHeight, distance;
      double? linesTop, linesLeft, linesRight, linesBottom;

      if (widget.axis == Axis.horizontal) {
        // top = hatchMark.linesDistanceFromTrackBar - 2.25;
        distance = ((_constraintMaxWidth - _handlersWidth!) / percent);
      } else {
        // left = hatchMark.linesDistanceFromTrackBar - 3.62;
        distance = ((_constraintMaxHeight - _handlersHeight!) / percent);
      }

      Alignment linesAlignment;
      if (widget.axis == Axis.horizontal) {
        if (hatchMark.linesAlignment == FlutterSliderHatchMarkAlignment.left) {
          linesAlignment = Alignment.bottomCenter;
        } else {
          linesAlignment = Alignment.topCenter;
        }
      } else {
        if (hatchMark.linesAlignment == FlutterSliderHatchMarkAlignment.left) {
          linesAlignment = Alignment.centerRight;
        } else {
          linesAlignment = Alignment.centerLeft;
        }
      }

      Widget barLine;
      for (int p = 0; p <= percent; p++) {
        FlutterSliderSizedBox? barLineBox = hatchMark.smallLine;

        if (p % (hatchMark.smallDensity + 1) == 0) {
          barLineBox = hatchMark.bigLine;
        }

        if (widget.axis == Axis.horizontal) {
          barHeight = barLineBox!.height;
          barWidth = barLineBox.width;
        } else {
          barHeight = barLineBox!.width;
          barWidth = barLineBox.height;
        }

        barLine = Align(
          alignment: linesAlignment,
          child: Container(
            decoration: barLineBox.decoration,
            foregroundDecoration: barLineBox.foregroundDecoration,
            transform: barLineBox.transform,
            height: barHeight,
            width: barWidth,
          ),
        );

        if (widget.axis == Axis.horizontal) {
          // left = (p * distance) + _handlersPadding - labelBoxHalfSize - 0.5;
          linesLeft = (p * distance) + _handlersPadding - 0.75;
          if (hatchMark.linesAlignment == FlutterSliderHatchMarkAlignment.right) {
            linesTop = _containerHeight! / 2 + maxTrackBarHeight / 2 + 2;
            linesBottom = _containerHeight! / 2 - maxTrackBarHeight - 15;
          } else {
            linesTop = _containerHeight! / 2 - maxTrackBarHeight - 15;
            linesBottom = _containerHeight! / 2 + maxTrackBarHeight / 2 + 2;
          }
          if (hatchMark.linesAlignment == FlutterSliderHatchMarkAlignment.left) {
            linesBottom += hatchMark.linesDistanceFromTrackBar!;
          } else {
            linesTop += hatchMark.linesDistanceFromTrackBar!;
          }
        } else {
          linesTop = (p * distance) + _handlersPadding - 0.5;
          if (hatchMark.linesAlignment == FlutterSliderHatchMarkAlignment.right) {
            linesLeft = _containerWidth! / 2 + maxTrackBarHeight / 2 + 2;
            linesRight = _containerWidth! / 2 - maxTrackBarHeight - 15;
          } else {
            linesLeft = _containerWidth! / 2 - maxTrackBarHeight - 15;
            linesRight = _containerWidth! / 2 + maxTrackBarHeight / 2 + 2;
          }
          if (hatchMark.linesAlignment == FlutterSliderHatchMarkAlignment.left) {
            linesRight += hatchMark.linesDistanceFromTrackBar!;
          } else {
            linesLeft += hatchMark.linesDistanceFromTrackBar!;
          }
        }

        _points.add(
          Positioned(
            top: linesTop,
            bottom: linesBottom,
            left: linesLeft,
            right: linesRight,
            child: barLine,
          ),
        );
      }
    }

    if (hatchMark.labels != null && hatchMark.labels!.isNotEmpty) {
      List<Widget> labelWidget = [];
      Widget? label;
      double labelBoxHalfSize;
      double? top, left, bottom, right;
      double? tr;
      for (FlutterSliderHatchMarkLabel markLabel in hatchMark.labels!) {
        label = markLabel.label;
        tr = markLabel.percent;
        labelBoxHalfSize = 0;

        if (widget.rtl) tr = 100 - tr!;

        if (widget.axis == Axis.horizontal) {
          labelBoxHalfSize = hatchMark.labelBox!.width / 2 - 0.5;
        } else {
          labelBoxHalfSize = hatchMark.labelBox!.height / 2 - 0.5;
        }

        labelWidget = [
          Container(
            height: widget.axis == Axis.vertical ? hatchMark.labelBox!.height : null,
            width: widget.axis == Axis.horizontal ? hatchMark.labelBox!.width : null,
            decoration: hatchMark.labelBox!.decoration,
            foregroundDecoration: hatchMark.labelBox!.foregroundDecoration,
            transform: hatchMark.labelBox!.transform,
            child: Align(alignment: Alignment.center, child: label),
          ),
        ];

        Widget bar;
        if (widget.axis == Axis.horizontal) {
          bar = Column(mainAxisAlignment: MainAxisAlignment.center, children: labelWidget);
          left =
              tr! * _containerWidthWithoutPadding! / 100 -
              0.5 +
              _handlersPadding -
              labelBoxHalfSize;
          // left = (tr * distance) + _handlersPadding - labelBoxHalfSize - 0.5;

          top = hatchMark.labelsDistanceFromTrackBar;
          bottom = 0;
        } else {
          bar = Row(mainAxisAlignment: MainAxisAlignment.center, children: labelWidget);
          top =
              tr! * _containerHeightWithoutPadding! / 100 -
              0.5 +
              _handlersPadding -
              labelBoxHalfSize;
          right = 0;
          left = hatchMark.labelsDistanceFromTrackBar;
        }

        _points.add(Positioned(top: top, bottom: bottom, left: left, right: right, child: bar));
      }
    }
  }

  void _validations() {
    if (widget.rangeSlider == true && widget.values.length < 2) {
      throw 'when range mode is true, slider needs both lower and upper values';
    }

    if (widget.fixedValues == null) {
      if (widget.values[0] < _widgetMin!) {
        throw 'Lower value should be greater than min';
      }

      if (widget.rangeSlider == true) {
        if (widget.values[1] > _widgetMax!) {
          throw 'Upper value should be smaller than max';
        }
      }
    } else {
      if (!(widget.fixedValues != null && widget.values[0] >= 0 && widget.values[0] <= 100)) {
        throw 'When using fixedValues, you should set values within the range of fixedValues';
      }

      if (widget.rangeSlider == true && widget.values.length > 1) {
        if (!(widget.fixedValues != null && widget.values[1] >= 0 && widget.values[1] <= 100)) {
          throw 'When using fixedValues, you should set values within the range of fixedValues';
        }
      }
    }

    if (widget.rangeSlider == true) {
      if (widget.values[0] > widget.values[1]) {
        throw 'Lower value must be smaller than upper value';
      }
    }
  }

  void _setParameters() {
    _realMin = 0;
    _widgetMax = widget.max;
    _widgetMin = widget.min;

    _ignoreSteps = [];

    if (widget.fixedValues != null && widget.fixedValues!.isNotEmpty) {
      _realMax = 100;
      _realMin = 0;
      _widgetStep = 1;
      _widgetMax = 100;
      _widgetMin = 0;

      List<double> fixedValuesIndices = [];
      for (FlutterSliderFixedValue fixedValue in widget.fixedValues!) {
        fixedValuesIndices.add(fixedValue.percent!.toDouble());
      }

      double lowerIgnoreBound = -1;
      double upperIgnoreBound;
      List<double> fixedV = [];
      for (double fixedPercent = 0; fixedPercent <= 100; fixedPercent++) {
        dynamic fValue = '';
        for (FlutterSliderFixedValue fixedValue in widget.fixedValues!) {
          if (fixedValue.percent == fixedPercent.toInt()) {
            fixedValuesIndices.add(fixedValue.percent!.toDouble());
            fValue = fixedValue.value;

            upperIgnoreBound = fixedPercent;
            if (fixedPercent > lowerIgnoreBound + 1 || lowerIgnoreBound == 0) {
              if (lowerIgnoreBound > 0) lowerIgnoreBound += 1;
              upperIgnoreBound = fixedPercent - 1;
              _ignoreSteps.add(
                FlutterSliderIgnoreSteps(from: lowerIgnoreBound, to: upperIgnoreBound),
              );
            }
            lowerIgnoreBound = fixedPercent;
            break;
          }
        }
        _fixedValues.add(FlutterSliderFixedValue(percent: fixedPercent.toInt(), value: fValue));
        if (fValue.toString().isNotEmpty) {
          fixedV.add(fixedPercent);
        }
      }

      double? biggestPoint = _findBiggestIgnorePoint(ignoreBeyondBoundaries: true);
      if (!fixedV.contains(100)) {
        _ignoreSteps.add(FlutterSliderIgnoreSteps(from: biggestPoint! + 1, to: 101));
      }
    } else {
      _realMax = _widgetMax! - _widgetMin!;
      _widgetStep = widget.step.step;
    }

    _ignoreSteps.addAll(widget.ignoreSteps);

    _handlersWidth = widget.handlerWidth ?? widget.handlerHeight ?? 35;
    _handlersHeight = widget.handlerHeight ?? widget.handlerWidth ?? 35;

    _setDivisionAndDecimalScale();

    _positionedItems = [_leftHandlerWidget, _rightHandlerWidget];

    FlutterSliderTooltip widgetTooltip = widget.tooltip ?? FlutterSliderTooltip();

    _tooltipData = FlutterSliderTooltip();
    _tooltipData.boxStyle =
        widgetTooltip.boxStyle ??
        FlutterSliderTooltipBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12, width: 0.5),
            color: const Color(0xffffffff),
          ),
        );
    _tooltipData.textStyle =
        widgetTooltip.textStyle ?? const TextStyle(fontSize: 12, color: Colors.black38);
    _tooltipData.leftPrefix = widgetTooltip.leftPrefix;
    _tooltipData.leftSuffix = widgetTooltip.leftSuffix;
    _tooltipData.rightPrefix = widgetTooltip.rightPrefix;
    _tooltipData.rightSuffix = widgetTooltip.rightSuffix;
    _tooltipData.alwaysShowTooltip = widgetTooltip.alwaysShowTooltip ?? false;
    _tooltipData.disabled = widgetTooltip.disabled ?? false;
    _tooltipData.disableAnimation = widgetTooltip.disableAnimation ?? false;
    _tooltipData.direction = widgetTooltip.direction ?? FlutterSliderTooltipDirection.top;
    _tooltipData.positionOffset = widgetTooltip.positionOffset;
    _tooltipData.format = widgetTooltip.format;
    _tooltipData.custom = widgetTooltip.custom;

    _arrangeHandlersZIndex();

    _generateHandler();

    _handlersDistance = widget.lockDistance ?? _upperValue! - _lowerValue!;
  }

  void _setDivisionAndDecimalScale() {
    _divisions = _realMax! / _widgetStep!;
    String tmpDecimalScale = '0';
    List<String> tmpDecimalScaleArr = _widgetStep.toString().split(".");
    if (tmpDecimalScaleArr.length > 1) tmpDecimalScale = tmpDecimalScaleArr[1];
    if (int.parse(tmpDecimalScale) > 0) {
      _decimalScale = tmpDecimalScale.length;
    }
  }

  List<double?> _calculateUpperAndLowerValues() {
    double? localLV, localUV;
    localLV = widget.values[0];
    if (widget.rangeSlider) {
      localUV = widget.values[1];
    } else {
      // when direction is rtl, then we use left handler. so to make right hand side
      // as blue ( as if selected ), then upper value should be max
      if (widget.rtl) {
        localUV = _widgetMax;
      } else {
        // when direction is ltr, so we use right handler, to make left hand side of handler
        // as blue ( as if selected ), we set lower value to min, and upper value to (input lower value)
        localUV = localLV;
        localLV = _widgetMin;
      }
    }

    return [localLV, localUV];
  }

  void _setValues() {
    List<double?> localValues = _calculateUpperAndLowerValues();

    _lowerValue = localValues[0]! - _widgetMin!;
    _upperValue = localValues[1]! - _widgetMin!;

    _outputUpperValue = _displayRealValue(_upperValue);
    _outputLowerValue = _displayRealValue(_lowerValue);

    if (widget.rtl == true) {
      _outputLowerValue = _displayRealValue(_upperValue);
      _outputUpperValue = _displayRealValue(_lowerValue);

      double tmpUpperValue = _realMax! - _lowerValue!;
      double tmpLowerValue = _realMax! - _upperValue!;

      _lowerValue = tmpLowerValue;
      _upperValue = tmpUpperValue;
    }
  }

  void _arrangeHandlersPosition() {
    if (!__dragging) {
      if (widget.axis == Axis.horizontal) {
        _handlersPadding = _handlersWidth! / 2;
        _leftHandlerXPosition = getPositionByValue(_lowerValue);
        _rightHandlerXPosition = getPositionByValue(_upperValue);
      } else {
        _handlersPadding = _handlersHeight! / 2;
        _leftHandlerYPosition = getPositionByValue(_lowerValue);
        _rightHandlerYPosition = getPositionByValue(_upperValue);
      }
    }
  }

  void _generateHandler() {
    /*Right Handler Data*/
    FlutterSliderHandler inputRightHandler = widget.rightHandler ?? FlutterSliderHandler();
    inputRightHandler.child ??= Icon(
      (widget.axis == Axis.horizontal) ? Icons.chevron_left : Icons.expand_less,
      color: Colors.black45,
    );
    inputRightHandler.decoration ??= const BoxDecoration(
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 2, spreadRadius: 0.2, offset: Offset(0, 1)),
      ],
      color: Colors.white,
      shape: BoxShape.circle,
    );

    rightHandler = MakeHandler(
      animation: _rightHandlerScaleAnimation,
      id: rightHandlerKey,
      visibleTouchArea: widget.visibleTouchArea,
      handlerData: widget.rightHandler,
      width: _handlersWidth,
      height: _handlersHeight,
      axis: widget.axis,
      handlerIndex: 2,
      touchSize: _touchSize,
    );

    leftHandler = MakeHandler(
      animation: _leftHandlerScaleAnimation,
      id: leftHandlerKey,
      visibleTouchArea: widget.visibleTouchArea,
      handlerData: widget.handler,
      width: _handlersWidth,
      height: _handlersHeight,
      rtl: widget.rtl,
      rangeSlider: widget.rangeSlider,
      axis: widget.axis,
      touchSize: _touchSize,
    );

    if (widget.rangeSlider == false) {
      rightHandler = leftHandler;
    }
  }

  double getPositionByValue(value) {
    if (widget.axis == Axis.horizontal) {
      return (((_constraintMaxWidth - _handlersWidth!) / _realMax!) * value) - _touchSize!;
    } else {
      return (((_constraintMaxHeight - _handlersHeight!) / _realMax!) * value) - _touchSize!;
    }
  }

  double getValueByPosition(double position) {
    double value = ((position / (__containerSizeWithoutPadding! / _divisions)) * _widgetStep!);
    value =
        (double.parse(value.toStringAsFixed(_decimalScale)) -
        double.parse((value % _widgetStep!).toStringAsFixed(_decimalScale)));
    return value;
  }

  double? getLengthByValue(value) {
    return value * __containerSizeWithoutPadding / _realMax;
  }

  double getValueByPositionIgnoreOffset(double position) {
    double value = ((position / (__containerSizeWithoutPadding! / _divisions)) * _widgetStep!);
    return value;
  }

  void _leftHandlerMove(
    PointerEvent pointer, {
    double lockedHandlersDragOffset = 0,
    double tappedPositionWithPadding = 0,
    bool selectedByTap = false,
  }) {
    if (widget.disabled || (widget.handler != null && widget.handler!.disabled)) {
      return;
    }

    _handlersDistance = widget.lockDistance ?? _upperValue! - _lowerValue!;

    // Tip: lockedHandlersDragOffset only subtracts from left handler position
    // because it calculates drag position only by left handler's position
    if (lockedHandlersDragOffset == 0) __lockedHandlersDragOffset = 0;

    if (selectedByTap) {
      _callbacks('onDragStarted', 0);
    } else if (!isPointerDown) {
      return;
    }

    bool validMove = true;

    if (widget.axis == Axis.horizontal) {
      __dAxis =
          pointer.position.dx -
          tappedPositionWithPadding -
          lockedHandlersDragOffset -
          _containerLeft;
      __axisDragTmp = xDragTmp;
      __containerSizeWithoutPadding = _containerWidthWithoutPadding;
      __rightHandlerPosition = _rightHandlerXPosition;
      __leftHandlerPosition = _leftHandlerXPosition;
    } else {
      __dAxis =
          pointer.position.dy -
          tappedPositionWithPadding -
          lockedHandlersDragOffset -
          _containerTop;
      __axisDragTmp = yDragTmp;
      __containerSizeWithoutPadding = _containerHeightWithoutPadding;
      __rightHandlerPosition = _rightHandlerYPosition;
      __leftHandlerPosition = _leftHandlerYPosition;
    }

    __axisPosTmp = __dAxis! - __axisDragTmp! + _touchSize!;

    _checkRangeStep(getValueByPositionIgnoreOffset(__axisPosTmp!));

    __rAxis = getValueByPosition(__axisPosTmp!);

    if (widget.rangeSlider &&
        widget.minimumDistance > 0 &&
        (__rAxis! + widget.minimumDistance) >= _upperValue!) {
      _lowerValue = (_upperValue! - widget.minimumDistance > _realMin!)
          ? _upperValue! - widget.minimumDistance
          : _realMin;
      _updateLowerValue(_lowerValue);

      if (lockedHandlersDragOffset == 0) validMove = validMove & false;
    }

    if (widget.rangeSlider &&
        widget.maximumDistance > 0 &&
        __rAxis! <= (_upperValue! - widget.maximumDistance)) {
      _lowerValue = (_upperValue! - widget.maximumDistance > _realMin!)
          ? _upperValue! - widget.maximumDistance
          : _realMin;
      _updateLowerValue(_lowerValue);

      if (lockedHandlersDragOffset == 0) validMove = validMove & false;
    }

    double? tS = _touchSize;
    if (widget.jump) {
      tS = _touchSize! + _handlersPadding;
    }

    validMove = validMove & _leftHandlerIgnoreSteps(tS);

    bool forcePosStop = false;
    if (((__axisPosTmp! <= 0) || (__axisPosTmp! - tS! >= __rightHandlerPosition!))) {
      forcePosStop = true;
    }

    if (validMove && ((__axisPosTmp! + _handlersPadding >= _handlersPadding) || forcePosStop)) {
      double tmpLowerValue = __rAxis!;

      if (tmpLowerValue > _realMax!) tmpLowerValue = _realMax!;
      if (tmpLowerValue < _realMin!) tmpLowerValue = _realMin!;

      if (tmpLowerValue > _upperValue!) tmpLowerValue = _upperValue!;

      if (widget.jump == true) {
        if (!forcePosStop) {
          _lowerValue = tmpLowerValue;
          _leftHandlerMoveBetweenSteps(__dAxis! - __axisDragTmp!, selectedByTap);
          __leftHandlerPosition = getPositionByValue(_lowerValue);
        } else {
          if (__axisPosTmp! - tS! >= __rightHandlerPosition!) {
            __leftHandlerPosition = __rightHandlerPosition;
            _lowerValue = tmpLowerValue = _upperValue!;
          } else {
            __leftHandlerPosition = getPositionByValue(_realMin);
            _lowerValue = tmpLowerValue = _realMin!;
          }
          _updateLowerValue(tmpLowerValue);
        }
      } else {
        _lowerValue = tmpLowerValue;

        if (!forcePosStop) {
          __leftHandlerPosition = __dAxis! - __axisDragTmp!; // - (_touchSize);

          _leftHandlerMoveBetweenSteps(__leftHandlerPosition, selectedByTap);
          tmpLowerValue = _lowerValue!;
        } else {
          if (__axisPosTmp! - tS! >= __rightHandlerPosition!) {
            __leftHandlerPosition = __rightHandlerPosition;
            _lowerValue = tmpLowerValue = _upperValue!;
          } else {
            __leftHandlerPosition = getPositionByValue(_realMin);
            _lowerValue = tmpLowerValue = _realMin!;
          }
          _updateLowerValue(tmpLowerValue);
        }
      }
    }

    if (widget.axis == Axis.horizontal) {
      _leftHandlerXPosition = __leftHandlerPosition;
    } else {
      _leftHandlerYPosition = __leftHandlerPosition;
    }
    if (widget.lockHandlers || lockedHandlersDragOffset > 0) {
      _lockedHandlers('leftHandler');
    }
    setState(() {});

    if (selectedByTap) {
      _callbacks('onDragging', 0);
      _callbacks('onDragCompleted', 0);
    } else {
      _callbacks('onDragging', 0);
    }
  }

  bool _leftHandlerIgnoreSteps(double? tS) {
    bool validMove = true;
    if (_ignoreSteps.isNotEmpty) {
      if (__axisPosTmp! <= 0) {
        double? ignorePoint;
        if (widget.rtl) {
          ignorePoint = _findBiggestIgnorePoint();
        } else {
          ignorePoint = _findSmallestIgnorePoint();
        }

        __leftHandlerPosition = getPositionByValue(ignorePoint);
        _lowerValue = ignorePoint;
        _updateLowerValue(_lowerValue);
        return false;
      } else if (__axisPosTmp! - tS! >= __rightHandlerPosition!) {
        __leftHandlerPosition = __rightHandlerPosition;
        _lowerValue = _upperValue;
        _updateLowerValue(_lowerValue);
        return false;
      }

      for (FlutterSliderIgnoreSteps steps in _ignoreSteps) {
        if (((!widget.rtl) &&
                (getValueByPositionIgnoreOffset(__axisPosTmp!) > steps.from! - _widgetStep! / 2 &&
                    getValueByPositionIgnoreOffset(__axisPosTmp!) <=
                        steps.to! + _widgetStep! / 2)) ||
            ((widget.rtl) &&
                (_realMax! - getValueByPositionIgnoreOffset(__axisPosTmp!) >
                        steps.from! - _widgetStep! / 2 &&
                    _realMax! - getValueByPositionIgnoreOffset(__axisPosTmp!) <=
                        steps.to! + _widgetStep! / 2)))
          validMove = false;
      }
    }

    return validMove;
  }

  void _leftHandlerMoveBetweenSteps(handlerPos, bool selectedByTap) {
    double nextStepMiddlePos = getPositionByValue(
      (_lowerValue! + (_lowerValue! + _widgetStep!)) / 2,
    );
    double prevStepMiddlePos = getPositionByValue(
      (_lowerValue! - (_lowerValue! - _widgetStep!)) / 2,
    );

    if (handlerPos > nextStepMiddlePos || handlerPos < prevStepMiddlePos) {
      if (handlerPos > nextStepMiddlePos) {
        _lowerValue = _lowerValue! + _widgetStep!;
        if (_lowerValue! > _realMax!) _lowerValue = _realMax;
        if (_lowerValue! > _upperValue!) _lowerValue = _upperValue;
      } else {
        _lowerValue = _lowerValue! - _widgetStep!;
        if (_lowerValue! < _realMin!) _lowerValue = _realMin;
      }
    }
    _updateLowerValue(_lowerValue);
  }

  void _lockedHandlers(handler) {
    double? distanceOfTwoHandlers = getLengthByValue(_handlersDistance);

    double? leftHandlerPos, rightHandlerPos;
    if (widget.axis == Axis.horizontal) {
      leftHandlerPos = _leftHandlerXPosition;
      rightHandlerPos = _rightHandlerXPosition;
    } else {
      leftHandlerPos = _leftHandlerYPosition;
      rightHandlerPos = _rightHandlerYPosition;
    }

    if (handler == 'rightHandler') {
      _lowerValue = _upperValue! - _handlersDistance;
      leftHandlerPos = rightHandlerPos! - distanceOfTwoHandlers!;
      if (getValueByPositionIgnoreOffset(__axisPosTmp!) - _handlersDistance < _realMin!) {
        _lowerValue = _realMin;
        _upperValue = _realMin! + _handlersDistance;
        rightHandlerPos = getPositionByValue(_upperValue);
        leftHandlerPos = getPositionByValue(_lowerValue);
      }
    } else {
      _upperValue = _lowerValue! + _handlersDistance;
      rightHandlerPos = leftHandlerPos! + distanceOfTwoHandlers!;
      if (getValueByPositionIgnoreOffset(__axisPosTmp!) + _handlersDistance > _realMax!) {
        _upperValue = _realMax;
        _lowerValue = _realMax! - _handlersDistance;
        rightHandlerPos = getPositionByValue(_upperValue);
        leftHandlerPos = getPositionByValue(_lowerValue);
      }
    }

    if (widget.axis == Axis.horizontal) {
      _leftHandlerXPosition = leftHandlerPos;
      _rightHandlerXPosition = rightHandlerPos;
    } else {
      _leftHandlerYPosition = leftHandlerPos;
      _rightHandlerYPosition = rightHandlerPos;
    }

    _updateUpperValue(_upperValue);
    _updateLowerValue(_lowerValue);
  }

  void _updateLowerValue(value) {
    _outputLowerValue = _displayRealValue(value);
    if (widget.rtl == true) {
      _outputLowerValue = _displayRealValue(_realMax! - value);
    }
  }

  void _rightHandlerMove(
    PointerEvent pointer, {
    double tappedPositionWithPadding = 0,
    bool selectedByTap = false,
  }) {
    if (widget.disabled || (widget.rightHandler != null && widget.rightHandler!.disabled)) return;

    _handlersDistance = widget.lockDistance ?? _upperValue! - _lowerValue!;

    if (selectedByTap) {
      _callbacks('onDragStarted', 1);
    } else if (!isPointerDown) {
      return;
    }

    bool validMove = true;

    if (widget.axis == Axis.horizontal) {
      __dAxis = pointer.position.dx - tappedPositionWithPadding - _containerLeft;
      __axisDragTmp = xDragTmp;
      __containerSizeWithoutPadding = _containerWidthWithoutPadding;
      __rightHandlerPosition = _rightHandlerXPosition;
      __leftHandlerPosition = _leftHandlerXPosition;
      __containerSizeWithoutHalfPadding = _constraintMaxWidth - _handlersPadding + 1;
    } else {
      __dAxis = pointer.position.dy - tappedPositionWithPadding - _containerTop;
      __axisDragTmp = yDragTmp;
      __containerSizeWithoutPadding = _containerHeightWithoutPadding;
      __rightHandlerPosition = _rightHandlerYPosition;
      __leftHandlerPosition = _leftHandlerYPosition;
      __containerSizeWithoutHalfPadding = _constraintMaxHeight - _handlersPadding + 1;
    }

    __axisPosTmp = __dAxis! - __axisDragTmp! + _touchSize!;

    _checkRangeStep(getValueByPositionIgnoreOffset(__axisPosTmp!));

    __rAxis = getValueByPosition(__axisPosTmp!);

    if (widget.rangeSlider &&
        widget.minimumDistance > 0 &&
        (__rAxis! - widget.minimumDistance) <= _lowerValue!) {
      _upperValue = (_lowerValue! + widget.minimumDistance < _realMax!)
          ? _lowerValue! + widget.minimumDistance
          : _realMax;
      validMove = validMove & false;
      _updateUpperValue(_upperValue);
    }
    if (widget.rangeSlider &&
        widget.maximumDistance > 0 &&
        __rAxis! >= (_lowerValue! + widget.maximumDistance)) {
      _upperValue = (_lowerValue! + widget.maximumDistance < _realMax!)
          ? _lowerValue! + widget.maximumDistance
          : _realMax;
      validMove = validMove & false;
      _updateUpperValue(_upperValue);
    }

    double? tS = _touchSize;
    double rM = _handlersPadding;
    if (widget.jump) {
      rM = -_handlersWidth!;
      tS = -_touchSize!;
    }

    validMove = validMove & _rightHandlerIgnoreSteps(tS);

    bool forcePosStop = false;
    if (((__axisPosTmp! >= __containerSizeWithoutPadding!) ||
        (__axisPosTmp! - tS! <= __leftHandlerPosition!))) {
      forcePosStop = true;
    }

    if (validMove && (__axisPosTmp! + rM <= __containerSizeWithoutHalfPadding! || forcePosStop)) {
      double tmpUpperValue = __rAxis!;

      if (tmpUpperValue > _realMax!) tmpUpperValue = _realMax!;
      if (tmpUpperValue < _realMin!) tmpUpperValue = _realMin!;

      if (tmpUpperValue < _lowerValue!) tmpUpperValue = _lowerValue!;

      if (widget.jump == true) {
        if (!forcePosStop) {
          _upperValue = tmpUpperValue;
          _rightHandlerMoveBetweenSteps(__dAxis! - __axisDragTmp!, selectedByTap);
          __rightHandlerPosition = getPositionByValue(_upperValue);
        } else {
          if (__axisPosTmp! - tS! <= __leftHandlerPosition!) {
            __rightHandlerPosition = __leftHandlerPosition;
            _upperValue = tmpUpperValue = _lowerValue!;
          } else {
            __rightHandlerPosition = getPositionByValue(_realMax);
            _upperValue = tmpUpperValue = _realMax!;
          }

          _updateUpperValue(tmpUpperValue);
        }
      } else {
        _upperValue = tmpUpperValue;

        if (!forcePosStop) {
          __rightHandlerPosition = __dAxis! - __axisDragTmp!;
          _rightHandlerMoveBetweenSteps(__rightHandlerPosition, selectedByTap);
          tmpUpperValue = _upperValue!;
        } else {
          if (__axisPosTmp! - tS! <= __leftHandlerPosition!) {
            __rightHandlerPosition = __leftHandlerPosition;
            _upperValue = tmpUpperValue = _lowerValue!;
          } else {
            __rightHandlerPosition = getPositionByValue(_realMax) + 1;
            _upperValue = tmpUpperValue = _realMax!;
          }
        }
        _updateUpperValue(tmpUpperValue);
      }
    }

    if (widget.axis == Axis.horizontal) {
      _rightHandlerXPosition = __rightHandlerPosition;
    } else {
      _rightHandlerYPosition = __rightHandlerPosition;
    }
    if (widget.lockHandlers) {
      _lockedHandlers('rightHandler');
    }

    setState(() {});

    if (selectedByTap) {
      _callbacks('onDragging', 1);
      _callbacks('onDragCompleted', 1);
    } else {
      _callbacks('onDragging', 1);
    }
  }

  bool _rightHandlerIgnoreSteps(double? tS) {
    bool validMove = true;
    if (_ignoreSteps.isNotEmpty) {
      if (__axisPosTmp! <= 0) {
        if (!widget.rangeSlider) {
          double? ignorePoint;
          if (widget.rtl) {
            ignorePoint = _findBiggestIgnorePoint();
          } else {
            ignorePoint = _findSmallestIgnorePoint();
          }

          __rightHandlerPosition = getPositionByValue(ignorePoint);
          _upperValue = ignorePoint;
          _updateUpperValue(_upperValue);
        } else {
          __rightHandlerPosition = __leftHandlerPosition;
          _upperValue = _lowerValue;
          _updateUpperValue(_upperValue);
        }
        return false;
      } else if (__axisPosTmp! >= __containerSizeWithoutPadding!) {
        double? ignorePoint;

        if (widget.rtl) {
          ignorePoint = _findSmallestIgnorePoint();
        } else {
          ignorePoint = _findBiggestIgnorePoint();
        }

        __rightHandlerPosition = getPositionByValue(ignorePoint);
        _upperValue = ignorePoint;
        _updateUpperValue(_upperValue);
        return false;
      }

      for (FlutterSliderIgnoreSteps steps in _ignoreSteps) {
        if (((!widget.rtl) &&
                (getValueByPositionIgnoreOffset(__axisPosTmp!) > steps.from! - _widgetStep! / 2 &&
                    getValueByPositionIgnoreOffset(__axisPosTmp!) <=
                        steps.to! + _widgetStep! / 2)) ||
            ((widget.rtl) &&
                (_realMax! - getValueByPositionIgnoreOffset(__axisPosTmp!) >
                        steps.from! - _widgetStep! / 2 &&
                    _realMax! - getValueByPositionIgnoreOffset(__axisPosTmp!) <=
                        steps.to! + _widgetStep! / 2)))
          validMove = false;
      }
    }
    return validMove;
  }

  double? _findSmallestIgnorePoint({ignoreBeyondBoundaries = false}) {
    double? ignorePoint = _realMax;
    bool beyondBoundaries = false;
    for (FlutterSliderIgnoreSteps steps in _ignoreSteps) {
      if (steps.from! < _realMin!) beyondBoundaries = true;
      if (steps.from! < ignorePoint! && steps.from! >= _realMin!) {
        ignorePoint = steps.from! - _widgetStep!;
      } else if (steps.to! < ignorePoint && steps.to! >= _realMin!) {
        ignorePoint = steps.to! + _widgetStep!;
      }
    }
    if (beyondBoundaries || ignoreBeyondBoundaries) {
      if (widget.rtl) {
        ignorePoint = _realMax! - ignorePoint!;
      }
      return ignorePoint;
    } else {
      if (widget.rtl) return _realMax;
      return _realMin;
    }
  }

  double? _findBiggestIgnorePoint({ignoreBeyondBoundaries = false}) {
    double? ignorePoint = _realMin;
    bool beyondBoundaries = false;
    for (FlutterSliderIgnoreSteps steps in _ignoreSteps) {
      if (steps.to! > _realMax!) beyondBoundaries = true;

      if (steps.to! > ignorePoint! && steps.to! <= _realMax!) {
        ignorePoint = steps.to! + _widgetStep!;
      } else if (steps.from! > ignorePoint && steps.from! <= _realMax!) {
        ignorePoint = steps.from! - _widgetStep!;
      }
    }
    if (beyondBoundaries || ignoreBeyondBoundaries) {
      if (widget.rtl) {
        ignorePoint = _realMax! - ignorePoint!;
      }

      return ignorePoint;
    } else {
      if (widget.rtl) return _realMin;
      return _realMax;
    }
  }

  void _rightHandlerMoveBetweenSteps(handlerPos, bool selectedByTap) {
    double nextStepMiddlePos = getPositionByValue(
      (_upperValue! + (_upperValue! + _widgetStep!)) / 2,
    );
    double prevStepMiddlePos = getPositionByValue(
      (_upperValue! - (_upperValue! - _widgetStep!)) / 2,
    );

    if (handlerPos > nextStepMiddlePos || handlerPos < prevStepMiddlePos) {
      if (handlerPos > nextStepMiddlePos) {
        _upperValue = _upperValue! + _widgetStep!;
        if (_upperValue! > _realMax!) _upperValue = _realMax;
      } else {
        _upperValue = _upperValue! - _widgetStep!;
        if (_upperValue! < _realMin!) _upperValue = _realMin;
        if (_upperValue! < _lowerValue!) _upperValue = _lowerValue;
      }
    }
    _updateUpperValue(_upperValue);
  }

  void _updateUpperValue(value) {
    _outputUpperValue = _displayRealValue(value);
    if (widget.rtl == true) {
      _outputUpperValue = _displayRealValue(_realMax! - value);
    }
  }

  void _checkRangeStep(double realValue) {
    double? sliderFromRange, sliderToRange;
    if (widget.step.rangeList != null) {
      for (FlutterSliderRangeStep rangeStep in widget.step.rangeList!) {
        if (widget.step.isPercentRange) {
          sliderFromRange = _widgetMax! * rangeStep.from! / 100;
          sliderToRange = _widgetMax! * rangeStep.to! / 100;
        } else {
          sliderFromRange = rangeStep.from;
          sliderToRange = rangeStep.to;
        }

        if (realValue >= sliderFromRange! && realValue <= sliderToRange!) {
          _widgetStep = rangeStep.step;
          _setDivisionAndDecimalScale();
          break;
        }
      }
    }
  }

  Positioned _leftHandlerWidget() {
    if (widget.rangeSlider == false) {
      return Positioned(child: Container());
    }

    double? bottom;
    double? right;
    if (widget.axis == Axis.horizontal) {
      bottom = 0;
    } else {
      right = 0;
    }

    return Positioned(
      key: const Key('leftHandler'),
      left: _leftHandlerXPosition,
      top: _leftHandlerYPosition,
      bottom: bottom,
      right: right,
      child: Listener(
        child: Draggable(
          axis: widget.axis,
          feedback: Container(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _tooltip(
                side: 'left',
                value: _outputLowerValue,
                opacity: _leftTooltipOpacity,
                animation: _leftTooltipAnimation,
              ),
              leftHandler,
            ],
          ),
        ),
        onPointerMove: (_) {
          __dragging = true;

          _leftHandlerMove(_);
        },
        onPointerDown: (_) {
          if (widget.disabled || (widget.handler != null && widget.handler!.disabled)) return;
          isPointerDown = true;
          _renderBoxInitialization();

          xDragTmp = (_.position.dx - _containerLeft - _leftHandlerXPosition!);
          yDragTmp = (_.position.dy - _containerTop - _leftHandlerYPosition!);

          if (!_tooltipData.disabled! && _tooltipData.alwaysShowTooltip == false) {
            _leftTooltipOpacity = 1;
            _leftTooltipAnimationController.forward();

            if (widget.lockHandlers) {
              _rightTooltipOpacity = 1;
              _rightTooltipAnimationController.forward();
            }
          }

          _leftHandlerScaleAnimationController!.forward();

          setState(() {});

          _callbacks('onDragStarted', 0);
        },
        onPointerUp: (_) {
          __dragging = isPointerDown = false;

          _adjustLeftHandlerPosition();

          if (widget.disabled || (widget.handler != null && widget.handler!.disabled)) return;

          _arrangeHandlersZIndex();

          _stopHandlerAnimation(
            animation: _leftHandlerScaleAnimation,
            controller: _leftHandlerScaleAnimationController,
          );

          _hideTooltips();

          setState(() {});

          _callbacks('onDragCompleted', 0);
        },
      ),
    );
  }

  void _adjustLeftHandlerPosition() {
    if (!widget.jump) {
      double position = getPositionByValue(_lowerValue);
      if (widget.axis == Axis.horizontal) {
        _leftHandlerXPosition = position > _rightHandlerXPosition!
            ? _rightHandlerXPosition
            : position;
        if (widget.lockHandlers || __lockedHandlersDragOffset > 0) {
          position = getPositionByValue(_lowerValue! + _handlersDistance);
          _rightHandlerXPosition = position < _leftHandlerXPosition!
              ? _leftHandlerXPosition
              : position;
        }
      } else {
        _leftHandlerYPosition = position > _rightHandlerYPosition!
            ? _rightHandlerYPosition
            : position;
        if (widget.lockHandlers || __lockedHandlersDragOffset > 0) {
          position = getPositionByValue(_lowerValue! + _handlersDistance);
          _rightHandlerYPosition = position < _leftHandlerYPosition!
              ? _leftHandlerYPosition
              : position;
        }
      }
    }
  }

  void _hideTooltips() {
    if (!_tooltipData.alwaysShowTooltip!) {
      _leftTooltipOpacity = 0;
      _rightTooltipOpacity = 0;
      _leftTooltipAnimationController.reset();
      _rightTooltipAnimationController.reset();
    }
  }

  Positioned _rightHandlerWidget() {
    double? bottom;
    double? right;
    if (widget.axis == Axis.horizontal) {
      bottom = 0;
    } else {
      right = 0;
    }

    return Positioned(
      key: const Key('rightHandler'),
      left: _rightHandlerXPosition,
      top: _rightHandlerYPosition,
      right: right,
      bottom: bottom,
      child: Listener(
        child: Draggable(
          axis: Axis.horizontal,
          feedback: Container(),
          child: Stack(
            clipBehavior: Clip.none,
            children: ([
              _tooltip(
                side: 'right',
                value: _outputUpperValue,
                opacity: _rightTooltipOpacity,
                animation: _rightTooltipAnimation,
              ),
              rightHandler,
            ]),
          ),
        ),
        onPointerMove: (_) {
          __dragging = true;

          if (!_tooltipData.disabled! && _tooltipData.alwaysShowTooltip == false) {
            _rightTooltipOpacity = 1;
          }
          _rightHandlerMove(_);
        },
        onPointerDown: (_) {
          if (widget.disabled || (widget.rightHandler != null && widget.rightHandler!.disabled)) {
            return;
          }
          isPointerDown = true;
          _renderBoxInitialization();

          xDragTmp = (_.position.dx - _containerLeft - _rightHandlerXPosition!);
          yDragTmp = (_.position.dy - _containerTop - _rightHandlerYPosition!);

          if (!_tooltipData.disabled! && _tooltipData.alwaysShowTooltip == false) {
            _rightTooltipOpacity = 1;
            _rightTooltipAnimationController.forward();

            if (widget.lockHandlers) {
              _leftTooltipOpacity = 1;
              _leftTooltipAnimationController.forward();
            }

            setState(() {});
          }
          if (widget.rangeSlider == false) {
            _leftHandlerScaleAnimationController!.forward();
          } else {
            _rightHandlerScaleAnimationController!.forward();
          }

          _callbacks('onDragStarted', 1);
        },
        onPointerUp: (_) {
          __dragging = isPointerDown = false;

          _adjustRightHandlerPosition();

          if (widget.disabled || (widget.rightHandler != null && widget.rightHandler!.disabled)) {
            return;
          }

          _arrangeHandlersZIndex();

          if (widget.rangeSlider == false) {
            _stopHandlerAnimation(
              animation: _leftHandlerScaleAnimation,
              controller: _leftHandlerScaleAnimationController,
            );
          } else {
            _stopHandlerAnimation(
              animation: _rightHandlerScaleAnimation,
              controller: _rightHandlerScaleAnimationController,
            );
          }

          _hideTooltips();

          setState(() {});

          _callbacks('onDragCompleted', 1);
        },
      ),
    );
  }

  void _adjustRightHandlerPosition() {
    if (!widget.jump) {
      double position = getPositionByValue(_upperValue);
      if (widget.axis == Axis.horizontal) {
        _rightHandlerXPosition = position < _leftHandlerXPosition!
            ? _leftHandlerXPosition
            : position;
        if (widget.lockHandlers) {
          position = getPositionByValue(_upperValue! - _handlersDistance);
          _leftHandlerXPosition = position > _rightHandlerXPosition!
              ? _rightHandlerXPosition
              : position;
        }
      } else {
        _rightHandlerYPosition = position < _leftHandlerYPosition!
            ? _leftHandlerYPosition
            : position;
        if (widget.lockHandlers) {
          position = getPositionByValue(_upperValue! - _handlersDistance);
          _leftHandlerYPosition = position > _rightHandlerYPosition!
              ? _rightHandlerYPosition
              : position;
        }
      }
    }
  }

  void _stopHandlerAnimation({Animation? animation, AnimationController? controller}) {
    if (widget.handlerAnimation.reverseCurve != null) {
      if (animation?.isCompleted ?? false) {
        controller?.reverse();
      } else {
        controller?.reset();
      }
    } else {
      controller?.reset();
    }
  }

  drawHandlers() {
    List<Positioned> items = [
      Function.apply(_inactiveTrack, []),
      Function.apply(_centralWidget, []),
      Function.apply(_activeTrack, []),
    ];
    items.addAll(_points);

    double tappedPositionWithPadding = 0;

    items.add(
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Opacity(
          opacity: 0,
          child: Listener(
            onPointerUp: (_) {
              __dragging = false;
              if (widget.selectByTap && !__dragging) {
                tappedPositionWithPadding = _distance();
                if (_distanceFromLeftHandler! < _distanceFromRightHandler!) {
                  if (!widget.rangeSlider) {
                    _rightHandlerMove(
                      _,
                      tappedPositionWithPadding: tappedPositionWithPadding,
                      selectedByTap: true,
                    );
                  } else {
                    _leftHandlerMove(
                      _,
                      tappedPositionWithPadding: tappedPositionWithPadding,
                      selectedByTap: true,
                    );
                  }
                } else {
                  _rightHandlerMove(
                    _,
                    tappedPositionWithPadding: tappedPositionWithPadding,
                    selectedByTap: true,
                  );
                }
              } else {
                if (_slidingByActiveTrackBar) {
                  _callbacks('onDragCompleted', 0);
                }
                if (_leftTapAndSlide) {
                  _callbacks('onDragCompleted', 0);
                }
                if (_rightTapAndSlide) {
                  _callbacks('onDragCompleted', 1);
                }
              }

              _hideTooltips();

              _stopHandlerAnimation(
                animation: _leftHandlerScaleAnimation,
                controller: _leftHandlerScaleAnimationController,
              );
              _stopHandlerAnimation(
                animation: _rightHandlerScaleAnimation,
                controller: _rightHandlerScaleAnimationController,
              );

              setState(() {});
            },
            onPointerMove: (_) {
              __dragging = true;

              if (_slidingByActiveTrackBar) {
                _trackBarSlideCallDragStated(0);
                _leftHandlerMove(_, lockedHandlersDragOffset: __lockedHandlersDragOffset);
              } else {
                tappedPositionWithPadding = _distance();

                if (widget.rangeSlider) {
                  if (_leftTapAndSlide) {
                    _trackBarSlideCallDragStated(0);
                    if (!_tooltipData.disabled! && _tooltipData.alwaysShowTooltip == false) {
                      _leftTooltipOpacity = 1;
                      _leftTooltipAnimationController.forward();
                    }
                    _leftHandlerMove(_, tappedPositionWithPadding: tappedPositionWithPadding);
                  } else {
                    _trackBarSlideCallDragStated(1);
                    if (!_tooltipData.disabled! && _tooltipData.alwaysShowTooltip == false) {
                      _rightTooltipOpacity = 1;
                      _rightTooltipAnimationController.forward();
                    }
                    _rightHandlerMove(_, tappedPositionWithPadding: tappedPositionWithPadding);
                  }
                } else {
                  _trackBarSlideCallDragStated(1);
                  if (!_tooltipData.disabled! && _tooltipData.alwaysShowTooltip == false) {
                    _rightTooltipOpacity = 1;
                    _rightTooltipAnimationController.forward();
                  }
                  _rightHandlerMove(_, tappedPositionWithPadding: tappedPositionWithPadding);
                }
              }
            },
            onPointerDown: (_) {
              _leftTapAndSlide = false;
              _rightTapAndSlide = false;
              _slidingByActiveTrackBar = false;
              __dragging = false;
              _trackBarSlideOnDragStartedCalled = false;

              double leftHandlerLastPosition, rightHandlerLastPosition;
              if (widget.axis == Axis.horizontal) {
                double lX =
                    _leftHandlerXPosition! + _handlersPadding + _touchSize! + _containerLeft;
                double rX =
                    _rightHandlerXPosition! + _handlersPadding + _touchSize! + _containerLeft;

                _distanceFromRightHandler = (rX - _.position.dx);
                _distanceFromLeftHandler = (lX - _.position.dx);

                leftHandlerLastPosition = lX;
                rightHandlerLastPosition = rX;
              } else {
                double lY = _leftHandlerYPosition! + _handlersPadding + _touchSize! + _containerTop;
                double rY =
                    _rightHandlerYPosition! + _handlersPadding + _touchSize! + _containerTop;

                _distanceFromLeftHandler = (lY - _.position.dy);
                _distanceFromRightHandler = (rY - _.position.dy);

                leftHandlerLastPosition = lY;
                rightHandlerLastPosition = rY;
              }

              if (widget.rangeSlider &&
                  widget.trackBar.activeTrackBarDraggable &&
                  _ignoreSteps.isEmpty &&
                  _distanceFromRightHandler! > 0 &&
                  _distanceFromLeftHandler! < 0) {
                _slidingByActiveTrackBar = true;
              } else {
                double thumbPosition = (widget.axis == Axis.vertical)
                    ? _.position.dy
                    : _.position.dx;
                if (_distanceFromLeftHandler!.abs() < _distanceFromRightHandler!.abs() ||
                    (_distanceFromLeftHandler == _distanceFromRightHandler &&
                        thumbPosition < leftHandlerLastPosition)) {
                  _leftTapAndSlide = true;
                }
                if (_distanceFromRightHandler!.abs() < _distanceFromLeftHandler!.abs() ||
                    (_distanceFromLeftHandler == _distanceFromRightHandler &&
                        thumbPosition < rightHandlerLastPosition)) {
                  _rightTapAndSlide = true;
                }
              }

              // if drag is within active area
              if (_distanceFromRightHandler! > 0 && _distanceFromLeftHandler! < 0) {
                if (widget.axis == Axis.horizontal) {
                  xDragTmp = 0;
                  __lockedHandlersDragOffset =
                      (_leftHandlerXPosition! + _containerLeft - _.position.dx).abs();
                } else {
                  yDragTmp = 0;
                  __lockedHandlersDragOffset =
                      (_leftHandlerYPosition! + _containerTop - _.position.dy).abs();
                }
              }
              //              }

              if (_ignoreSteps.isEmpty) {
                if ((widget.lockHandlers || __lockedHandlersDragOffset > 0) &&
                    !_tooltipData.disabled! &&
                    _tooltipData.alwaysShowTooltip == false) {
                  _leftTooltipOpacity = 1;
                  _leftTooltipAnimationController.forward();
                  _rightTooltipOpacity = 1;
                  _rightTooltipAnimationController.forward();
                }

                if ((widget.lockHandlers || __lockedHandlersDragOffset > 0)) {
                  _leftHandlerScaleAnimationController!.forward();
                  _rightHandlerScaleAnimationController!.forward();
                }
              }

              setState(() {});
            },
            child: Draggable(
              axis: widget.axis,
              feedback: Container(),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ),
    );

    //    items      ..addAll(_points);

    for (Function func in _positionedItems) {
      items.add(Function.apply(func, []));
    }

    return items;
  }

  _trackBarSlideCallDragStated(handlerIndex) {
    if (!_trackBarSlideOnDragStartedCalled) {
      _callbacks('onDragStarted', handlerIndex);
      _trackBarSlideOnDragStartedCalled = true;
    }
  }

  _distance() {
    _distanceFromLeftHandler = _distanceFromLeftHandler!.abs();
    _distanceFromRightHandler = _distanceFromRightHandler!.abs();

    if (widget.axis == Axis.horizontal) {
      return _handlersWidth! / 2 + _touchSize! - xDragTmp;
    } else {
      return _handlersHeight! / 2 + _touchSize! - yDragTmp;
    }
  }

  Positioned _tooltip({String? side, dynamic value, double? opacity, Animation? animation}) {
    if (_tooltipData.disabled! || value == '') {
      return Positioned(child: Container());
    }

    Widget prefix;
    Widget suffix;

    if (side == 'left') {
      prefix = _tooltipData.leftPrefix ?? Container();
      suffix = _tooltipData.leftSuffix ?? Container();
      if (widget.rangeSlider == false) {
        return Positioned(child: Container());
      }
    } else {
      prefix = _tooltipData.rightPrefix ?? Container();
      suffix = _tooltipData.rightSuffix ?? Container();
    }
    String numberFormat = value.toString();
    if (_tooltipData.format != null) {
      numberFormat = _tooltipData.format!(numberFormat);
    }

    List<Widget> children = [prefix, Text(numberFormat, style: _tooltipData.textStyle), suffix];

    Widget tooltipHolderWidget = Column(mainAxisSize: MainAxisSize.min, children: children);
    if (_tooltipData.direction == FlutterSliderTooltipDirection.top) {
      tooltipHolderWidget = Row(mainAxisSize: MainAxisSize.max, children: children);
    }

    Widget tooltipWidget = IgnorePointer(
      child: Center(
        child: FittedBox(
          child: Container(
            key: (side == 'left') ? leftTooltipKey : rightTooltipKey,
            child: (widget.tooltip != null && widget.tooltip!.custom != null)
                ? widget.tooltip!.custom!(value)
                : Container(
                    padding: const EdgeInsets.all(8),
                    decoration: _tooltipData.boxStyle!.decoration,
                    foregroundDecoration: _tooltipData.boxStyle!.foregroundDecoration,
                    transform: _tooltipData.boxStyle!.transform,
                    child: tooltipHolderWidget,
                  ),
          ),
        ),
      ),
    );

    double? top, right, bottom, left;

    switch (_tooltipData.direction) {
      case FlutterSliderTooltipDirection.top:
        {
          top = 0.0;
          left = 0.0;
          right = 0.0;

          break;
        }
      case FlutterSliderTooltipDirection.left:
        {
          left = 0.0;
          top = 0.0;
          bottom = 0.0;

          break;
        }
      case FlutterSliderTooltipDirection.right:
        {
          right = 0.0;
          top = 0.0;
          bottom = 0.0;

          break;
        }
      default:
        break;
    }

    if (_tooltipData.positionOffset != null) {
      if (_tooltipData.positionOffset!.top != null) {
        top = (top ?? 0.0) + _tooltipData.positionOffset!.top!;
      }
      if (_tooltipData.positionOffset!.left != null) {
        left = (left ?? 0.0) + _tooltipData.positionOffset!.left!;
      }
      if (_tooltipData.positionOffset!.right != null) {
        right = (right ?? 0.0) + _tooltipData.positionOffset!.right!;
      }
      if (_tooltipData.positionOffset!.bottom != null) {
        bottom = (bottom ?? 0.0) + _tooltipData.positionOffset!.bottom!;
      }
    }

    tooltipWidget = SlideTransition(position: animation as Animation<Offset>, child: tooltipWidget);

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Opacity(
        opacity: opacity!,
        child: Center(child: tooltipWidget),
      ),
    );
  }

  Positioned _inactiveTrack() {
    BoxDecoration boxDecoration = widget.trackBar.inactiveTrackBar ?? const BoxDecoration();

    Color trackBarColor = boxDecoration.color ?? const Color(0x110000ff);
    if (widget.disabled) {
      trackBarColor = widget.trackBar.inactiveDisabledTrackBarColor;
    }

    double? top, bottom, left, right, width, height;
    top = left = right = width = height = 0;
    right = bottom = null;

    if (widget.axis == Axis.horizontal) {
      bottom = 0;
      left = _handlersPadding;
      width = _containerWidthWithoutPadding;
      height = widget.trackBar.inactiveTrackBarHeight;
      top = 0;
    } else {
      right = 0;
      height = _containerHeightWithoutPadding;
      top = _handlersPadding;
      width = widget.trackBar.inactiveTrackBarHeight;
    }

    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Center(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: trackBarColor,
            backgroundBlendMode: boxDecoration.backgroundBlendMode,
            shape: boxDecoration.shape,
            gradient: boxDecoration.gradient,
            border: boxDecoration.border,
            borderRadius: boxDecoration.borderRadius,
            boxShadow: boxDecoration.boxShadow,
            image: boxDecoration.image,
          ),
        ),
      ),
    );
  }

  /// This function is used to get the decoration of the trackbar.
  /// If the user has not provided any decoration for the trackbar, we will use a default decoration.
  /// The default decoration is defined in the trackbar class.
  /// If the user has provided a decoration, we will use the decoration that the user has provided.
  Positioned _activeTrack() {
    BoxDecoration boxDecoration = widget.trackBar.activeTrackBar ?? const BoxDecoration();

    Color trackBarColor = boxDecoration.color ?? const Color(0xff2196F3);
    if (widget.disabled) {
      trackBarColor = widget.trackBar.activeDisabledTrackBarColor;
    }

    double? top, bottom, left, right, width, height;
    top = left = width = height = 0;
    right = bottom = null;

    if (widget.axis == Axis.horizontal) {
      bottom = 0;
      height = widget.trackBar.activeTrackBarHeight;
      if (!widget.centeredOrigin || widget.rangeSlider) {
        width = _rightHandlerXPosition! - _leftHandlerXPosition!;
        left = _leftHandlerXPosition! + _handlersWidth! / 2 + _touchSize!;

        if (widget.rtl == true && widget.rangeSlider == false) {
          left = null;
          right = _handlersWidth! / 2;
          width = _containerWidthWithoutPadding! - _rightHandlerXPosition! - _touchSize!;
        }
      } else {
        if (_containerWidthWithoutPadding! / 2 - _touchSize! > _rightHandlerXPosition!) {
          width = _containerWidthWithoutPadding! / 2 - _rightHandlerXPosition! - _touchSize!;
          left = _rightHandlerXPosition! + _handlersWidth! / 2 + _touchSize!;
        } else {
          left = _containerWidthWithoutPadding! / 2 + _handlersPadding;
          width = _rightHandlerXPosition! + _touchSize! - _containerWidthWithoutPadding! / 2;
        }
      }
    } else {
      right = 0;
      width = widget.trackBar.activeTrackBarHeight;

      if (!widget.centeredOrigin || widget.rangeSlider) {
        height = _rightHandlerYPosition! - _leftHandlerYPosition!;
        top = _leftHandlerYPosition! + _handlersHeight! / 2 + _touchSize!;
        if (widget.rtl == true && widget.rangeSlider == false) {
          top = null;
          bottom = _handlersHeight! / 2;
          height = _containerHeightWithoutPadding! - _rightHandlerYPosition! - _touchSize!;
        }
      } else {
        if (_containerHeightWithoutPadding! / 2 - _touchSize! > _rightHandlerYPosition!) {
          height = _containerHeightWithoutPadding! / 2 - _rightHandlerYPosition! - _touchSize!;
          top = _rightHandlerYPosition! + _handlersHeight! / 2 + _touchSize!;
        } else {
          top = _containerHeightWithoutPadding! / 2 + _handlersPadding;
          height = _rightHandlerYPosition! + _touchSize! - _containerHeightWithoutPadding! / 2;
        }
      }
    }

    width = (width < 0) ? 0 : width;
    height = (height < 0) ? 0 : height;

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Center(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: trackBarColor,
            backgroundBlendMode: boxDecoration.backgroundBlendMode,
            shape: boxDecoration.shape,
            gradient: boxDecoration.gradient,
            border: boxDecoration.border,
            borderRadius: boxDecoration.borderRadius,
            boxShadow: boxDecoration.boxShadow,
            image: boxDecoration.image,
          ),
        ),
      ),
    );
  }

  /// Position the central widget at the center of the track bar.
  Positioned _centralWidget() {
    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      child: Center(child: widget.trackBar.centralWidget ?? Container()),
    );
  }

  /// This function is used to call the callbacks
  /// This function is called from the [handleDragStart], [handleDragUpdate], and [handleDragEnd] functions
  void _callbacks(String callbackName, int handlerIndex) {
    dynamic lowerValue = _outputLowerValue;
    dynamic upperValue = _outputUpperValue;
    if (widget.rtl == true || widget.rangeSlider == false) {
      lowerValue = _outputUpperValue;
      upperValue = _outputLowerValue;
    }

    switch (callbackName) {
      case 'onDragging':
        if (widget.onDragging != null) {
          widget.onDragging!(handlerIndex, lowerValue, upperValue);
        }
        break;
      case 'onDragCompleted':
        if (widget.onDragCompleted != null) {
          widget.onDragCompleted!(handlerIndex, lowerValue, upperValue);
        }
        break;
      case 'onDragStarted':
        if (widget.onDragStarted != null) {
          widget.onDragStarted!(handlerIndex, lowerValue, upperValue);
        }
        break;
    }
  }

  /// Returns the value that should be displayed on the slider.
  /// If the slider has fixed values, the value should be one of those.
  /// Otherwise, the value should be parsed to the correct decimal scale.
  dynamic _displayRealValue(double? value) {
    if (_fixedValues.isNotEmpty) {
      return _fixedValues[value!.toInt()].value;
    }

    return double.parse((value! + _widgetMin!).toStringAsFixed(_decimalScale));
  }

  /// This function arranges the z-index of the handlers, so that the lower value
  /// handler is always in front of the higher value handler.
  void _arrangeHandlersZIndex() {
    if (_lowerValue! >= (_realMax! / 2)) {
      _positionedItems = [_rightHandlerWidget, _leftHandlerWidget];
    } else {
      _positionedItems = [_leftHandlerWidget, _rightHandlerWidget];
    }
  }

  /// This function calculates the position of the container in the screen.
  /// It is called each time the screen is rendered.
  /// The position is calculated by getting the size of the screen and
  /// subtracting the size of the container, then dividing by two.
  /// This will give you the position of the container in the center of the screen.
  void _renderBoxInitialization() {
    if (_containerLeft <= 0 ||
        (MediaQuery.of(context).size.width - _constraintMaxWidth) <= _containerLeft) {
      RenderBox containerRenderBox = containerKey.currentContext!.findRenderObject() as RenderBox;
      _containerLeft = containerRenderBox.localToGlobal(Offset.zero).dx;
    }
    if (_containerTop <= 0 ||
        (MediaQuery.of(context).size.height - _constraintMaxHeight) <= _containerTop) {
      RenderBox containerRenderBox = containerKey.currentContext!.findRenderObject() as RenderBox;
      _containerTop = containerRenderBox.localToGlobal(Offset.zero).dy;
    }
  }
}
