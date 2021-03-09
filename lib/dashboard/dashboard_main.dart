import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:savings/Storage.dart';
import 'package:savings/dashboard/savings_chart.dart';
import 'package:savings/dashboard/savings_sum.dart';

class DashboardMain extends StatefulWidget {
  @override
  _DashboardMainState createState() => _DashboardMainState();
}

class _DashboardMainState extends State<DashboardMain> {
  var _storageProvider = Storage.getProvider();
  String displayName = '';
  @override
  void initState() {
    _storageProvider.getDisplayName().then((value) {
      setState(() {
        displayName = value;
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: Duration(milliseconds: 250),
      child: Scaffold(
        body: Builder(builder: (BuildContext context) {
          return ListView(
            padding: EdgeInsets.only(top: 30, left: 30),
            children: [
              Padding(
                padding: EdgeInsets.only(top: 30, right: 10),
                child: Text('Hello $displayName',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, right: 30),
                child: SavingsSum(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, right: 30),
                child: SavingsChart(),
              ),
            ],
          );
        }),
      ),
    );
  }
}
