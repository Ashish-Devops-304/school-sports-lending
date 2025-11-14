import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../services/loan_service.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({Key? key}) : super(key: key);

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final LoanService _loanSvc = LoanService();

  List<ParseObject> _items = [];
  ParseObject? _selectedItem;
  DateTime? _dueDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _loading = true);

    try {
      final query = QueryBuilder<ParseObject>(ParseObject('SportsItem'))
        ..whereGreaterThan('quantity', 0); // Only fetch items with quantity > 0

      final response = await query.query();

      if (response.success && response.results != null) {
        setState(() {
          _items = response.results!.cast<ParseObject>();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No items available to borrow.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading items: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitLoan() async {
    if (_selectedItem == null || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select item and due date')),
      );
      return;
    }

    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    setState(() => _loading = true);

    final success = await _loanSvc.borrowItem(
      user: currentUser,
      item: _selectedItem!,
      dueDate: _dueDate!,
    );

    setState(() => _loading = false);

    if (!mounted) return; // prevent context errors if widget is disposed

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loan added successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add loan. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Loan'),
        backgroundColor: Colors.indigo,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text(
                    'Select Item',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ParseObject>(
                    value: _selectedItem,
                    items: _items.map((item) {
                      final name = item.get<String>('name') ?? 'Unnamed';
                      final qty = item.get<int>('quantity') ?? 0;
                      return DropdownMenuItem(
                        value: item,
                        child: Text('$name (Qty: $qty)'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedItem = value);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Item',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Due Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dueDate == null
                              ? 'No date selected'
                              : formatter.format(_dueDate!),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => _dueDate = picked);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                        ),
                        child: const Text('Select'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitLoan,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        backgroundColor: Colors.indigo,
                      ),
                      child: const Text(
                        'Submit Loan',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
