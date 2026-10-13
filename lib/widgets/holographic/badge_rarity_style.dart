import 'package:flutter/material.dart';

import '../../models/home_models.dart';
import '../../theme/triluma_theme.dart';
import 'sticker_effects.dart';

/// Rarity picks the seal silhouette and its finish: colours, foil and motion.
class BadgeRarityStyle {
  const BadgeRarityStyle({
    required this.colors,
    required this.accent,
    required this.frameStyle,
    this.foilColors,
    this.shine = 1,
    this.tilt = 1,
    this.parallax = 1,
    this.shadow = 1,
    this.particles = 14,
    this.glow = 0,
    this.ornate = true,
    this.glint = 0,
  });

  /// Strength of the soft highlight that floats over the glass with the tilt.
  final double glint;

  /// Rim decorations (studs, engraving, travelling sparkles). Off keeps a
  /// plain foil ring.
  final bool ornate;
  final List<Color> colors;
  final List<Color>? foilColors;
  List<Color> get showcaseColors => foilColors ?? colors;
  final Color accent;
  final BadgeFrameStyle frameStyle;
  final double shine, tilt, parallax, shadow, glow;
  final int particles;

  /// The four badge seals. Finish grows from matte linen wax (common) to
  /// full gold foil (legendary).
  static const styles = {
    // Matte linen wax: a faint warm tint, just enough to read as coloured.
    BadgeRarity.common: BadgeRarityStyle(
      frameStyle: BadgeFrameStyle.matte,
      colors: [
        Color(0xFFE6DACB),
        Color(0xFFF3ECE2),
        Color(0xFFD9C9B5),
        Color(0xFFEBE1D4),
      ],
      accent: TrilumaColors.secondary,
      shine: 0,
      tilt: .4,
      parallax: .4,
      shadow: .45,
      particles: 0,
    ),
    // Baby blue melting into peach: a soft two-colour gradient, apart from
    // the lilac/teal epic and the gold legendary.
    BadgeRarity.rare: BadgeRarityStyle(
      frameStyle: BadgeFrameStyle.prismatic,
      colors: [
        Color(0xFFAFD3F2),
        Color(0xFFC9DFF3),
        Color(0xFFF6CDB6),
        Color(0xFFF2A488),
        Color(0xFFF6CDB6),
        Color(0xFFC9DFF3),
      ],
      foilColors: [
        Color(0xFFA2CBF0),
        Color(0xFFC4DCF3),
        Color(0xFFF5C4A9),
        Color(0xFFEE9A7C),
        Color(0xFFF5C4A9),
        Color(0xFFC4DCF3),
      ],
      accent: TrilumaColors.brand,
      shine: .45,
      ornate: false,
      glint: 1,
    ),
    BadgeRarity.epic: BadgeRarityStyle(
      frameStyle: BadgeFrameStyle.prismatic,
      colors: [
        TrilumaColors.lilac,
        Color(0xFFD8C0F0),
        TrilumaColors.teal,
        Color(0xFFB6AEDE),
        TrilumaColors.surface,
      ],
      accent: Color(0xFF715097),
      shine: .72,
      tilt: 1.05,
      parallax: 1.15,
      particles: 16,
      glow: .05,
    ),
    BadgeRarity.legendary: BadgeRarityStyle(
      frameStyle: BadgeFrameStyle.prismatic,
      colors: [
        TrilumaColors.gold,
        TrilumaColors.paleGold,
        Color(0xFFFFF1C9),
        TrilumaColors.teal,
        TrilumaColors.lilac,
        TrilumaColors.paleGold,
      ],
      accent: Color(0xFF805B20),
      shine: 1,
      tilt: 1.1,
      parallax: 1.3,
      particles: 20,
      glow: .1,
    ),
  };

  static BadgeRarityStyle of(BadgeRarity rarity) => styles[rarity]!;

  /// Seal silhouette for each rarity.
  static SealShape shapeOf(BadgeRarity rarity) => switch (rarity) {
    BadgeRarity.common => SealShape.pressedThick,
    BadgeRarity.rare || BadgeRarity.epic => SealShape.pressed,
    BadgeRarity.legendary => SealShape.poured,
  };
}
