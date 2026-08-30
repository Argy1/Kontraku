import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../theme/app_colors.dart';

/// Pil status. Bisa dari UnitStatus, atau teks+warna kustom
/// (mis. "Segera bayar" untuk unit yang penyewanya mendekati jatuh tempo).
class StatusBadge extends StatelessWidget {
  const StatusBadge._({
    required this.label,
    required this.bg,
    required this.fg,
  });

  factory StatusBadge.fromUnitStatus(BuildContext context, UnitStatus status) {
    final c = AppColors.of(context);
    return switch (status) {
      UnitStatus.terisi => StatusBadge._(
          label: 'Terisi', bg: c.statusFilledBg, fg: c.statusFilledText),
      UnitStatus.kosong => StatusBadge._(
          label: 'Kosong', bg: c.statusEmptyBg, fg: c.statusEmptyText),
      UnitStatus.renovasi => StatusBadge._(
          label: 'Renovasi', bg: c.contractBg, fg: c.contractText),
    };
  }

  factory StatusBadge.due(BuildContext context, String label) {
    final c = AppColors.of(context);
    return StatusBadge._(label: label, bg: c.statusDueBg, fg: c.statusDueText);
  }

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

/// Pil teal "N unit" yang dipakai di kartu kontrakan.
class CountPill extends StatelessWidget {
  const CountPill(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.tealPillBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: c.tealPillText,
        ),
      ),
    );
  }
}
