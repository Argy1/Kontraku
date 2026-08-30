import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Membangun ThemeData terang & gelap.
///
/// Prinsip desain "Hangat & Jelas" (target pengguna termasuk orang tua):
/// - ukuran font lebih besar dari standar Material
/// - kontras tinggi, kartu besar, jarak lega
/// - sudut membulat 16px
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light, AppColors.light);
  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors c) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.primary,
      brightness: brightness,
    ).copyWith(
      surface: c.surface,
      primary: c.primary,
      onPrimary: c.onPrimary,
    );

    // Skala teks: body 15, judul kartu 16-17, angka ringkasan 22-26.
    final text = _textTheme(c);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      extensions: [c],
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.cardBorder, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: TextStyle(color: c.textMuted, fontSize: 15),
        labelStyle: TextStyle(color: c.textSecondary, fontSize: 14),
        border: _inputBorder(c.inputBorder),
        enabledBorder: _inputBorder(c.inputBorder),
        focusedBorder: _inputBorder(c.primary, width: 1.5),
        errorBorder: _inputBorder(c.contractBar),
        focusedErrorBorder: _inputBorder(c.contractBar, width: 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.cardBorder, thickness: 0.5),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.textPrimary,
        contentTextStyle: TextStyle(color: c.surface, fontSize: 14),
      ),
    );
  }

  static TextTheme _textTheme(AppColors c) {
    final primary = TextStyle(color: c.textPrimary);
    return TextTheme(
      // angka ringkasan besar di beranda
      displaySmall: primary.copyWith(fontSize: 26, fontWeight: FontWeight.w600),
      headlineSmall: primary.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
      // judul layar
      titleLarge: primary.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      // judul kartu / section
      titleMedium: primary.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: primary.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      // teks isi
      bodyLarge: primary.copyWith(fontSize: 15),
      bodyMedium: TextStyle(color: c.textSecondary, fontSize: 13),
      labelLarge: primary.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(color: c.textMuted, fontSize: 12),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 0.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
