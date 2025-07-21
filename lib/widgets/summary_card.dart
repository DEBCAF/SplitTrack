import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final List<Map<String, dynamic>> debts;
  final bool splitEqually;
  final List people;

  const SummaryCard({super.key, required this.debts, required this.splitEqually, required this.people});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Summary of Debts',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (splitEqually)
              Builder(
                builder: (context) {
                  double total = 0;
                  for (var p in people) {
                    total += p.spent;
                  }
                  double perPerson = people.isNotEmpty ? total / people.length : 0;
                  return Column(
                    children: [
                      Text(
                        'Each person should pay:',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(people.length, (i) {
                        final name = (people[i].name.isEmpty) ? 'Person ${i + 1}' : people[i].name;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 16)),
                            Text(
                              '\$${perPerson.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        );
                      }),
                    ],
                  );
                },
              )
            else if (debts.isEmpty)
              const Text(
                'All settled up!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              )
            else
              ...debts.map((debt) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${debt['from']} owes ${debt['to']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        '\$${debt['amount'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}