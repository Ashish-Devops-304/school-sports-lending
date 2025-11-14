import 'dart:io';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SportsItemService {
  Future<bool> addSportsItem({
    required String name,
    required String category,
    required String description,
    required dynamic file,
  }) async {
    try {
      ParseFileBase? parseFile;

      if (kIsWeb) {
        parseFile = ParseWebFile(file.bytes, name: file.name);
      } else {
        final pickedFile = File(file.path);
        parseFile = ParseFile(pickedFile, name: file.name);
      }
      await parseFile.save();

      final sportsItem = ParseObject('SportsItem')
        ..set('name', name)
        ..set('category', category)
        ..set('description', description)
        ..set('image', parseFile)
        // --- FIX: Add a default quantity so items can be borrowed ---
        ..set('quantity', 1); 

      final response = await sportsItem.save();
      return response.success;
    } catch (e) {
      print('Error adding sports item: $e');
      return false;
    }
  }

  Future<List<ParseObject>> getSportsItems() async {
    final query = QueryBuilder<ParseObject>(ParseObject('SportsItem'));
    final response = await query.query();
    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    } else {
      return [];
    }
  }
}
