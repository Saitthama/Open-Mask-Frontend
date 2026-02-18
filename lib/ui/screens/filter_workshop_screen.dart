import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/ui/screens/filter_editor_screen.dart';

class FilterWorkshopScreen extends StatelessWidget {
  const FilterWorkshopScreen({super.key});

  static const routePath = '/filter-workshop';

  /// Gibt den Index des Filter-Workshop-Tabs für das Shell-Routing an.
  static const int filterWorkshopBranchIndex = 0;

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Filterwerkstatt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings Aktion
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header mit Zeit und "Filter"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '9:41',
                  style: TextStyle(fontSize: 16),
                ),
                const Text(
                  'Filter',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(width: 24), // Platzhalter für Ausgleich
              ],
            ),
          ),
          // Button Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    // Importieren Aktion
                  },
                  child: const Text('Importieren'),
                ),
                TextButton(
                  onPressed: () {
                    // Exportieren Aktion
                  },
                  child: const Text('Exportieren'),
                ),
                TextButton(
                  onPressed: () {
                    // Erstellen Aktion
                    context.push(
                        '${FilterWorkshopScreen.routePath}${FilterEditorScreen.routePath}');
                  },
                  child: const Text('Erstellen'),
                ),
              ],
            ),
          ),

          // Hauptinhalt
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Nichts hier. Zur Zeit.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hier finden Sie Ihre fertigen Filter.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Filter erstellen Aktion

                      context.push(
                          '${FilterWorkshopScreen.routePath}${FilterEditorScreen.routePath}');
                    },
                    child: const Text('Erstelle einen Filter'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
