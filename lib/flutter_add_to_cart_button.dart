import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

enum AddToCartButtonStateId { idle, loading, done }

class AddToCartButton extends StatefulWidget {
  final Widget trolley;
  final Widget text;
  final Widget check;
  final Function(AddToCartButtonStateId id) onPressed;
  final Duration duration;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double streetLineHeight;
  final double streetLineDashWidth;
  final double trolleyLeftMargin;
  final AddToCartButtonStateId stateId;

  const AddToCartButton({
    Key? key,
    this.duration: const Duration(milliseconds: 3000),
    required this.trolley,
    required this.text,
    required this.check,
    required this.onPressed,
    this.borderRadius,
    this.backgroundColor,
    this.streetLineHeight: 2,
    this.streetLineDashWidth: 12,
    this.trolleyLeftMargin: 12,
    this.stateId = AddToCartButtonStateId.idle,
  }) : super(key: key);

  @override
  _AddToCartButtonState createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton>
    with TickerProviderStateMixin {
  final TweenSequence<double> _bounceScaleTween = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 0.3),
    TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.2), weight: 0.3),
    TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 0.4),
  ]);
  late Animatable<double> _disappearFirstTween;

  late AnimationController _firstController;
  late AnimationController _crossController;
  late AnimationController _secondController;
  AddToCartButtonStateId stateId = AddToCartButtonStateId.idle;

  @override
  void initState() {
    _disappearFirstTween = Tween<double>(begin: 1.0, end: 0.0);

    final duration = widget.duration * 0.1;
    _firstController = AnimationController(vsync: this, duration: duration);
    _firstController.addListener(() {
      setState(() {});
    });
    _crossController = AnimationController(vsync: this, duration: duration);
    _crossController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _secondController.forward(from: 0.0);
      }
    });
    _crossController.addListener(() {
      setState(() {});
    });
    _secondController = AnimationController(vsync: this, duration: duration);
    _secondController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _firstController.dispose();
    _crossController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AddToCartButton oldWidget) {
    if (oldWidget.stateId != widget.stateId) {
      _updateState(widget.stateId);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (stateId == AddToCartButtonStateId.done) _buildSecond(context),
        if (stateId != AddToCartButtonStateId.done ||
            _crossController.isAnimating)
          _buildFirst(context),
      ],
    );
  }

  Widget _buildFirst(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(24);
    final double height =
        math.max(borderRadius.topLeft.y, borderRadius.topRight.y) +
            math.max(borderRadius.bottomLeft.y, borderRadius.bottomRight.y);
    return ScaleTransition(
      scale: _bounceScaleTween.animate(_firstController),
      child: ElevatedButton(
        onPressed: this.onPressedFirst,
        style: ButtonStyle(
          shape:
              MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
            borderRadius: borderRadius,
          )),
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
          elevation: MaterialStateProperty.all<double>(0.0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: MaterialStateProperty.all<Size>(Size.zero),
          backgroundColor: widget.backgroundColor != null
              ? MaterialStateProperty.all<Color>(widget.backgroundColor!)
              : null,
        ),
        child: SizeTransition(
          axis: Axis.horizontal,
          sizeFactor: _disappearFirstTween.animate(_crossController),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: height,
                child: FadeTransition(
                  opacity: _disappearFirstTween
                      .chain(CurveTween(curve: Curves.fastLinearToSlowEaseIn))
                      .animate(_crossController),
                  child: _RunningTrolley(
                    stateId: stateId,
                    trolley: widget.trolley,
                    duration: widget.duration,
                    listener: this.onRunningTrolley,
                    streetLineHeight: widget.streetLineHeight,
                    streetLineDashWidth: widget.streetLineDashWidth,
                    trolleyLeftMargin: widget.trolleyLeftMargin,
                  ),
                ),
              ),
              FadeTransition(
                opacity: _disappearFirstTween
                    .chain(CurveTween(curve: Curves.fastLinearToSlowEaseIn))
                    .animate(_firstController),
                child: Center(
                  child: widget.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecond(BuildContext context) {
    return ScaleTransition(
      scale: _bounceScaleTween.animate(_secondController),
      child: ElevatedButton(
        onPressed: this.onPressedSecond,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<OutlinedBorder>(CircleBorder()),
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
          elevation: MaterialStateProperty.all<double>(0.0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: MaterialStateProperty.all<Size>(Size.zero),
          backgroundColor: widget.backgroundColor != null
              ? MaterialStateProperty.all<Color>(widget.backgroundColor!)
              : null,
        ),
        child: widget.check,
      ),
    );
  }

  void _updateState(AddToCartButtonStateId stateId) {
    this.stateId = stateId;
    switch (stateId) {
      case AddToCartButtonStateId.loading:
        _loading();
        break;
      case AddToCartButtonStateId.done:
        _done();
        break;
      default:
        _reset();
        break;
    }
  }

  void _loading() {
    _firstController.forward(from: 0.0);
  }

  void _done() {
    _crossController.forward(from: 0.0);
  }

  void _reset() {
    _firstController.reset();
    _secondController.reset();
    _crossController.reverse();
  }

  void onRunningTrolley(AnimationController controller) {}

  void onPressedFirst() {
    if (stateId == AddToCartButtonStateId.idle) {
      widget.onPressed(stateId);
    }
  }

  void onPressedSecond() {
    if (stateId == AddToCartButtonStateId.done) {
      widget.onPressed(stateId);
    }
  }
}

class _RunningTrolley extends StatefulWidget {
  final Function(AnimationController controller)? listener;
  final Widget trolley;
  final Duration duration;
  final AddToCartButtonStateId stateId;
  final double streetLineHeight;
  final double streetLineDashWidth;
  final double trolleyLeftMargin;

  const _RunningTrolley({
    Key? key,
    this.listener,
    required this.trolley,
    required this.duration,
    this.stateId: AddToCartButtonStateId.idle,
    required this.streetLineHeight,
    required this.streetLineDashWidth,
    required this.trolleyLeftMargin,
  }) : super(key: key);

  @override
  _RunningTrolleyState createState() => _RunningTrolleyState();
}

class _RunningTrolleyState extends State<_RunningTrolley>
    with TickerProviderStateMixin {
  late AnimationController _streetController;
  late AnimationController _trolleyController;
  late AnimationController _disappearController;

  late TweenSequence<double> _trolleyScaleTween;
  late TweenSequence<double> _trolleyRotateTween;
  TweenSequence<Offset>? _trolleyTranslateTween;
  late TweenSequence<double> _streetTween;
  late Animatable<double> _disappearTween;

  @override
  void initState() {
    _disappearTween = Tween<double>(begin: 1.0, end: 0.0)
        .chain(CurveTween(curve: Curves.linear));

    _trolleyScaleTween = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 0.1),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 0.1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 0.8),
    ]);
    _trolleyRotateTween = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: _convertDegToRad(-20.0)), weight: 0.1),
      TweenSequenceItem(
          tween: Tween(
              begin: _convertDegToRad(-20.0), end: _convertDegToRad(20.0)),
          weight: 0.1),
      TweenSequenceItem(
          tween: Tween(begin: _convertDegToRad(20.0), end: 0.0), weight: 0.8),
    ]);
    _streetTween = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 0.1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -1.0), weight: 0.9),
    ]);

    _streetController =
        AnimationController(vsync: this, duration: widget.duration);
    _streetController.addListener(() {
      setState(() {});
      if (widget.listener != null) widget.listener!(_streetController);
    });
    final trolleyDuration = widget.duration * 0.8;
    _trolleyController =
        AnimationController(vsync: this, duration: trolleyDuration);
    _trolleyController.addListener(() {
      setState(() {});
    });
    final disappearDuration = widget.duration * 0.1;
    _disappearController =
        AnimationController(vsync: this, duration: disappearDuration);
    _disappearController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _RunningTrolley oldWidget) {
    if (oldWidget.stateId != widget.stateId) {
      switch (widget.stateId) {
        case AddToCartButtonStateId.loading:
          _start();
          break;
        case AddToCartButtonStateId.done:
          _disappear();
          break;
        default:
          _reset();
          break;
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _streetController.dispose();
    _trolleyController.dispose();
    _disappearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var box = context.findRenderObject() as RenderBox?;
    final double width = box?.hasSize == true ? box!.size.width : 0;
    if (_trolleyTranslateTween == null && width > 0) {
      final left = Offset(widget.trolleyLeftMargin, 0.0);
      _trolleyTranslateTween = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: left, end: left), weight: 0.1),
        TweenSequenceItem(
            tween: Tween(begin: left, end: Offset(width, 0.0)), weight: 0.9),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Transform.translate(
              offset: _trolleyTranslateTween == null
                  ? Offset.zero
                  : _trolleyTranslateTween!
                      .chain(CurveTween(curve: Curves.fastOutSlowIn))
                      .evaluate(_trolleyController),
              child: Transform.rotate(
                angle: _trolleyRotateTween.evaluate(_trolleyController),
                child: ScaleTransition(
                  scale: _trolleyScaleTween.animate(_trolleyController),
                  alignment: Alignment.bottomLeft,
                  child: width > 0 ? widget.trolley : SizedBox(),
                ),
              ),
            ),
          ],
        ),
        FadeTransition(
          opacity: _disappearTween.animate(_disappearController),
          child: Container(
            height: widget.streetLineHeight,
            child: CustomPaint(
              painter: _StreetLinePainter(
                dashWidth: widget.streetLineDashWidth,
                translateFactor: _streetTween
                    .chain(CurveTween(curve: Curves.fastOutSlowIn))
                    .evaluate(_streetController),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _start() {
    _disappearController.stop();
    _disappearController.reset();

    _trolleyController.forward(from: 0.0);
    _streetController.forward(from: 0.0);
  }

  void _reset() {
    _disappearController.stop();
    _disappearController.reset();
    _trolleyController.stop();
    _trolleyController.reset();
    _streetController.stop();
    _streetController.reset();
  }

  void _disappear() {
    Future.delayed(_disappearController.duration!, () {
      _disappearController.forward(from: 0.0);
    });
  }
}

class _StreetLinePainter extends CustomPainter {
  final double dashWidth;
  final double translateFactor;

  _StreetLinePainter({
    this.dashWidth: 12.0,
    this.translateFactor: 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;
    final gapPaint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = paint.strokeWidth
      ..strokeCap = StrokeCap.round;
    final distance = size.width * 3;
    final numberOfHorizontalDash = distance ~/ dashWidth + 2;
    var left = size.centerLeft(Offset.zero);
    left +=
        Offset(size.width + dashWidth * 2 + translateFactor * distance, 0.0);

    for (int i = 0; i < numberOfHorizontalDash; i++) {
      canvas.drawLine(
          left + Offset(i * dashWidth, 0),
          left + Offset(i * dashWidth + dashWidth, 0),
          (i % 2 == 0) ? paint : gapPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

double _convertDegToRad(double deg) => deg * math.pi / 180.0;
