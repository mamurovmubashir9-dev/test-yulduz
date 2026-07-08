import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

/// A [Card] that scales down slightly while pressed, for tactile feedback.
/// Used by the list-item cards (test/student/assigned-test) to avoid
/// repeating the same Card+InkWell scaffolding in every one of them.
class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const PressableCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onTap,
          onHighlightChanged: widget.onTap == null
              ? null
              : (v) {
                  if (v) HapticFeedback.selectionClick();
                  setState(() => _pressed = v);
                },
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}
