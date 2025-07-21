import '../models/person.dart';

enum SplitMode { equally, onePays }

typedef Repayment = Map<String, double>; // {from: amount}

class ExpenseLogic {
  static List<Person> applyServiceCharge(List<Person> people, double charge, bool isPercent) {
    if (charge == 0) return people;
    double total = people.fold(0, (sum, p) => sum + p.spent);
    double toAdd = isPercent ? total * (charge / 100) : charge;
    double perPerson = toAdd / people.length;
    return people
        .map((p) => p.copyWith(spent: p.spent + perPerson))
        .toList();
  }

  static List<Person> splitEqually(List<Person> people) {
    double total = people.fold(0, (sum, p) => sum + p.spent);
    double perPerson = total / people.length;
    return people
        .map((p) => p.copyWith(balance: p.spent - perPerson))
        .toList();
  }

  static List<Person> splitOnePays(List<Person> people, int payerIndex) {
    double total = people.fold(0, (sum, p) => sum + p.spent);
    return [
      for (int i = 0; i < people.length; i++)
        people[i].copyWith(
          balance: i == payerIndex ? total - people[i].spent : -people[i].spent,
        )
    ];
  }

  static List<Person> applyRepayment(List<Person> people, int from, int to, double amount) {
    if (from == to || amount <= 0) return people;
    List<Person> updated = List.from(people);
    updated[from] = updated[from].copyWith(balance: updated[from].balance + amount);
    updated[to] = updated[to].copyWith(balance: updated[to].balance - amount);
    return updated;
  }

  static List<Map<String, dynamic>> getDebts(List<Person> people) {
    // Returns a list of {from, to, amount}
    List<Map<String, dynamic>> debts = [];
    List<Person> debtors = people.where((p) => p.balance < -0.01).toList();
    List<Person> creditors = people.where((p) => p.balance > 0.01).toList();
    int d = 0, c = 0;
    while (d < debtors.length && c < creditors.length) {
      double debt = -debtors[d].balance;
      double credit = creditors[c].balance;
      double pay = debt < credit ? debt : credit;
      debts.add({
        'from': debtors[d].name,
        'to': creditors[c].name,
        'amount': pay,
      });
      debtors[d] = debtors[d].copyWith(balance: debtors[d].balance + pay);
      creditors[c] = creditors[c].copyWith(balance: creditors[c].balance - pay);
      if (debtors[d].balance.abs() < 0.01) d++;
      if (creditors[c].balance.abs() < 0.01) c++;
    }
    return debts;
  }
} 