library map_picker;

import 'package:flutter/material.dart';

/// Map picker is controlled with MapPickerController. Map pin is lifted up
/// whenever mapMoving() is called, and will be down when mapFinishedMoving()
/// is called.
class MapPickerController {
  Function? mapMoving;
  Function? mapFinishedMoving;
}

/// MapPicker widget is main widget that gets map as a child.
/// It does not restrict user from using maps other than google map.
/// [MapPicker] is controlled with [MapPickerController] class object
class MapPicker extends StatefulWidget {
  /// Map widget, Google, Yandex Map or any other map can be used, see example
  final Widget child;

  /// Map pin widget in the center of the screen. [iconWidget] is used with
  /// animation controller
  final Widget? iconWidget;

  /// default value is true, defines, if there is a dot, at the bottom of the pin
  final bool showDot;

  /// [MapPicker] can be controller with [MapPickerController] object.
  /// you can call mapPickerController.mapMoving!() and
  /// mapPickerController.mapFinishedMoving!() for controlling the Map Pin.
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

  /// Start of animation when map starts dragging by user, checks the state
  /// before firing animation, thus optimizing for rendering purposes
  void mapMoving() {
    if (!animationController.isAnimating && !animationController.isCompleted) {
      animationController.forward();
    }
  }

  /// down the Pin whenever the map is released and goes to idle position
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
