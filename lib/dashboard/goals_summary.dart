import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:savings/Storage.dart';
import 'package:savings/classes/Goal.dart';

class GoalsSummary extends StatefulWidget {
  @override
  _GoalsSummaryState createState() => _GoalsSummaryState();
}

class _GoalsSummaryState extends State<GoalsSummary> {
  List<Goal> goals = [];
  double total = 0;

  var _storageProvider = Storage.getProvider();

  @override
  void initState() {
    goals.add(Goal(300, "Fahrraklajshsdfsdfsdf"));
    goals.add(Goal(12, "Fahrrad"));
    goals.add(Goal(12, "Fahrrad"));
    goals.add(Goal(12, "Fahrrad"));
    goals.add(Goal(12, "Fahrrad"));
    goals.add(Goal(12, "Fahrrad"));
    _storageProvider.getTotal().then((value) {
      if (value != null) {
        total = value;
      }
    });
    super.initState();
  }

//  return Center(
//  child: Padding(
//  padding: EdgeInsets.all(10),
  // child: Text('Saved so far',
//  style: TextStyle(fontSize: 20)),
  // ),

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 310,
        child: Card(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text('Your goals', style: TextStyle(fontSize: 20)),
              ),
              Container(
                height: 250,
                child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 10);
                    },
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.redAccent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text("Delete", style: TextStyle(fontSize: 15)),
                                    Padding(
                                      padding: EdgeInsets.only(right: 8, left: 8),
                                      child: Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          key: Key(index.toString()),
                          child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(goals[index].name,
                                      style: TextStyle(fontSize: 15)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Text(
                                            "${goals[index].amount.toStringAsFixed(2)}",
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                      CircularPercentIndicator(
                                        radius: 45.0,
                                        lineWidth: 4.0,
                                        percent:
                                            (total / goals[index].amount > 1
                                                ? 1
                                                : total / goals[index].amount),
                                        center: Text(
                                            "${(total / goals[index].amount > 1 ? 100 : total / goals[index].amount * 100).toStringAsFixed(0)}%"),
                                        progressColor: Colors.greenAccent,
                                      )
                                    ],
                                  )
                                ],
                              )));
                    }),
              ),
            ],
          ),
        ));
  }
}
