import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/person.dart';

class PersonInputTile extends StatefulWidget {
  final Person person;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<double> onSpentChanged;

  const PersonInputTile({
    super.key,
    required this.person,
    required this.onNameChanged,
    required this.onSpentChanged,
  });

  @override
  _PersonInputTileState createState() => _PersonInputTileState();
}

class _PersonInputTileState extends State<PersonInputTile> {
  late final TextEditingController _nameController;
  late final TextEditingController _spentController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.person.name);
    _spentController =
        TextEditingController(text: widget.person.spent.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _spentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            onChanged: widget.onNameChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: _spentController,
            decoration: const InputDecoration(
              labelText: 'Spent',
              border: OutlineInputBorder(),
              prefixText: '\$',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: (value) {
              widget.onSpentChanged(double.tryParse(value) ?? 0.0);
            },
          ),
        ),
      ],
    );
  }
}