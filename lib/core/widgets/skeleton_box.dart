import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../features/rates/presentation/rates_colors.dart';

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE7ECF1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Wraps skeleton placeholders in a shared shimmer sweep. Put one of these
/// around a screen's skeleton layout rather than shimmering each box alone,
/// so the sweep reads as a single loading surface.
class SkeletonShimmer extends StatelessWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE7ECF1),
      highlightColor: const Color(0xFFF4F7FA),
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

/// Stat-tile skeleton: label + big value + delta line, matching the
/// dashboard's stat cards.
class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 90, height: 13),
          SizedBox(height: 12),
          SkeletonBox(width: 70, height: 30),
          SizedBox(height: 10),
          SkeletonBox(width: 110, height: 13),
        ],
      ),
    );
  }
}

/// Single data-table row skeleton: a run of flexed bars with two pill-shaped
/// badge placeholders, matching the dashboard's recent-rates table.
class TableRowSkeleton extends StatelessWidget {
  const TableRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 22, child: SkeletonBox(height: 14)),
        const SizedBox(width: 24),
        const Expanded(flex: 16, child: SkeletonBox(height: 14)),
        const SizedBox(width: 24),
        const Expanded(flex: 12, child: SkeletonBox(width: 70, height: 20, borderRadius: 20)),
        const SizedBox(width: 24),
        const Expanded(flex: 12, child: SkeletonBox(height: 14)),
        const SizedBox(width: 24),
        const Expanded(flex: 12, child: SkeletonBox(width: 60, height: 20, borderRadius: 20)),
      ],
    );
  }
}

/// List-row skeleton for a client-rate card: leading badge, two-line body,
/// trailing pill.
class ListRowCardSkeleton extends StatelessWidget {
  const ListRowCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 56, height: 22, borderRadius: 6),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 140, height: 15),
                const SizedBox(height: 8),
                const SkeletonBox(width: 180, height: 13),
              ],
            ),
          ),
          const SkeletonBox(width: 72, height: 22, borderRadius: 20),
        ],
      ),
    );
  }
}

/// Grid-card skeleton: header (avatar + two lines), body line, footer bar —
/// matching the custom-clients grid's client cards.
class GridCardSkeleton extends StatelessWidget {
  const GridCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.colors.surfaceMuted))),
            child: Row(
              children: [
                const SkeletonBox(width: 44, height: 44, borderRadius: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SkeletonBox(width: 120, height: 14),
                      const SizedBox(height: 6),
                      const SkeletonBox(width: 150, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 160, height: 13),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      SkeletonBox(width: 70, height: 20, borderRadius: 20),
                      SizedBox(width: 8),
                      SkeletonBox(width: 60, height: 20, borderRadius: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: context.colors.border)),
            ),
            child: const SkeletonBox(width: 100, height: 13),
          ),
        ],
      ),
    );
  }
}
