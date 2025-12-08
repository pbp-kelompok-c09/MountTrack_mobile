import 'package:flutter/material.dart';

class CommunityTheme {
  static ThemeData get theme {
    const olive = Color(0xFF3E4A2A);
    const bgBeige = Color(0xFFDED3BE);
    const surfaceBeige = Color(0xFFE7DDC7);
    const inputBeige = Color(0xFFF3EBDD);
    const borderBeige = Color(0xFFB8AD95);
    const onOlive = Color(0xFFF5F0E6);

    final scheme = ColorScheme.fromSeed(
      seedColor: olive,
      brightness: Brightness.light,
    ).copyWith(
      background: bgBeige,
      surface: surfaceBeige,
      primary: olive,
      onPrimary: onOlive,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,

      // background default
      scaffoldBackgroundColor: bgBeige,

      // bantu beberapa widget lama supaya gak putih
      canvasColor: bgBeige,
      dialogBackgroundColor: surfaceBeige,

      appBarTheme: const AppBarTheme(
        backgroundColor: olive,
        foregroundColor: onOlive,
        elevation: 0,
        centerTitle: true,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBeige,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderBeige),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderBeige),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: olive, width: 1.6),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: olive,
          foregroundColor: onOlive,
        ),
      ),
    );
  }
}
