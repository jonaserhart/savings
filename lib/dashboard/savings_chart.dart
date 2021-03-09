import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:savings/Storage.dart';
import 'package:savings/classes/Saving.dart';

class SavingsChart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SavingsChartState();
}

class _SavingsChartState extends State<SavingsChart> {
  var _storageProvider = Storage.getProvider();
  List<double> _amounts = [0,0,0,0,0,0];
  double _maxAmount = 20;
  bool checkSavingDateForIndex (Saving element, int index) {
    var actualDate = DateTime.now();
    var dateAsDouble = double.parse(element.date);
    if (dateAsDouble == null)
      return false;
    if (
    DateTime.now().add(Duration(days: -(index + 1))).millisecondsSinceEpoch < dateAsDouble
        && dateAsDouble < new DateTime(actualDate.year, actualDate.month, actualDate.day - index, 23, 59, 59).millisecondsSinceEpoch
    ) {
      return true;
    }
    return false;
  }
  @override
  void initState() {
    super.initState();

    _storageProvider.getLastWeeksSavings()
        .then((value) {
      var list = value as List<Saving>;
      List<double> amountList = [0,0,0,0,0,0];
      for (int i = 0; i < 6; i++) {
        var savings = list.where((element) => checkSavingDateForIndex(element, i));
        double sum = 0;
        savings.forEach((e) => sum += e.amount ?? 0);
        amountList[i] = sum;
      }
      var maxA = amountList.reduce(max);
      setState(() {
        _amounts = amountList;
        _maxAmount = maxA + 10;
      });
      print (_maxAmount);

    });
  }
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: Theme.of(context).cardColor,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 0, top: 10),
              child: Text('Savings last week',
                  style: TextStyle(fontSize: 20)),
            ),
            BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _maxAmount,
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.transparent,
                    tooltipPadding: const EdgeInsets.all(0),
                    tooltipBottomMargin: 8,
                    getTooltipItem: (
                        BarChartGroupData group,
                        int groupIndex,
                        BarChartRodData rod,
                        int rodIndex,
                        ) {
                      return BarTooltipItem(
                        rod.y.round().toString(),
                        TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTextStyles: (value) => const TextStyle(
                        color: Color(0xff7589a2), fontWeight: FontWeight.bold, fontSize: 14),
                    margin: 20,
                    getTitles: (double value) {
                      switch (value.toInt()) {
                        case 0:
                          return 'Mon';
                        case 1:
                          return 'Tue';
                        case 2:
                          return 'Wed';
                        case 3:
                          return 'Thu';
                        case 4:
                          return 'Fri';
                        case 5:
                          return 'Sat';
                        case 6:
                          return 'Sun';
                        default:
                          return '';
                      }
                    },
                  ),
                  leftTitles: SideTitles(showTitles: false),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: [
                  BarChartGroupData(
                    x: (DateTime.now().weekday - 6) % 7,
                    barRods: [
                      BarChartRodData(y: _amounts[5], colors: [Colors.lightBlueAccent, Colors.greenAccent])
                    ],
                    showingTooltipIndicators: [0],
                  ),
                  BarChartGroupData(
                    x: (DateTime.now().weekday - 5) % 7,
                    barRods: [
                      BarChartRodData(y: _amounts[4], colors: [Colors.lightBlueAccent, Colors.greenAccent])
                    ],
                    showingTooltipIndicators: [0],
                  ),
                  BarChartGroupData(
                    x: (DateTime.now().weekday - 4) % 7,
                    barRods: [
                      BarChartRodData(y:  _amounts[3], colors: [Colors.lightBlueAccent, Colors.greenAccent])
                    ],
                    showingTooltipIndicators: [0],
                  ),
                  BarChartGroupData(
                    x: (DateTime.now().weekday - 3) % 7,
                    barRods: [
                      BarChartRodData(y: _amounts[2], colors: [Colors.lightBlueAccent, Colors.greenAccent])
                    ],
                    showingTooltipIndicators: [0],
                  ),
                  BarChartGroupData(
                    x: (DateTime.now().weekday - 2) % 7,
                    barRods: [
                      BarChartRodData(y: _amounts[1], colors: [Colors.lightBlueAccent, Colors.greenAccent])
                    ],
                    showingTooltipIndicators: [0],
                  ),
                  BarChartGroupData(
                    x: DateTime.now().weekday - 1,
                    barRods: [
                      BarChartRodData(y: _amounts[0], colors: [Colors.lightBlueAccent, Colors.greenAccent])
                    ],
                    showingTooltipIndicators: [0],
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
}