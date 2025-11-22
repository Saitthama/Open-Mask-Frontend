import 'package:flutter/material.dart';

class CameraShutterButton extends StatefulWidget {
  const CameraShutterButton({
    super.key,
    required this.onTap,
    this.size = 82,
  });

  final double size;
  final VoidCallback onTap;

  @override
  State<CameraShutterButton> createState() => _CameraShutterButtonState();
}

class _CameraShutterButtonState extends State<CameraShutterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _innerScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 120),
    );

    _innerScale = Tween<double>(begin: 1.0, end: 0.82).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: _tap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Äußerer Ring
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (ButtonTheme.of(context).colorScheme == null)
                      ? Colors.white
                      : ButtonTheme.of(context).colorScheme!.primary,
                  width: widget.size * 0.07,
                ),
              ),
            ),

            // Animierter innerer Kreis
            AnimatedBuilder(
              animation: _innerScale,
              builder: (final context, final child) {
                return Transform.scale(
                  scale: _innerScale.value,
                  child: Container(
                    width: widget.size * 0.72,
                    height: widget.size * 0.72,
                    decoration: BoxDecoration(
                      color: Theme.of(context).buttonTheme.colorScheme?.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
