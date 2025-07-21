import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/person.dart';
import '../widgets/person_input_tile.dart';
import '../widgets/split_mode_selector.dart';
import 'result_page.dart';
import '../logic/expense_logic.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _numPeopleController = TextEditingController(text: '2');
  List<Person> _people = [];
  final _serviceChargeController = TextEditingController();
  bool _isServiceChargePercent = false;
  SplitMode _splitMode = SplitMode.equally;
  int _payerIndex = 0;

  @override
  void initState() {
    super.initState();
    _updatePeopleList(2);
  }

  void _updatePeopleList(int count) {
    if (count <= 0) return;
    List<Person> newPeople = List.generate(count, (i) {
      return (i < _people.length)
          ? _people[i]
          : Person(name: 'Person ${i + 1}');
    });
    setState(() {
      _people = newPeople;
      if (_payerIndex >= count) {
        _payerIndex = 0;
      }
    });
  }

  void _calculate() {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Parse service charge
    double serviceCharge = double.tryParse(_serviceChargeController.text) ?? 0.0;

    // Apply service charge
    List<Person> peopleWithService = ExpenseLogic.applyServiceCharge(
      _people,
      serviceCharge,
      _isServiceChargePercent,
    );

    // Calculate balances
    List<Person> finalPeople;
    if (_splitMode == SplitMode.equally) {
      finalPeople = ExpenseLogic.splitEqually(peopleWithService);
    } else {
      finalPeople = ExpenseLogic.splitOnePays(peopleWithService, _payerIndex);
    }

    // Navigate to results
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(people: finalPeople),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Expense Tracker'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPeopleCountInput(),
              const SizedBox(height: 20),
              ..._buildPersonTiles(),
              const SizedBox(height: 20),
              _buildServiceChargeInput(),
              const SizedBox(height: 20),
              SplitModeSelector(
                splitMode: _splitMode,
                onChanged: (mode) {
                  if (mode != null) {
                    setState(() => _splitMode = mode);
                  }
                },
                payerIndex: _payerIndex,
                people: _people,
                onPayerChanged: (index) {
                  if (index != null) {
                    setState(() => _payerIndex = index);
                  }
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Calculate'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeopleCountInput() {
    return TextField(
      controller: _numPeopleController,
      decoration: const InputDecoration(
        labelText: 'Number of People',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        int? count = int.tryParse(value);
        if (count != null && count > 0) {
          _updatePeopleList(count);
        }
      },
    );
  }

  List<Widget> _buildPersonTiles() {
    return [
      for (int i = 0; i < _people.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: PersonInputTile(
            person: _people[i],
            onNameChanged: (name) => _people[i].name = name,
            onSpentChanged: (spent) => _people[i].spent = spent,
          ),
        ),
    ];
  }

  Widget _buildServiceChargeInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _serviceChargeController,
            decoration: const InputDecoration(
              labelText: 'Service Charge',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: 10),
        ChoiceChip(
          label: const Text('\$'),
          selected: !_isServiceChargePercent,
          onSelected: (selected) {
            if (selected) setState(() => _isServiceChargePercent = false);
          },
        ),
        const SizedBox(width: 5),
        ChoiceChip(
          label: const Text('%'),
          selected: _isServiceChargePercent,
          onSelected: (selected) {
            if (selected) setState(() => _isServiceChargePercent = true);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _numPeopleController.dispose();
    _serviceChargeController.dispose();
    super.dispose();
  }
}