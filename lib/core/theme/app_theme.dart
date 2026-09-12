import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData lightTheme=ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.whiteColor,
    ),
    scaffoldBackgroundColor: AppColors.whiteColor,
    textTheme: GoogleFonts.soraTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w700,
          color: AppColors.whiteColor
        ),
        headlineMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.whiteColor
        ),
        headlineSmall: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w500,
          color: AppColors.whiteColor
        ),
        titleLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor
        ),
        titleMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryColor
        ),
        titleSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryColor
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.blackColor
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w300,
          color: AppColors.primaryColor
        )
      )
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
        padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
        textStyle: GoogleFonts.sora(
          fontWeight: FontWeight.w600,
          color: AppColors.whiteColor,
          fontSize: 16
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20))
      )
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: AppColors.whiteColor,
      labelStyle: GoogleFonts.sora(color: AppColors.greyColor),
      hintStyle: GoogleFonts.sora(color: AppColors.greyColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.greyColor,width: 1.5)
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.greyColor,width: 1.5)
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.greyColor,width: 1.5)
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.redColor,width: 1.5)
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.redColor,width: 1.5)
      ),
      errorStyle: GoogleFonts.sora(color: AppColors.redColor,fontSize: 13),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.whiteColor,
      shape: CircleBorder()
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        textStyle: GoogleFonts.sora(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );
}