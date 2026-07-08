import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../core/theme/app_theme.dart';

/// Shimmering placeholder rows shown while a list-shaped provider is
/// loading, so the screen doesn't jump straight from a spinner to content.
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const SkeletonList({super.key, this.itemCount = 4, this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Shimmer.fromColors(
      baseColor: palette.surfaceAlt,
      highlightColor: palette.border,
      child: ListView.separated(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) => Container(
          height: 76,
          decoration: BoxDecoration(
            color: palette.surfaceAlt,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
