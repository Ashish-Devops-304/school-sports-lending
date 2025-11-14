import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class LoanService {
  Future<List<ParseObject>> fetchLoansForUser(ParseUser user) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Loan'))
      ..whereEqualTo('borrower', user)
      ..includeObject(['item']);

    final response = await query.query();
    if (response.success && response.results != null) {
      return response.results!.cast<ParseObject>();
    }
    return [];
  }

  Future<bool> borrowItem({
    required ParseUser user,
    required ParseObject item,
    required DateTime dueDate,
  }) async {
    try {
      
      // --- THIS IS THE FIX ---
      // 'fetch()' returns the ParseObject itself
      final ParseObject freshItem = await item.fetch();
      // We don't need to check for .success or .result here
      // The try/catch block will handle any errors
      // --- END FIX ---

      final currentQty = freshItem.get<int>('quantity') ?? 0;
      if (currentQty <= 0) {
        return false; 
      }

      freshItem.set<int>('quantity', currentQty - 1);
      final saveResponse = await freshItem.save();

      if (!saveResponse.success) return false;

      final loan = ParseObject('Loan')
        ..set('borrower', user)
        ..set('item', freshItem)
        ..set('borrowDate', DateTime.now())
        ..set('dueDate', dueDate)
        ..set('status', 'borrowed');

      final result = await loan.save();
      return result.success;
    } catch (e) {
      print('Error borrowing item: $e');
      return false;
    }
  }

  Future<bool> returnItem(ParseObject loan) async {
    try {
      final item = loan.get<ParseObject>('item');
      if (item == null) return false;
      
      // --- THIS IS THE FIX ---
      // 'fetch()' returns the ParseObject itself
      final ParseObject freshItem = await item.fetch();
      // --- END FIX ---

      final curQty = freshItem.get<int>('quantity') ?? 0;
      freshItem.set<int>('quantity', curQty + 1);
      await freshItem.save();

      loan.set<String>('status', 'returned');
      final result = await loan.save();
      return result.success;
    } catch (e) {
      print('Error returning item: $e');
      return false;
    }
  }
}