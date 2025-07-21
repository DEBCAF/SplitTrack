import 'package:flutter/material.dart';
import '../models/person.dart';
import '../logic/expense_logic.dart';
import '../widgets/summary_card.dart';

class ResultPage extends StatefulWidget {
  final List<Person> people;
  final bool splitEqually;

  const ResultPage({super.key, required this.people, required this.splitEqually});

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
    String? errorText;
    const double maxMoney = 1000000.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void validate() {
              double? amount = double.tryParse(amountController.text);
              errorText = null;
              if (fromPersonIndex == null || toPersonIndex == null) {
                errorText = 'Select both people';
              } else if (fromPersonIndex == toPersonIndex) {
                errorText = 'Cannot repay yourself';
              } else if (amount == null || amount <= 0) {
                errorText = 'Enter a positive amount';
              } else {
                // Calculate max allowed
                double maxOwed = _people[fromPersonIndex!].balance < 0
                  ? -_people[fromPersonIndex!].balance
                  : 0;
                if (amount > maxOwed + 0.01) {
                  errorText = 'Cannot repay more than owed ( 24${maxOwed.toStringAsFixed(2)})';
                } else if (amount > maxMoney) {
                  errorText = 'Amount too high (max $maxMoney)';
                }
              }
              setDialogState(() {});
            }
            return AlertDialog(
              title: const Text('Simulate Repayment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: fromPersonIndex,
                    hint: const Text('From'),
                    onChanged: (val) {
                      fromPersonIndex = val;
                      validate();
                    },
                    items: List.generate(
                      _people.length,
                      (i) => DropdownMenuItem(
                          value: i, child: Text(_people[i].name.isEmpty ? 'Person ${i + 1}' : _people[i].name)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: toPersonIndex,
                    hint: const Text('To'),
                    onChanged: (val) {
                      toPersonIndex = val;
                      validate();
                    },
                    items: List.generate(
                      _people.length,
                      (i) => DropdownMenuItem(
                          value: i, child: Text(_people[i].name.isEmpty ? 'Person ${i + 1}' : _people[i].name)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                      errorText: errorText,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => validate(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: (errorText == null && fromPersonIndex != null && toPersonIndex != null)
                      ? () {
                          double? amount = double.tryParse(amountController.text);
                          if (fromPersonIndex != null &&
                              toPersonIndex != null &&
                              amount != null &&
                              amount > 0 &&
                              fromPersonIndex != toPersonIndex) {
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
                        }
                      : null,
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

    // Patch debts to use fallback names if empty
    List<Map<String, dynamic>> patchedDebts = debts.map((debt) {
      String from = (debt['from'] as String).isEmpty ? 'Person ${_people.indexWhere((p) => p.name == debt['from']) + 1}' : debt['from'];
      String to = (debt['to'] as String).isEmpty ? 'Person ${_people.indexWhere((p) => p.name == debt['to']) + 1}' : debt['to'];
      return {
        'from': from,
        'to': to,
        'amount': debt['amount'],
      };
    }).toList();

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
            SummaryCard(debts: patchedDebts, splitEqually: widget.splitEqually, people: _people),
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
                  final displayName = person.name.isEmpty ? 'Person ${index + 1}' : person.name;
                  return ListTile(
                    title: Text(displayName),
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