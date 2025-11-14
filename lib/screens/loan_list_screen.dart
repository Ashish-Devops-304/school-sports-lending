import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../services/loan_service.dart';

class LoanListScreen extends StatefulWidget {
  const LoanListScreen({super.key});

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  final _svc = LoanService();
  List<ParseObject> _loans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final current = await ParseUser.currentUser() as ParseUser?;
      if (current != null) {
        final data = await _svc.fetchLoansForUser(current);
        setState(() => _loans = data);
      } else {
        setState(() => _loans = []);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading loans: $e')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _returnLoan(ParseObject loan) async {
    try {
      final success = await _svc.returnItem(loan);
      if (success) {
        await _load();
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Item returned successfully')));
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Failed to return item')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Loans'),
        backgroundColor: Colors.indigo,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loans.isEmpty
              ? const Center(child: Text('No loans found'))
              : ListView.builder(
                  itemCount: _loans.length,
                  itemBuilder: (context, index) {
                    final loan = _loans[index];
                    final item = loan.get<ParseObject>('item');
                    final status = loan.get<String>('status') ?? 'unknown';
                    final dueDate = loan.get<DateTime>('dueDate');

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(item?.get<String>('name') ?? 'Unnamed Item'),
                        subtitle: Text(
                          'Status: $status\nDue: ${dueDate != null ? dueDate.toLocal().toString().split(' ').first : '-'}',
                        ),
                        isThreeLine: true,
                        trailing: status == 'borrowed'
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                ),
                                onPressed: () => _returnLoan(loan),
                                child: const Text('Return'),
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
