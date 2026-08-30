import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../theme/app_colors.dart';

/// Sekumpulan warna + ikon untuk satu tipe reminder, sesuai design-reference.
class ReminderStyle {
  const ReminderStyle({
    required this.bar,
    required this.bg,
    required this.text,
    required this.cardBorder,
    required this.icon,
  });

  final Color bar; // garis tebal di kiri kartu
  final Color bg; // latar chip ikon
  final Color text; // warna teks keterangan waktu
  final Color cardBorder;
  final IconData icon;

  static ReminderStyle of(BuildContext context, ReminderType type) {
    final c = AppColors.of(context);
    return switch (type) {
      ReminderType.sewaJatuhTempo => ReminderStyle(
          bar: c.rentBar,
          bg: c.rentBg,
          text: c.rentText,
          cardBorder: c.rentCardBorder,
          icon: Icons.payments_outlined,
        ),
      ReminderType.kontrakHabis => ReminderStyle(
          bar: c.contractBar,
          bg: c.contractBg,
          text: c.contractText,
          cardBorder: c.contractCardBorder,
          icon: Icons.description_outlined,
        ),
      ReminderType.maintenance => ReminderStyle(
          bar: c.neutralBar,
          bg: c.statusEmptyBg,
          text: c.textSecondary,
          cardBorder: c.cardBorder,
          icon: Icons.build_outlined,
        ),
      ReminderType.utilitas => ReminderStyle(
          bar: c.neutralBar,
          bg: c.statusEmptyBg,
          text: c.textSecondary,
          cardBorder: c.cardBorder,
          icon: Icons.bolt_outlined,
        ),
    };
  }
}
