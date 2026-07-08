import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

class QuickActionTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<QuickActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onTap,
          onHighlightChanged: (v) {
            if (v) HapticFeedback.selectionClick();
            setState(() => _pressed = v);
          },
          child: Container(
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(11)),
                  child: Icon(widget.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 12),
                Text(widget.title, style: TextStyle(color: widget.color, fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 2),
                Text(widget.subtitle, style: TextStyle(color: widget.color.withValues(alpha: 0.75), fontSize: 12.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
