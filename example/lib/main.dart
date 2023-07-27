import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/handler_animation.dart';
import 'package:another_xlider/models/hatch_mark.dart';
import 'package:another_xlider/models/hatch_mark_label.dart';
import 'package:another_xlider/models/ignore_steps.dart';
import 'package:another_xlider/models/slider_step.dart';
import 'package:another_xlider/models/tooltip/tooltip.dart';
import 'package:another_xlider/models/trackbar.dart';
import 'package:another_xlider/widgets/sized_box.dart';
import 'package:flutter/material.dart';
import 'package:another_xlider/another_xlider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        //
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Xlider Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _lowerValue = 50;
  double _upperValue = 200;

  double _lv = 50.0;
  double _uv = 250.0;

  double _lv1 = 1000.0;
  double _uv1 = 15000.0;

  double _lv2 = 3000.0;
  double _uv2 = 17000.0;

  double _lv3 = 3000;
  double _uv3 = 3500;

  double _lv4 = 0;
  double _uv4 = 2500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _singleSlider(),
            _singleSlider(rtl: true),
            _rangeSlider(),
            _rangeSliderIgnoreSteps(),
            _customHandler(),
            _tooltipExample(),
            _hatchMarkWithLabels(),
          ],
        ),
      ),
    );
  }

  FlutterSliderHandler customHandler(IconData icon) {
    return FlutterSliderHandler(
      decoration: BoxDecoration(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.blue.withOpacity(0.3), spreadRadius: 0.05, blurRadius: 5, offset: Offset(0, 1))
          ],
        ),
        child: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3), shape: BoxShape.circle),
          child: Icon(
            icon,
            color: Colors.white,
            size: 23,
          ),
        ),
      ),
    );
  }

  _singleSlider({bool rtl = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text('Single Slider ' + (rtl ? 'RTL' : 'LTR')),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: FlutterSlider(
                handlerWidth: 30,
                rtl: rtl,
                handlerHeight: 30,
                values: [_lowerValue],
                max: 100,
                min: 0,
                tooltip: FlutterSliderTooltip(
                  disabled: true,
                ),
                trackBar: FlutterSliderTrackBar(activeTrackBar: BoxDecoration(color: Colors.blue.withOpacity(0.5))),
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  setState(() {
                    _lowerValue = lowerValue;
                  });
                },
                onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                  setState(() {
                    _lowerValue = lowerValue;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                child: Text(
                  _lowerValue.toInt().toString() + ' %',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _rangeSlider() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text('Range Slider'),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: FlutterSlider(
              values: [_lv, _uv],
              rangeSlider: true,
              max: 500,
              min: 0,
              onDragging: (_handlerIndex, _lowerValue, _upperValue) {
                setState(() {
                  _lv = _lowerValue;
                  _uv = _upperValue;
                });
              },
            )),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                child: Text(
                  _lv.toInt().toString() + ' - ' + _uv.toInt().toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _rangeSliderIgnoreSteps() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text('Range Slider - Ignore Steps (8000 - 12000) and (18000 - 22000)'),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: FlutterSlider(
              values: [_lv1, _uv1],
              rangeSlider: true,
              ignoreSteps: [
                FlutterSliderIgnoreSteps(from: 8000, to: 12000),
                FlutterSliderIgnoreSteps(from: 18000, to: 22000),
              ],
              max: 25000,
              min: 0,
              step: FlutterSliderStep(step: 100),
              jump: true,
              trackBar: FlutterSliderTrackBar(
                activeTrackBarHeight: 5,
              ),
              tooltip: FlutterSliderTooltip(
                textStyle: TextStyle(fontSize: 17, color: Colors.lightBlue),
              ),
              handler: FlutterSliderHandler(
                decoration: BoxDecoration(),
                child: Material(
                  type: MaterialType.canvas,
                  color: Colors.orange,
                  elevation: 10,
                  child: Container(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.adjust,
                        size: 25,
                      )),
                ),
              ),
              rightHandler: FlutterSliderHandler(
                child: Icon(
                  Icons.chevron_left,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              onDragging: (_handlerIndex, _lowerValue, _upperValue) {
                setState(() {
                  _lv1 = _lowerValue;
                  _uv1 = _upperValue;
                });
              },
            )),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                child: Text(
                  _lv1.toInt().toString() + ' - ' + _uv1.toInt().toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _customHandler() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text('Range Slider - Custom Handler'),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: FlutterSlider(
              values: [_lv2, _uv2],
              rangeSlider: true,
              max: 25000,
              min: 0,
              step: FlutterSliderStep(step: 100),
              jump: true,
              trackBar: FlutterSliderTrackBar(
                inactiveTrackBarHeight: 2,
                activeTrackBarHeight: 3,
              ),
              disabled: false,
              handler: customHandler(Icons.chevron_right),
              rightHandler: customHandler(Icons.chevron_left),
              tooltip: FlutterSliderTooltip(
                leftPrefix: Icon(
                  Icons.attach_money,
                  size: 19,
                  color: Colors.black45,
                ),
                rightSuffix: Icon(
                  Icons.attach_money,
                  size: 19,
                  color: Colors.black45,
                ),
                textStyle: TextStyle(fontSize: 17, color: Colors.black45),
              ),
              onDragging: (_handlerIndex, _lowerValue, _upperValue) {
                setState(() {
                  _lv2 = _lowerValue;
                  _uv2 = _upperValue;
                });
              },
            )),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                child: Text(
                  _lv2.toInt().toString() + ' - ' + _uv2.toInt().toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _tooltipExample() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text('Range Slider - tooltip example'),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: FlutterSlider(
              key: Key('3343'),
              values: [_lv3, _uv3],
              rangeSlider: true,
              tooltip: FlutterSliderTooltip(
                alwaysShowTooltip: true,
              ),
              max: 4000,
              min: 0,
              step: FlutterSliderStep(step: 20),
              jump: true,
              onDragging: (_handlerIndex, _lowerValue, _upperValue) {
                setState(() {
                  _lv3 = _lowerValue;
                  _uv3 = _upperValue;
                });
              },
            )),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                child: Text(
                  _lv3.toInt().toString() + ' - ' + _uv3.toInt().toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _hatchMarkWithLabels() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text('Range Slider - Hatch Mark with labels'),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: FlutterSlider(
              key: Key('3343'),
              values: [_lv4, _uv4],
              touchSize: 50.0,
              handlerAnimation: FlutterSliderHandlerAnimation(
                  reverseCurve: Curves.bounceOut, curve: Curves.bounceIn, duration: Duration(milliseconds: 500), scale: 1.5),
              rangeSlider: true,
              ignoreSteps: [
                FlutterSliderIgnoreSteps(from: 500, to: 1000),
              ],
              hatchMark: FlutterSliderHatchMark(
                displayLines: true,
                linesDistanceFromTrackBar: 10,
                labelBox: FlutterSliderSizedBox(
                  width: 40,
                  height: 20,
                  foregroundDecoration: BoxDecoration(color: Color.fromARGB(39, 54, 165, 244)),
                  transform: Matrix4.translationValues(0, 30, 0),
                ),
                density: 0.5,
                labels: [
                  FlutterSliderHatchMarkLabel(percent: 0, label: Text('Start')),
                  FlutterSliderHatchMarkLabel(percent: 20, label: Text('N/A')),
                  FlutterSliderHatchMarkLabel(percent: 10, label: Text('10 %')),
                  FlutterSliderHatchMarkLabel(percent: 50, label: Text('50 %')),
                  FlutterSliderHatchMarkLabel(percent: 80, label: Text('80 %')),
                  FlutterSliderHatchMarkLabel(percent: 100, label: Text('Finish')),
                ],
              ),
              rightHandler: FlutterSliderHandler(
                decoration: BoxDecoration(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              tooltip: FlutterSliderTooltip(
                alwaysShowTooltip: false,
              ),
              max: 4000,
              min: 0,
              step: FlutterSliderStep(step: 100),
              jump: true,
              onDragging: (_handlerIndex, _lowerValue, _upperValue) {
                setState(() {
                  _lv4 = _lowerValue;
                  _uv4 = _upperValue;
                });
              },
            )),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                child: Text(
                  _lv4.toInt().toString() + ' - ' + _uv4.toInt().toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
