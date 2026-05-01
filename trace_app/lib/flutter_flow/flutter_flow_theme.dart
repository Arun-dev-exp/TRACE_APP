import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlutterFlowTheme {
  static FlutterFlowTheme of(BuildContext context) => FlutterFlowTheme();

  // TRACE brand palette — trust + alert
  Color primary = const Color(0xFF0F3D5C);        // deep navy
  Color secondary = const Color(0xFF1E88E5);       // action blue
  Color tertiary = const Color(0xFFFFA726);        // alert amber
  Color success = const Color(0xFF2E7D32);
  Color warning = const Color(0xFFF9A825);
  Color error = const Color(0xFFD32F2F);

  Color primaryBackground = const Color(0xFFF5F7FA);
  Color secondaryBackground = Colors.white;
  Color primaryText = const Color(0xFF101828);
  Color secondaryText = const Color(0xFF667085);
  Color divider = const Color(0xFFE4E7EC);

  TextStyle get displayLarge =>
      GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: primaryText);
  TextStyle get headlineMedium =>
      GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: primaryText);
  TextStyle get headlineSmall =>
      GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: primaryText);
  TextStyle get titleMedium =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: primaryText);
  TextStyle get bodyLarge =>
      GoogleFonts.inter(fontSize: 15, color: primaryText);
  TextStyle get bodyMedium =>
      GoogleFonts.inter(fontSize: 14, color: primaryText);
  TextStyle get bodySmall =>
      GoogleFonts.inter(fontSize: 12, color: secondaryText);
  TextStyle get labelMedium =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: secondaryText);
}
