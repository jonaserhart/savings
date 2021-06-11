import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:savings/goals/AnimatedFloatingActionButton.dart';

class Goals extends StatefulWidget {
  @override
  _GoalsState createState() => _GoalsState();
}

class _GoalsState extends State<Goals> {
  @override
  Widget build(BuildContext context) {
    return FadeIn(
        duration: Duration(milliseconds: 250),
        child: Scaffold(
          floatingActionButton: ActionButton(),
          body: Builder(builder: (BuildContext context) {
            return Container(
              padding:
                  EdgeInsets.only(top: 30, left: 30, right: 10, bottom: 40),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 30, right: 90, bottom: 20),
                    child: Text(
                      'Goals',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ],
              ),
            );
          }),
        ));
  }
}
