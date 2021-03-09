

import 'package:countup/countup.dart';
import 'package:flutter/material.dart';
import 'package:savings/FirebaseStorageProvider.dart';
import 'package:savings/Storage.dart';

class SavingsSum extends StatefulWidget {
  @override
  _SavingsSumState createState() => _SavingsSumState();
}

class _SavingsSumState extends State<SavingsSum> {
  String _currency;
  double _total;

  var _storageProvider = Storage.getProvider();

  @override
  void initState() {
    _storageProvider.getCurrency().then((value) {
      setState(() {
        _currency = value;
      });
    });
    _storageProvider.getTotal().then((value) {
      setState(() {
        _total = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Text('Saved so far',
                style: TextStyle(fontSize: 20)),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Countup(
                begin: 0,
                end: _total ?? 0,
                precision: 2,
                duration: Duration(milliseconds: 500),
                separator: ',',
                style: TextStyle(
                  fontSize: 36,
                ),
                suffix: _currency == null ? '' : _currency,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
