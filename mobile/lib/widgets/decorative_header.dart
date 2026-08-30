import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Header teal dekoratif dengan 2 lingkaran, seperti di layar Beranda.
class DecorativeHeader extends StatelessWidget {
  const DecorativeHeader({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return ClipRect(
      child: Container(
        width: double.infinity,
        color: c.headerBg,
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: _circle(130, c.headerCircleA),
            ),
            Positioned(
              bottom: -20,
              right: 60,
              child: _circle(70, c.headerCircleB.withValues(alpha: 0.5)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, topPadding + 16, 18, 24),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// Kartu statistik semi-transparan di dalam header (mis. "3 Kontrakan").
class HeaderStatCard extends StatelessWidget {
  const HeaderStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: c.headerMutedText),
          ),
        ],
      ),
    );
  }
}
