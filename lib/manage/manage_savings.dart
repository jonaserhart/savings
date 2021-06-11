import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:savings/Storage.dart';
import 'package:savings/classes/Saving.dart';

import 'AnimatedFloatingActionButton.dart';

const int LIMIT = 15;

class ManageSavingsPage extends StatefulWidget {
  @override
  _ManageSavingsPageState createState() => _ManageSavingsPageState();
}

class _ManageSavingsPageState extends State<ManageSavingsPage> {
  var _storageProvider = Storage.getProvider();

  List<Saving> _savings = List.empty(growable: true);
  final _listController = StreamController<List<Saving>>();
  ScrollController _scrollController;
  var _currency;
  var _lastItemIndex = 0;
  var _currentPage = 0;

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
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
                child: Text('Fetching more savings..'),
              ),
            ],
          ),
        ),
      );
      _storageProvider.getLast(_lastItemIndex + LIMIT).then((value) {
        var values = value as List<Saving>;
        values.sort((a, b) => b.date.compareTo(a.date));
        if (values.length < (_lastItemIndex + LIMIT)) {
          _scrollController.removeListener(_scrollListener);
        }
        _lastItemIndex = values.length;
        setState(() {
          _savings = value;
        });
        _listController.sink.add(_savings);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text("New items loaded")));
      });
    }
  }

  @override
  void initState() {
    _currentPage = 0;
    _scrollController = new ScrollController();
    _storageProvider.getCurrency().then((value) {
      setState(() {
        _currency = value;
      });
    });
    _storageProvider.getLast(LIMIT).then((value) {
      var values = value as List<Saving>;
      values.sort((a, b) => b.date.compareTo(a.date));
      if (values.length >= 15) {
        _scrollController.addListener(_scrollListener);
      }
      _lastItemIndex = values.length;
      setState(() {
        _savings = value;
      });
      _listController.sink.add(_savings);
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void onExpenseAdded(double amount, String description) async {
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
      var saving = new Saving(-amount, description);
      await _storageProvider.addSaving(saving);
      setState(() {
        _savings.insert(0, saving);
        _listController.sink.add(_savings);
      });
    } catch (error) {
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
            controller: _scrollController,
            itemCount: _savings.length,
            itemBuilder: (context, index) {
              var date = DateTime.fromMillisecondsSinceEpoch(
                  int.tryParse(_savings[index].date));
              var dateString =
                  '${date.day < 10 ? '0' : ''}${date.day}.${date.month < 10 ? '0' : ''}${date.month}.${date.year}';
              return Dismissible(
                  onDismissed: (direction) async {
                    var saving = _savings.elementAt(index);
                    await _storageProvider.removeSaving(saving);
                  },
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  background: Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Card(
                        color: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("Delete", style: TextStyle(fontSize: 16)),
                                Padding(
                                  padding: EdgeInsets.only(right: 8, left: 8),
                                  child: Icon(Icons.delete),
                                ),
                              ],
                            )),
                      )),
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: FadeIn(
                        duration: Duration(milliseconds: 500),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      child: Text(
                                        _currency ?? '\$',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ),
                                      backgroundColor:
                                          _savings[index].amount.isNegative
                                              ? Colors.red
                                              : Colors.greenAccent,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              _savings[index].description == ""
                                                  ? "General"
                                                  : _savings[index].description,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${_savings[index].amount.toStringAsFixed(2)}$_currency',
                                  style: TextStyle(fontSize: 30),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )));
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
        floatingActionButton: ActionButton(onSavingAdded, onExpenseAdded),
        body: Builder(
          builder: (BuildContext context) {
            return Container(
              padding:
                  EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 40),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 30, right: 90, bottom: 20),
                    child: Text(
                      'Manage savings / goals',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  _savings.isNotEmpty
                      ? buildList()
                      : Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Column(
                            children: [
                              Text(
                                  'No savings found, you can add one at the bottom'),
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
