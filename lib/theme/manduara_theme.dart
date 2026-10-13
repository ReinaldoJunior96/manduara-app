import 'package:flutter/material.dart';

/// Manduarã palette: a travel journal. Paper, ink green and the terracotta of
/// a wax seal.
abstract final class ManduaraColors {
  static const paper = Color(0xFFF5EFE4);
  static const card = Color(0xFFFFFCF6);
  static const ink = Color(0xFF17322C);
  static const muted = Color(0xFF6B7A72);
  static const inactive = Color(0xFF7F8B84);
  static const label = Color(0xFF7D725F);
  static const wax = Color(0xFFB4543A);
  static const hairline = Color(0xFFE4DACB);
  static const contour = Color(0xFFE2D6C2);
  static const cardBorder = Color(0xFFECE3D4);
}

/// Instrument Serif for display, Figtree for everything else.
abstract final class ManduaraText {
  static const display = 'Instrument Serif';
  static const body = 'Figtree';

  static const headline = TextStyle(
    fontFamily: display,
    fontSize: 40,
    height: 1.02,
    letterSpacing: -.6,
    color: ManduaraColors.ink,
  );
  static const title = TextStyle(
    fontFamily: display,
    fontSize: 26,
    height: 1.1,
    color: ManduaraColors.ink,
  );
  static const eyebrow = TextStyle(
    fontFamily: body,
    fontSize: 11,
    letterSpacing: 2,
    fontWeight: FontWeight.w600,
    color: ManduaraColors.label,
  );
  static const bodyStrong = TextStyle(
    fontFamily: body,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: ManduaraColors.ink,
  );
}
