import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:path/path.dart' as p; // Import path package

class SeedDataService {
  static Future<void> seedSportsItems() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/sports.json');
      final List<dynamic> items = json.decode(jsonString);

      for (var item in items) {
        // ... (your existing fields) ...
        final name = item['name'] ?? 'Unnamed';
        final category = item['category'] ?? 'Misc';
        final description = item['description'] ?? '';
        final quantity = item['quantity'] ?? 0;
        final condition = item['condition'] ?? 'Good';
        final imagePath = item['image']; // e.g., "assets/images/basketball.png"

        final query = QueryBuilder<ParseObject>(ParseObject('SportsItem'))
          ..whereEqualTo('name', name);
        final existing = await query.query();

        if (existing.success && existing.results != null && existing.results!.isNotEmpty) {
          print('$name already exists, skipping...');
          continue;
        }

        final parseItem = ParseObject('SportsItem')
          ..set('name', name)
          ..set('category', category)
          ..set('description', description)
          ..set('quantity', quantity)
          ..set('condition', condition);

        // --- FIX: Correctly load image from assets ---
        if (imagePath != null) {
          try {
            final ByteData byteData = await rootBundle.load(imagePath);
            final List<int> bytes = byteData.buffer.asUint8List();
            final String fileName = p.basename(imagePath);
            final parseFile = ParseFile.forData(bytes, name: fileName);
            
            await parseFile.save(); // Save the file first
            parseItem.set('image', parseFile); // Then set the pointer
          
          } catch (e) {
            print('Could not load asset image $imagePath: $e');
          }
        }
        // --- End Fix ---

        final response = await parseItem.save();
        if (response.success) {
          print('Added $name to Back4App');
        } else {
          print('Failed to add $name: ${response.error?.message}');
        }
      }
      print('Seeding completed successfully!');
    } catch (e) {
      print('Error seeding data: $e');
    }
  }
}