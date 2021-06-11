
import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:savings/StorageProvider.dart';
import 'package:savings/classes/Saving.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class FirebaseStorageProvider implements StorageProvider{
  DatabaseReference _userRef;

  static final FirebaseStorageProvider _instance = FirebaseStorageProvider._internal();

  factory FirebaseStorageProvider() {
    return _instance;
  }

  FirebaseStorageProvider._internal() {
    if (_auth.currentUser != null) {
      _userRef = FirebaseDatabase.instance.reference().child(_auth.currentUser.uid);
    } else {
      throw new AssertionError('cannot use firebase storage, because user is not authenticated');
    }
  }

  @override
  Future<void> addSaving(Saving saving) async {
    var ref = _userRef.child('savings').push();
    ref.set(saving.toMap());
    await updateTotal(saving.amount);
  }

  @override
  Future<String> getCurrency() async {
    var value = await _userRef.child('currency').once();
    return value.value.toString();
  }

  @override
  Future<Iterable<Saving>> getSavings() {
    // TODO: implement getSavings
    throw UnimplementedError();
  }

  @override
  Future<double> getTotal() async {
    var value = await _userRef.child('total').once();
    if (double.tryParse(value.value.toString()) == null) {
      throw new ArgumentError('could not parse double value from total');
    }
    return double.parse(value.value.toString());
  }

  @override
  Future<void> setCurrency(String currency) async {
    await _userRef.child('currency').set(currency);
  }

  @override
  Future<void> updateTotal(double value) async {
    var total = await getTotal();
    total += value;
    await _userRef.child('total').set(total);
  }

  @override
  Future<Iterable<Saving>> getLastWeeksSavings() async {
    var date = DateTime.now().add(Duration(days: -5));
    var savingsMap = await _userRef.child('savings').orderByChild('date').startAt(date.millisecondsSinceEpoch.toString()).once();
    var values = savingsMap.value;
    List<Saving> list = [];
    for (var key in values.keys) {
      var entry = values[key];
      var amount = entry['amount'];
      if (amount == null || double.tryParse(amount.toString()) == null) {
        continue;
      }
      var amountAsNumber = double.tryParse(amount.toString());
      var dateAsNumber = int.tryParse(entry['date'].toString());
      if (dateAsNumber == null) {
        continue;
      }
      var description = entry['description'];
      list.add(Saving.withDate(amountAsNumber, description ?? '', dateAsNumber.toString()));
    }
    return list;
  }

  @override
  Future<Iterable<Saving>> getLast(int number) async {
    var savingsMap = await _userRef.child('savings').orderByChild('date').limitToLast(number).once();
    var values = savingsMap.value;
    List<Saving> list = [];
    for (var key in values.keys) {
      var entry = values[key];
      var amount = entry['amount'];
      if (amount == null || double.tryParse(amount.toString()) == null) {
        continue;
      }
      var amountAsNumber = double.tryParse(amount.toString());
      var dateAsNumber = int.tryParse(entry['date'].toString());
      if (dateAsNumber == null) {
        continue;
      }
      var description = entry['description'];
      list.add(Saving.withDate(amountAsNumber, description ?? '', dateAsNumber.toString()));
    }
    return list;
  }

  @override
  Future<void> initialize() async {
  }

  @override
  Future<void> setDisplayName(String name) {
  }

  @override
  Future<String> getDisplayName() async {
    return FirebaseAuth.instance.currentUser?.displayName ?? '';
  }

  @override
  Future<void> removeSaving(Saving saving) {
    // TODO: implement removeSaving
    throw UnimplementedError();
  }
  
}