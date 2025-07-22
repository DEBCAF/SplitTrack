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
  bool _serviceChargeEnabled = false;
  final _totalAmountController = TextEditingController();

  // Validation state
  String? _peopleCountError;
  List<String?> _nameErrors = [];
  List<String?> _spentErrors = [];
  String? _serviceChargeError;
  bool _formValid = false;

  static const int maxPeople = 50;
  static const double maxMoney = 1000000.0;

  @override
  void initState() {
    super.initState();
    _updatePeopleList(2);
    _totalAmountController.text = '0.0';
  }

  void _updatePeopleList(int count) {
    if (count <= 0) return;
    List<Person> newPeople = List.generate(count, (i) {
      return (i < _people.length)
          ? _people[i]
          : Person(name: '', spent: 0.0);
    });
    setState(() {
      _people = newPeople;
      if (_payerIndex >= count) {
        _payerIndex = 0;
      }
      _validateAll();
    });
  }

  void _validateAll() {
    // Validate people count
    int count = int.tryParse(_numPeopleController.text) ?? 0;
    if (count < 2) {
      _peopleCountError = 'At least 2 people required';
    } else if (count > maxPeople) {
      _peopleCountError = 'Maximum $maxPeople people allowed';
    } else {
      _peopleCountError = null;
    }

    // Validate names (no error for empty, fallback used)
    _nameErrors = List.filled(_people.length, null);
    Set<String> seen = {};
    for (int i = 0; i < _people.length; i++) {
      String name = _people[i].name.trim();
      String fallback = 'Person ${i + 1}';
      String effectiveName = name.isEmpty ? fallback : name;
      if (seen.contains(effectiveName)) {
        _nameErrors[i] = 'Duplicate name';
      } else {
        seen.add(effectiveName);
      }
    }

    // Validate spent
    _spentErrors = List.filled(_people.length, null);
    for (int i = 0; i < _people.length; i++) {
      double spent = _people[i].spent;
      if (spent < 0) {
        _spentErrors[i] = 'Cannot be negative';
      } else if (spent > maxMoney) {
        _spentErrors[i] = 'Too high (max $maxMoney)';
      }
    }

    // Validate service charge
    double? serviceCharge = double.tryParse(_serviceChargeController.text);
    if (!_serviceChargeEnabled) {
      _serviceChargeError = null;
    } else if (serviceCharge == null || serviceCharge < 0) {
      _serviceChargeError = 'Must be non-negative';
    } else if (serviceCharge > 100) {
      _serviceChargeError = 'Too high (max 100%)';
    } else {
      _serviceChargeError = null;
    }

    // Form valid?
    _formValid = _peopleCountError == null &&
        _nameErrors.every((e) => e == null) &&
        _spentErrors.every((e) => e == null) &&
        _serviceChargeError == null;
  }

  void _onSplitModeChanged(SplitMode? mode) {
    if (mode == null) return;
    if (mode == SplitMode.equally && _splitMode != SplitMode.equally) {
      // Switching to equally: sum per-person values
      double total = _people.fold(0.0, (sum, p) => sum + p.spent);
      _totalAmountController.text = total.toStringAsFixed(2);
    }
    setState(() {
      _splitMode = mode;
    });
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    _validateAll();
    if (!_formValid) {
      setState(() {});
      return;
    }
    double serviceCharge = _serviceChargeEnabled ? (double.tryParse(_serviceChargeController.text) ?? 0.0) : 0.0;
    List<Person> peopleWithService;
    if (_splitMode == SplitMode.equally) {
      // Distribute total equally
      double total = double.tryParse(_totalAmountController.text) ?? 0.0;
      int count = _people.length;
      double perPerson = count > 0 ? total / count : 0.0;
      peopleWithService = _people
        .asMap()
        .map((i, p) => MapEntry(i, p.copyWith(spent: perPerson)))
        .values
        .toList();
      peopleWithService = ExpenseLogic.applyServiceCharge(peopleWithService, serviceCharge);
    } else {
      peopleWithService = ExpenseLogic.applyServiceCharge(_people, serviceCharge);
    }
    List<Person> finalPeople;
    if (_splitMode == SplitMode.equally) {
      finalPeople = ExpenseLogic.splitEqually(peopleWithService);
    } else {
      finalPeople = ExpenseLogic.splitOnePays(peopleWithService, _payerIndex);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          people: finalPeople,
          splitEqually: _splitMode == SplitMode.equally,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SplitTrack'),
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
              if (_splitMode == SplitMode.equally)
                _buildTotalAmountInput()
              else
                ..._buildPersonTiles(),
              const SizedBox(height: 20),
              _buildServiceChargeInput(),
              const SizedBox(height: 20),
              SplitModeSelector(
                splitMode: _splitMode,
                onChanged: _onSplitModeChanged,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _numPeopleController,
          decoration: InputDecoration(
            labelText: 'Number of People',
            border: const OutlineInputBorder(),
            errorText: _peopleCountError,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            int? count = int.tryParse(value);
            if (count != null && count > 0) {
              _updatePeopleList(count);
            }
          },
        ),
      ],
    );
  }

  List<Widget> _buildPersonTiles() {
    return [
      for (int i = 0; i < _people.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: PersonInputTile(
            person: _people[i],
            displayName: _people[i].name.isEmpty ? 'Person ${i + 1}' : _people[i].name,
            onNameChanged: (name) => setState(() {
              _people[i] = _people[i].copyWith(name: name);
              _validateAll();
            }),
            onSpentChanged: (spent) => setState(() {
              _people[i] = _people[i].copyWith(spent: spent);
              _validateAll();
            }),
            nameError: _nameErrors.length > i ? _nameErrors[i] : null,
            spentError: _spentErrors.length > i ? _spentErrors[i] : null,
          ),
        ),
    ];
  }

  Widget _buildTotalAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus && (_totalAmountController.text == '0.0' || _totalAmountController.text == '0.00')) {
              _totalAmountController.clear();
            }
          },
          child: TextField(
            controller: _totalAmountController,
            decoration: const InputDecoration(
              labelText: 'Total Amount',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceChargeInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: _serviceChargeEnabled,
          onChanged: (checked) {
            setState(() {
              _serviceChargeEnabled = checked ?? false;
              if (_serviceChargeEnabled) {
                _serviceChargeController.text = '10';
              } else {
                _serviceChargeController.clear();
              }
              _validateAll();
            });
          },
        ),
        const Text('Apply Service Charge (%)'),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _serviceChargeController,
            enabled: _serviceChargeEnabled,
            decoration: InputDecoration(
              labelText: 'Service Charge (%)',
              border: const OutlineInputBorder(),
              errorText: _serviceChargeError,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(_validateAll),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _numPeopleController.dispose();
    _serviceChargeController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }
}