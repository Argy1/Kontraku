import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_colors.dart';
import 'status_badge.dart';

/// Kartu satu kontrakan di daftar. Warna ikon bergantian ungu / pink
/// (parameter [index] menentukan giliran).
class KontrakanCard extends StatelessWidget {
  const KontrakanCard({
    super.key,
    required this.kontrakan,
    required this.index,
    required this.onTap,
  });

  final Kontrakan kontrakan;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isPurple = index.isEven;
    final iconBg = isPurple ? c.kontrakanPurpleBg : c.kontrakanPinkBg;
    final iconFg = isPurple ? c.kontrakanPurpleFg : c.kontrakanPinkFg;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.home_rounded, size: 24, color: iconFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kontrakan.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      kontrakan.address ?? 'Alamat belum diisi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CountPill('${kontrakan.unitCount} unit'),
            ],
          ),
        ),
      ),
    );
  }
}
