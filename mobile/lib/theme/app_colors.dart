import 'package:flutter/material.dart';

/// Semua warna diambil PERSIS dari design-reference.html yang sudah disetujui.
///
/// Dipakai lewat `ThemeExtension` supaya tiap widget bisa ambil warna yang benar
/// (light/dark) dengan `AppColors.of(context)` tanpa cek tema manual.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.cardBorder,
    required this.headerBg,
    required this.headerCircleA,
    required this.headerCircleB,
    required this.headerAccentText,
    required this.headerMutedText,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.onPrimary,
    required this.avatarBg,
    required this.avatarText,
    required this.tealPillBg,
    required this.tealPillText,
    required this.inputBorder,
    // status unit
    required this.statusFilledBg,
    required this.statusFilledText,
    required this.statusEmptyBg,
    required this.statusEmptyText,
    required this.statusDueBg,
    required this.statusDueText,
    // reminder: sewa (amber)
    required this.rentBar,
    required this.rentBg,
    required this.rentText,
    required this.rentCardBorder,
    // reminder: kontrak (coral)
    required this.contractBar,
    required this.contractBg,
    required this.contractText,
    required this.contractCardBorder,
    // reminder: lain (netral abu)
    required this.neutralBar,
    // kartu kontrakan bergantian
    required this.kontrakanPurpleBg,
    required this.kontrakanPurpleFg,
    required this.kontrakanPinkBg,
    required this.kontrakanPinkFg,
  });

  final Color background;
  final Color surface;
  final Color cardBorder;
  final Color headerBg;
  final Color headerCircleA;
  final Color headerCircleB;
  final Color headerAccentText;
  final Color headerMutedText;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final Color onPrimary;
  final Color avatarBg;
  final Color avatarText;
  final Color tealPillBg;
  final Color tealPillText;
  final Color inputBorder;
  final Color statusFilledBg;
  final Color statusFilledText;
  final Color statusEmptyBg;
  final Color statusEmptyText;
  final Color statusDueBg;
  final Color statusDueText;
  final Color rentBar;
  final Color rentBg;
  final Color rentText;
  final Color rentCardBorder;
  final Color contractBar;
  final Color contractBg;
  final Color contractText;
  final Color contractCardBorder;
  final Color neutralBar;
  final Color kontrakanPurpleBg;
  final Color kontrakanPurpleFg;
  final Color kontrakanPinkBg;
  final Color kontrakanPinkFg;

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  static const light = AppColors(
    background: Color(0xFFF1EFE8),
    surface: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE5E3DA),
    headerBg: Color(0xFF085041),
    headerCircleA: Color(0xFF0F6E56),
    headerCircleB: Color(0xFF1D9E75),
    headerAccentText: Color(0xFF9FE1CB),
    headerMutedText: Color(0xFF9FE1CB),
    textPrimary: Color(0xFF262622),
    textSecondary: Color(0xFF6B6A63),
    textMuted: Color(0xFFA8A69C),
    primary: Color(0xFF085041),
    onPrimary: Color(0xFFFFFFFF),
    avatarBg: Color(0xFFFAC775),
    avatarText: Color(0xFF412402),
    tealPillBg: Color(0xFFE1F5EE),
    tealPillText: Color(0xFF085041),
    inputBorder: Color(0xFFD3D1C7),
    statusFilledBg: Color(0xFFEAF3DE),
    statusFilledText: Color(0xFF27500A),
    statusEmptyBg: Color(0xFFF1EFE8),
    statusEmptyText: Color(0xFF5F5E5A),
    statusDueBg: Color(0xFFFAEEDA),
    statusDueText: Color(0xFF854F0B),
    rentBar: Color(0xFFEF9F27),
    rentBg: Color(0xFFFAEEDA),
    rentText: Color(0xFF854F0B),
    rentCardBorder: Color(0xFFF0E2C0),
    contractBar: Color(0xFFD85A30),
    contractBg: Color(0xFFFAECE7),
    contractText: Color(0xFF993C1D),
    contractCardBorder: Color(0xFFF2DDD3),
    neutralBar: Color(0xFFB4B2A9),
    kontrakanPurpleBg: Color(0xFFCECBF6),
    kontrakanPurpleFg: Color(0xFF3C3489),
    kontrakanPinkBg: Color(0xFFF4C0D1),
    kontrakanPinkFg: Color(0xFF72243E),
  );

  static const dark = AppColors(
    background: Color(0xFF1C1C1A),
    surface: Color(0xFF252523),
    cardBorder: Color(0xFF3A3A37),
    headerBg: Color(0xFF04342C),
    headerCircleA: Color(0xFF085041),
    headerCircleB: Color(0xFF0F6E56),
    headerAccentText: Color(0xFF5DCAA5),
    headerMutedText: Color(0xFF5DCAA5),
    textPrimary: Color(0xFFF0EFE9),
    textSecondary: Color(0xFF9C9A92),
    textMuted: Color(0xFF7A7972),
    primary: Color(0xFF0F6E56),
    onPrimary: Color(0xFFFFFFFF),
    avatarBg: Color(0xFFFAC775),
    avatarText: Color(0xFF412402),
    tealPillBg: Color(0xFF0A2A22),
    tealPillText: Color(0xFF5DCAA5),
    inputBorder: Color(0xFF3A3A37),
    statusFilledBg: Color(0xFF20301A),
    statusFilledText: Color(0xFFA9D48A),
    statusEmptyBg: Color(0xFF2A2A27),
    statusEmptyText: Color(0xFF9C9A92),
    statusDueBg: Color(0xFF3A2F18),
    statusDueText: Color(0xFFFAC775),
    rentBar: Color(0xFFFAC775),
    rentBg: Color(0xFF3A2F18),
    rentText: Color(0xFFFBE8C9),
    rentCardBorder: Color(0xFF3A2F18),
    contractBar: Color(0xFFF0997B),
    contractBg: Color(0xFF3A2620),
    contractText: Color(0xFFF6DCD2),
    contractCardBorder: Color(0xFF3A2620),
    neutralBar: Color(0xFF7A7972),
    kontrakanPurpleBg: Color(0xFF3C3489),
    kontrakanPurpleFg: Color(0xFFCECBF6),
    kontrakanPinkBg: Color(0xFF72243E),
    kontrakanPinkFg: Color(0xFFF4C0D1),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? cardBorder,
    Color? headerBg,
    Color? headerCircleA,
    Color? headerCircleB,
    Color? headerAccentText,
    Color? headerMutedText,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? primary,
    Color? onPrimary,
    Color? avatarBg,
    Color? avatarText,
    Color? tealPillBg,
    Color? tealPillText,
    Color? inputBorder,
    Color? statusFilledBg,
    Color? statusFilledText,
    Color? statusEmptyBg,
    Color? statusEmptyText,
    Color? statusDueBg,
    Color? statusDueText,
    Color? rentBar,
    Color? rentBg,
    Color? rentText,
    Color? rentCardBorder,
    Color? contractBar,
    Color? contractBg,
    Color? contractText,
    Color? contractCardBorder,
    Color? neutralBar,
    Color? kontrakanPurpleBg,
    Color? kontrakanPurpleFg,
    Color? kontrakanPinkBg,
    Color? kontrakanPinkFg,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      cardBorder: cardBorder ?? this.cardBorder,
      headerBg: headerBg ?? this.headerBg,
      headerCircleA: headerCircleA ?? this.headerCircleA,
      headerCircleB: headerCircleB ?? this.headerCircleB,
      headerAccentText: headerAccentText ?? this.headerAccentText,
      headerMutedText: headerMutedText ?? this.headerMutedText,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      avatarBg: avatarBg ?? this.avatarBg,
      avatarText: avatarText ?? this.avatarText,
      tealPillBg: tealPillBg ?? this.tealPillBg,
      tealPillText: tealPillText ?? this.tealPillText,
      inputBorder: inputBorder ?? this.inputBorder,
      statusFilledBg: statusFilledBg ?? this.statusFilledBg,
      statusFilledText: statusFilledText ?? this.statusFilledText,
      statusEmptyBg: statusEmptyBg ?? this.statusEmptyBg,
      statusEmptyText: statusEmptyText ?? this.statusEmptyText,
      statusDueBg: statusDueBg ?? this.statusDueBg,
      statusDueText: statusDueText ?? this.statusDueText,
      rentBar: rentBar ?? this.rentBar,
      rentBg: rentBg ?? this.rentBg,
      rentText: rentText ?? this.rentText,
      rentCardBorder: rentCardBorder ?? this.rentCardBorder,
      contractBar: contractBar ?? this.contractBar,
      contractBg: contractBg ?? this.contractBg,
      contractText: contractText ?? this.contractText,
      contractCardBorder: contractCardBorder ?? this.contractCardBorder,
      neutralBar: neutralBar ?? this.neutralBar,
      kontrakanPurpleBg: kontrakanPurpleBg ?? this.kontrakanPurpleBg,
      kontrakanPurpleFg: kontrakanPurpleFg ?? this.kontrakanPurpleFg,
      kontrakanPinkBg: kontrakanPinkBg ?? this.kontrakanPinkBg,
      kontrakanPinkFg: kontrakanPinkFg ?? this.kontrakanPinkFg,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      headerBg: Color.lerp(headerBg, other.headerBg, t)!,
      headerCircleA: Color.lerp(headerCircleA, other.headerCircleA, t)!,
      headerCircleB: Color.lerp(headerCircleB, other.headerCircleB, t)!,
      headerAccentText: Color.lerp(headerAccentText, other.headerAccentText, t)!,
      headerMutedText: Color.lerp(headerMutedText, other.headerMutedText, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      avatarBg: Color.lerp(avatarBg, other.avatarBg, t)!,
      avatarText: Color.lerp(avatarText, other.avatarText, t)!,
      tealPillBg: Color.lerp(tealPillBg, other.tealPillBg, t)!,
      tealPillText: Color.lerp(tealPillText, other.tealPillText, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      statusFilledBg: Color.lerp(statusFilledBg, other.statusFilledBg, t)!,
      statusFilledText: Color.lerp(statusFilledText, other.statusFilledText, t)!,
      statusEmptyBg: Color.lerp(statusEmptyBg, other.statusEmptyBg, t)!,
      statusEmptyText: Color.lerp(statusEmptyText, other.statusEmptyText, t)!,
      statusDueBg: Color.lerp(statusDueBg, other.statusDueBg, t)!,
      statusDueText: Color.lerp(statusDueText, other.statusDueText, t)!,
      rentBar: Color.lerp(rentBar, other.rentBar, t)!,
      rentBg: Color.lerp(rentBg, other.rentBg, t)!,
      rentText: Color.lerp(rentText, other.rentText, t)!,
      rentCardBorder: Color.lerp(rentCardBorder, other.rentCardBorder, t)!,
      contractBar: Color.lerp(contractBar, other.contractBar, t)!,
      contractBg: Color.lerp(contractBg, other.contractBg, t)!,
      contractText: Color.lerp(contractText, other.contractText, t)!,
      contractCardBorder:
          Color.lerp(contractCardBorder, other.contractCardBorder, t)!,
      neutralBar: Color.lerp(neutralBar, other.neutralBar, t)!,
      kontrakanPurpleBg:
          Color.lerp(kontrakanPurpleBg, other.kontrakanPurpleBg, t)!,
      kontrakanPurpleFg:
          Color.lerp(kontrakanPurpleFg, other.kontrakanPurpleFg, t)!,
      kontrakanPinkBg: Color.lerp(kontrakanPinkBg, other.kontrakanPinkBg, t)!,
      kontrakanPinkFg: Color.lerp(kontrakanPinkFg, other.kontrakanPinkFg, t)!,
    );
  }
}
