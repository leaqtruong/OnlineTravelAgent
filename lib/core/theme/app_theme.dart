import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF176FF2);
  static const Color backgroundGray = Color(0xFFF3F8FE);
  static const Color darkGray = Color(0xFF4D5652);
  static const Color textBlack = Color(0xFF212121);
  static const Color textGray = Colors.grey;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textBlack),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textBlack),
        bodyLarge: GoogleFonts.inter(color: textBlack),
        bodyMedium: GoogleFonts.inter(color: textBlack),
        labelSmall: GoogleFonts.inter(color: textGray, fontSize: 11),
      ),
    );
  }
}
