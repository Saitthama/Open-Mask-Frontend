import 'package:flutter/material.dart';
import 'package:open_mask/ui/view_models/filter_workshop_view_model.dart';
import 'package:open_mask/ui/views/filter_workshop_view.dart';
import 'package:provider/provider.dart';

/// Startseite der Filterwerkstatt.
class FilterWorkshopScreen extends StatelessWidget {
  /// Konstruktor.
  const FilterWorkshopScreen({super.key});

  /// Route zu der Seite, über die diese erreicht werden kann.
  static const routePath = '/filter-workshop';

  /// Gibt den Index des Filter-Workshop-Tabs für das Shell-Routing an.
  static const int filterWorkshopBranchIndex = 0;

  @override
  Widget build(final BuildContext context) {
    return ChangeNotifierProvider(
      create: (final _) => FilterWorkshopViewModel(),
      child: const FilterWorkshopView(),
    );
  }
}
