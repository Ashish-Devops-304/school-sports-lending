import 'package:flutter/material.dart';
import '../services/sports_item_service.dart';
import 'add_sports_item_screen.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class SportsItemListScreen extends StatefulWidget {
  const SportsItemListScreen({super.key});

  @override
  State<SportsItemListScreen> createState() => _SportsItemListScreenState();
}

class _SportsItemListScreenState extends State<SportsItemListScreen> {
  final SportsItemService _svc = SportsItemService();
  List<ParseObject> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    // --- FIX: Renamed function to match your service file ---
    final data = await _svc.getSportsItems(); 
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    // Note: You don't have a deleteItem function in your service
    // You will need to add one if you want this to work
    // await _svc.deleteItem(id); 
    print('Delete functionality not implemented in service');
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sports Items')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final name = item.get<String>('name') ?? 'Unnamed';
                  final category = item.get<String>('category') ?? '';
                  final qty = item.get<int>('quantity') ?? 0;

                  return ListTile(
                    title: Text(name),
                    subtitle: Text('$category • Qty: $qty'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'delete') {
                          await _delete(item.objectId!);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        // Use the correct route name from main.dart
        onPressed: () => Navigator.pushNamed(context, '/add_item').then((_) => _load()),
        child: const Icon(Icons.add),
        tooltip: 'Add Item',
      ),
    );
  }
}