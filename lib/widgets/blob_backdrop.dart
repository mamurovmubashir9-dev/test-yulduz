import 'package:flutter/material.dart';

/// A hand-drawn-feeling decorative backdrop of soft overlapping blobs,
/// used behind icons on empty states and auth headers so those moments
/// read as small illustrations rather than a bare icon in a circle.
///
/// Painted at runtime instead of shipping raster assets, so it always
/// matches the current brand palette and theme (light/dark) exactly.
class BlobBackdrop extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final Widget child;

  const BlobBackdrop({
    super.key,
    required this.child,
    this.size = 140,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _BlobPainter(colors: colors),
          ),
          child,
        ],
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final List<Color> colors;

  _BlobPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final blobs = [
      (offset: const Offset(-0.28, -0.22), radius: 0.42, colorIndex: 0),
      (offset: const Offset(0.32, -0.1), radius: 0.34, colorIndex: 1 % colors.length),
      (offset: const Offset(-0.05, 0.32), radius: 0.36, colorIndex: 2 % colors.length),
    ];

    for (final blob in blobs) {
      final paint = Paint()
        ..color = colors[blob.colorIndex].withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(
        center + Offset(blob.offset.dx * size.width, blob.offset.dy * size.height),
        blob.radius * size.width,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) => oldDelegate.colors != colors;
}
