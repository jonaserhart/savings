import 'dart:async';
import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:savings/Storage.dart';
import 'package:savings/classes/Saving.dart';

import 'AnimatedFloatingActionButton.dart';

class ManageSavingsPage extends StatefulWidget {
  @override
  _ManageSavingsPageState createState() => _ManageSavingsPageState();
}

class _ManageSavingsPageState extends State<ManageSavingsPage> {
  var _storageProvider = Storage.getProvider();

  List<Saving> _savings = List.empty(growable: true);
  final _listController = StreamController<List<Saving>>();
  var _controller = ScrollController();
  var _currency;

  @override
  void initState() {
    _storageProvider.getCurrency().then((value) {
      setState(() {
        _currency = value;
      });
    });
    var limit = 15;
    _storageProvider.getLast(limit).then((value) {
      var values = value as List<Saving>;
      values.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _savings = value;
      });
      _listController.sink.add(_savings);
      if (value.length == limit) {
        _controller.addListener(() {
          if (_controller.position.pixels ==
              _controller.position.maxScrollExtent) {
            print('fetching more...');
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _listController.sink.close();
    super.dispose();
  }

  void onSavingAdded(double amount, String description) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(days: 2),
        content: Row(
          children: [
            SizedBox(
              height: 40,
              child: SpinKitChasingDots(
                size: 30,
                color: Colors.blue,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Performing changes..'),
            ),
          ],
        ),
      ),
    );
    try {
      var saving = new Saving(amount, description);
      await _storageProvider.addSaving(saving);
      setState(() {
        _savings.insert(0, saving);
        _listController.sink.add(_savings);
      });
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  Widget buildList() {
    return Flexible(
        child: StreamBuilder(
      stream: _listController.stream,
      builder: (context, AsyncSnapshot<List<Saving>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: _savings.length,
            itemBuilder: (context, index) {
              var date = DateTime.fromMillisecondsSinceEpoch(
                  int.tryParse(_savings[index].date));
              var dateString =
                  '${date.day < 10 ? '0' : ''}${date.day}.${date.month < 10 ? '0' : ''}${date.month}.${date.year}';
              return Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: FadeIn(
                    duration: Duration(milliseconds: 500),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              child: Text(
                                _currency ?? '\$',
                                style: TextStyle(fontSize: 25),
                              ),
                              backgroundColor: _savings[index].amount.isNegative
                                  ? Colors.redAccent
                                  : Colors.greenAccent,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dateString,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      _savings[index].description,
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 40),
                              child: Text(
                                '${_savings[index].amount.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 30),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ));
            },
          );
        }
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: Duration(milliseconds: 250),
      child: Scaffold(
        floatingActionButton: ActionButton(onSavingAdded),
        body: Builder(
          builder: (BuildContext context) {
            return Container(
              padding: EdgeInsets.only(top: 30, left: 10, right: 10),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 30, right: 90, bottom: 20),
                    child: Text(
                      'Manage your savings',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  _savings.isNotEmpty
                      ? buildList()
                      : Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Column(
                            children: [
                              Text('No savings found, you can add one at the bottom'),
                              Padding(padding: EdgeInsets.only(top: 60)),
                              SpinKitChasingDots(
                                size: 50,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
