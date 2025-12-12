import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/routing/active_branch_notifier.dart';
import 'package:open_mask/routing/navigation_bar.dart';

/// Oberste Shell der App.
/// <ul>
///   <li>Enthält den [StatefulNavigationShell], der die Tabs verwaltet.</li>
///   <li>Bindet die untere Navigationsleiste [CustomNavigationBar] ein.</li>
///   <li>Koordiniert Tab-Wechsel.</li>
/// </ul>
class AppShell extends StatefulWidget {
  /// Erstellt eine AppShell mit der gegebenen [navigationShell].
  const AppShell({required this.navigationShell, super.key});

  /// Shell mit den drei Branches der App.
  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

/// Hält den Status von [AppShell].
class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
  }

  /// Wird aufgerufen, wenn ein Tab ausgewählt wird.
  /// <ul>
  ///   <li>Wechselt den aktiven Branch.</li>
  ///   <li>Informiert den [ActiveBranchNotifier] über den neuen Index.</li>
  ///   <li>Bei erneutem Drücken wird zum Root des Tabs zurück navigiert.</li>
  /// </ul>
  void onTap(final int index) {
    final current = widget.navigationShell.currentIndex;

    if (index == current) {
      // erneut gedrückt --> zum Root des Tabs zurückkehren
      ActiveBranchNotifier.instance.value = -1;
      ActiveBranchNotifier.instance.value = 1;
      widget.navigationShell.goBranch(index, initialLocation: true);
      return;
    }

    // Notifier auf neuen Index vor goBranch setzen, sodass listener direkt informiert und gestoppt werden können
    ActiveBranchNotifier.instance.value = index;

    // Branch wechseln
    widget.navigationShell.goBranch(index);
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: widget.navigationShell.currentIndex,
        onBranchSelected: onTap,
      ),
    );
  }
}
