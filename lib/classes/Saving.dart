
import 'package:savings/LocalStorageProvider.dart';

class Saving{
  final double amount;
  final String description;
  String date;

  Saving(this.amount, this.description) {
    this.date = DateTime.now().millisecondsSinceEpoch.toString();
  }

  Saving.withDate(this.amount, this.description, this.date);

  Map<String, Object> toSqliteEntry() {
    return {
      LocalStorageProvider.dateColumn : date,
      LocalStorageProvider.amountColumn : amount,
      LocalStorageProvider.descriptionColumn : description,
    };
  }

  static Saving fromMap(Map<String, Object> map) {
    return Saving.withDate(map['amount'], map['description'], map['date']);
  }

  Map<String, Object> toMap() {
    return {
        'amount': amount,
        'description': description,
        'date': date
    };
  }
}