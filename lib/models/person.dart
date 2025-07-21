class Person {
  final String name;
  final double spent;
  final double balance;

  Person({required this.name, required this.spent, this.balance = 0});

  Person copyWith({String? name, double? spent, double? balance}) {
    return Person(
      name: name ?? this.name,
      spent: spent ?? this.spent,
      balance: balance ?? this.balance,
    );
  }
} 

class Expense {
  String name;
  double amount;
  List<Person> participants;

  Expense({required this.name, required this.amount, required this.participants});
}
