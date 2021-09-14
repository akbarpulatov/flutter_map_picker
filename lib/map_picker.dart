library map_picker;

import 'package:flutter/material.dart';

class MapPickerController {
  Function? mapMoving;
  Function? mapFinishedMoving;
}

class MapPicker extends StatefulWidget {
  final Widget child;
  final Widget? iconWidget;
  final bool showDot;
  final MapPickerController mapPickerController;

  const MapPicker({
    Key? key,
    required this.child,
    required this.mapPickerController,
    this.iconWidget,
    this.showDot = true,
  }) : super(key: key);

  @override
  _MapPickerState createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker>
    with SingleTickerProviderStateMixin {
  static const double _dotRadius = 2.2;

  late AnimationController animationController;
  late Animation<double> translateAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    widget.mapPickerController.mapMoving = mapMoving;
    widget.mapPickerController.mapFinishedMoving = mapFinishedMoving;

    translateAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.ease,
    ));
  }

  void mapMoving() {
    if (!animationController.isAnimating && !animationController.isCompleted) {
      animationController.forward();
    }
  }

  void mapFinishedMoving() {
    animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            widget.child,
            Positioned(
              bottom: constraints.maxHeight * 0.5 - 10,
              child: AnimatedBuilder(
                  animation: animationController,
                  builder: (context, snapshot) {
                    return Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        if (widget.showDot)
                          Container(
                            width: _dotRadius,
                            height: _dotRadius,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(_dotRadius),
                            ),
                          ),
                        Transform.translate(
                          offset: Offset(0, -15 * translateAnimation.value),
                          child: widget.iconWidget,
                        ),
                      ],
                    );
                  }),
            ),
          ],
        );
      },
    );
  }
}
