import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import "package:open_mask/ui/screens/camera_screen.dart";
import 'package:open_mask/ui/screens/filter_workshop_screen.dart';
import 'package:open_mask/ui/screens/settings_screen.dart';

class CustomNavigationBar extends StatelessWidget {
  final String currentRoute;

  const CustomNavigationBar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.white, size: 30),
              onPressed: () => (currentRoute == FilterWorkshopScreen.routePath)
                  ? {}
                  : context.pushReplacement(FilterWorkshopScreen.routePath)),
          IconButton(
              icon: const Icon(Icons.circle_outlined,
                  color: Colors.white, size: 50),
              onPressed: () => (currentRoute == CameraScreen.routePath)
                  ? {}
                  : context.pushReplacement(CameraScreen.routePath)),
          IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 30),
              onPressed: () => (currentRoute == SettingsScreen.routePath)
                  ? {}
                  : context.pushReplacement(SettingsScreen.routePath)),
        ],
      ),
    );
  }
}
