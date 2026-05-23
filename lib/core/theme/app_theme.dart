import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF176FF2);
  static const Color backgroundGray = Color(0xFFF3F8FE);
  static const Color darkGray = Color(0xFF4D5652);
  static const Color textBlack = Color(0xFF212121);
  static const Color textGray = Colors.grey;

  // Sử dụng font hệ thống mặc định để tránh lỗi nạp font gây treo app
  static final TextTheme _textTheme = const TextTheme().copyWith(
    displayLarge: const TextStyle(fontWeight: FontWeight.bold, color: textBlack),
    titleLarge: const TextStyle(fontWeight: FontWeight.bold, color: textBlack),
    bodyLarge: const TextStyle(color: textBlack),
    bodyMedium: const TextStyle(color: textBlack),
    labelSmall: const TextStyle(color: textGray, fontSize: 11),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      surface: Colors.white,
    ),
    textTheme: _textTheme,
  );
}
