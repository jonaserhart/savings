import 'package:flutter/material.dart';
import 'package:savings/manage/add_saving.dart';

class ActionButton extends StatefulWidget {
  ActionButton();
  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  bool _isOpened = false;
  AnimationController _animationController;
  Animation<Color> _animateColor;
  Animation<double> _animateIcon;
  Curve _curve = Curves.easeOut;
  Animation<Offset> _offsetAnimationNewGoal;

  void onSubmit() {

  }

  @override
  void initState() {
    _animationController =
    AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )
      ..addListener(() {
        setState(() {});
      });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animateColor = ColorTween(
      begin: Colors.white,
      end: Colors.redAccent,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: _curve,
      ),
    ));
    _offsetAnimationNewGoal = Tween<Offset>(
      begin: Offset(1, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutExpo,
    ));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!_isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    _isOpened = !_isOpened;
  }

  Widget newGoalChip() {
    return new SlideTransition(
      position: _offsetAnimationNewGoal,
      child: AnimatedOpacity(
        opacity: _isOpened ? 1 : 0,
        duration: Duration(milliseconds: 300),
        child: Container(
            child: ActionChip(
              onPressed: () {

              },
              label: Text('New goal'),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        newGoalChip(),
        Padding(padding: EdgeInsets.only(top: 20)),
        FloatingActionButton(
            backgroundColor: _animateColor.value,
            onPressed: animate,
            tooltip: 'Toggle',
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animateIcon,
            )),
      ],
    );
  }
}
