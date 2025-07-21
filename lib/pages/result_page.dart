import 'package:flutter/material.dart';
import '../models/person.dart';
import '../logic/expense_logic.dart';
import '../widgets/summary_card.dart';

class ResultPage extends StatefulWidget {
  final List<Person> people;

  const ResultPage({super.key, required this.people});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late List<Person> _people;

  @override
  void initState() {
    super.initState();
    _people = widget.people.map((p) => p.copyWith()).toList();
  }

  void _showRepaymentDialog() {
    int? fromPersonIndex;
    int? toPersonIndex;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Simulate Repayment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: fromPersonIndex,
                    hint: const Text('From'),
                    onChanged: (val) => setDialogState(() => fromPersonIndex = val),
                    items: List.generate(
                      _people.length,
                      (i) => DropdownMenuItem(
                          value: i, child: Text(_people[i].name)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: toPersonIndex,
                    hint: const Text('To'),
                    onChanged: (val) => setDialogState(() => toPersonIndex = val),
                    items: List.generate(
                      _people.length,
                      (i) => DropdownMenuItem(
                          value: i, child: Text(_people[i].name)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    double? amount = double.tryParse(amountController.text);
                    if (fromPersonIndex != null &&
                        toPersonIndex != null &&
                        amount != null &&
                        amount > 0) {
                      setState(() {
                        _people = ExpenseLogic.applyRepayment(
                          _people,
                          fromPersonIndex!,
                          toPersonIndex!,
                          amount,
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> debts = ExpenseLogic.getDebts(_people);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _people = widget.people.map((p) => p.copyWith()).toList();
            }),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SummaryCard(debts: debts),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              'Running Balances',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _people.length,
                itemBuilder: (context, index) {
                  Person person = _people[index];
                  return ListTile(
                    title: Text(person.name),
                    trailing: Text(
                      '${person.balance.toStringAsFixed(2)} \$',
                      style: TextStyle(
                        color: person.balance >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRepaymentDialog,
        label: const Text('Repayment'),
        icon: const Icon(Icons.paid),
      ),
    );
  }
}