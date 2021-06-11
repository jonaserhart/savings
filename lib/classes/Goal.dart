
class Goal {
  double amount;
  String name;

  Goal(this.amount, this.name);

  Map<String, Object> toMap() {
    return {
      'amount': amount,
      'name': name,
    };
  }
}