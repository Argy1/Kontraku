import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../utils/reminder_style.dart';

const _cardRadius = BorderRadius.only(
  topLeft: Radius.circular(4),
  bottomLeft: Radius.circular(4),
  topRight: Radius.circular(16),
  bottomRight: Radius.circular(16),
);

/// Cangkang kartu reminder khas desain: sudut 4-16-16-4, garis tebal berwarna
/// di kiri, hairline tipis mengelilingi.
///
/// Trik: border tebal-kiri + hairline itu "tidak seragam" sehingga tidak boleh
/// digabung dengan borderRadius pada satu BoxDecoration. Jadi hairline + sudut
/// dipasang di container luar (seragam), strip 4px jadi anak yang ikut ter-clip.
class ReminderCardShell extends StatelessWidget {
  const ReminderCardShell({
    super.key,
    required this.barColor,
    required this.borderColor,
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  final Color barColor;
  final Color borderColor;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Material(
      color: c.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: _cardRadius,
        side: BorderSide(color: borderColor, width: 0.5),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: barColor),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu "Perlu perhatian" di Beranda.
class AttentionCard extends StatelessWidget {
  const AttentionCard({super.key, required this.item, this.onTap});

  final AttentionItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final style = ReminderStyle.of(context, item.type);

    return ReminderCardShell(
      barColor: style.bar,
      borderColor: style.cardBorder,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: style.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(style.icon, size: 20, color: style.text),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.unitName}, ${item.kontrakanName} · ${relativeDays(item.daysLeft)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Baris reminder di layar Reminder, dengan lingkaran untuk menandai selesai.
class ReminderTile extends StatelessWidget {
  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onComplete,
    this.onLongPress,
  });

  final Reminder reminder;
  final VoidCallback onComplete;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final style = ReminderStyle.of(context, reminder.type);

    return ReminderCardShell(
      barColor: style.bar,
      borderColor: style.cardBorder,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            IconButton(
              onPressed: onComplete,
              visualDensity: VisualDensity.compact,
              tooltip: 'Tandai selesai',
              icon: Icon(Icons.circle_outlined, size: 22, color: style.bar),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.displayTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    relativeDays(reminder.daysLeft),
                    style: TextStyle(fontSize: 12, color: style.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
