import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/person.dart';

class PersonInputTile extends StatefulWidget {
  final Person person;
  final String displayName;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<double> onSpentChanged;
  final String? nameError;
  final String? spentError;

  const PersonInputTile({
    super.key,
    required this.person,
    required this.displayName,
    required this.onNameChanged,
    required this.onSpentChanged,
    this.nameError,
    this.spentError,
  });

  @override
  _PersonInputTileState createState() => _PersonInputTileState();
}

class _PersonInputTileState extends State<PersonInputTile> {
  late TextEditingController _nameController;
  late TextEditingController _spentController;
  FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.person.name.isEmpty ? widget.displayName : widget.person.name,
    );
    _spentController = TextEditingController(
      text: (widget.person.spent == 0.0) ? '' : widget.person.spent.toStringAsFixed(2),
    );
    _nameFocusNode.addListener(_handleNameFocus);
  }

  void _handleNameFocus() {
    if (_nameFocusNode.hasFocus && _nameController.text == widget.displayName) {
      _nameController.clear();
    }
    if (!_nameFocusNode.hasFocus && _nameController.text.isEmpty) {
      _nameController.text = widget.displayName;
    }
  }

  @override
  void didUpdateWidget(covariant PersonInputTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.person.name != _nameController.text && !_nameFocusNode.hasFocus) {
      _nameController.text = widget.person.name.isEmpty ? widget.displayName : widget.person.name;
    }
    // Do NOT update _spentController.text here to avoid input freezing bug
  }

  @override
  void dispose() {
    _nameController.dispose();
    _spentController.dispose();
    _nameFocusNode.dispose();
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
            focusNode: _nameFocusNode,
            decoration: InputDecoration(
              labelText: 'Name',
              border: const OutlineInputBorder(),
              errorText: widget.nameError,
            ),
            onChanged: widget.onNameChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: _spentController,
            decoration: InputDecoration(
              labelText: 'Spent',
              border: const OutlineInputBorder(),
              prefixText: '\$',
              errorText: widget.spentError,
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