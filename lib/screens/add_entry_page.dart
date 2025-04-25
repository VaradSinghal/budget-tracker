import 'package:flutter/material.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/firestore_service.dart';

class AddEntryPage extends StatefulWidget {
  @override
  _AddEntryPageState createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'expense';
  String _description = '';
  String _amount = '';
  String? _category;
  final FirestoreService _firestoreService = FirestoreService();

  void _submitEntry() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final transaction = Transaction(
        id: '',
        type: _type,
        description: _description,
        amount: double.parse(_amount),
        category: _type == 'expense' ? _category : null,
        date: DateTime.now(),
      );
      await _firestoreService.addTransaction(transaction);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry added successfully')),
      );
      _formKey.currentState!.reset();
      setState(() {
        _category = null;
        _type = 'expense';
        _amount = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              items: ['income', 'expense']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type[0].toUpperCase() + type.substring(1)),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                _type = value!;
                _category = null;
              }),
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) =>
                  value!.isEmpty ? 'Enter a description' : null,
              onSaved: (value) => _description = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value!.isEmpty || double.tryParse(value) == null
                      ? 'Enter a valid amount'
                      : null,
              onSaved: (value) => _amount = value!,
            ),
            if (_type == 'expense')
              StreamBuilder<List<String>>(
                stream: _firestoreService.getCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return DropdownButtonFormField<String>(
                    value: _category,
                    items: snapshot.data!
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _category = value),
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (value) =>
                        value == null ? 'Select a category' : null,
                  );
                },
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitEntry,
              child: const Text('Add Entry'),
            ),
          ],
        ),
      ),
    );
  }
}