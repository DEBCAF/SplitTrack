import 'package:flutter/material.dart';
import '../models/person.dart';
import '../logic/expense_logic.dart';

class SplitModeSelector extends StatelessWidget {
  final SplitMode splitMode;
  final ValueChanged<SplitMode?> onChanged;
  final int payerIndex;
  final ValueChanged<int?> onPayerChanged;
  final List<Person> people;

  const SplitModeSelector({
    super.key,
    required this.splitMode,
    required this.onChanged,
    required this.payerIndex,
    required this.onPayerChanged,
    required this.people,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Split Mode', style: TextStyle(fontWeight: FontWeight.bold)),
        RadioListTile<SplitMode>(
          title: const Text('Split equally across all members'),
          value: SplitMode.equally,
          groupValue: splitMode,
          onChanged: onChanged,
        ),
        RadioListTile<SplitMode>(
          title: const Text('One person pays, others owe them'),
          value: SplitMode.onePays,
          groupValue: splitMode,
          onChanged: onChanged,
        ),
        if (splitMode == SplitMode.onePays)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: DropdownButtonFormField<int>(
              value: payerIndex,
              decoration: const InputDecoration(
                labelText: 'Who Paid?',
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                people.length,
                (index) => DropdownMenuItem(
                  value: index,
                  child: Text(people[index].name.isEmpty
                      ? 'Person ${index + 1}'
                      : people[index].name),
                ),
              ),
              onChanged: onPayerChanged,
            ),
          ),
      ],
    );
  }
}