import 'package:flutter/widgets.dart';

/// The few Lucide icons the app uses, drawn from the bundled Lucide font.
///
/// Declared here instead of importing a Lucide package: those classes hold
/// ~30k constants, which overflows the stack of the web debug compiler.
/// To add an icon, look up its code point on https://lucide.dev or in the
/// lucide_icons_flutter sources.
abstract final class ManduaraIcons {
  static const _font = 'Lucide';

  static const house = IconData(57589, fontFamily: _font);
  static const map = IconData(57616, fontFamily: _font);
  static const stamp = IconData(58299, fontFamily: _font);
  static const award = IconData(57423, fontFamily: _font);
  static const user = IconData(57759, fontFamily: _font);
  static const bell = IconData(57433, fontFamily: _font);
  static const beer = IconData(58063, fontFamily: _font);
  static const landmark = IconData(57914, fontFamily: _font);
  static const leaf = IconData(58078, fontFamily: _font);
  static const chevronRight = IconData(57455, fontFamily: _font);
  static const mapPin = IconData(57617, fontFamily: _font);
  static const arrowLeft = IconData(57416, fontFamily: _font);
  static const arrowRight = IconData(57417, fontFamily: _font);
  static const share = IconData(57685, fontFamily: _font);
  static const circleCheck = IconData(57894, fontFamily: _font);
  static const lock = IconData(57611, fontFamily: _font);
  static const compass = IconData(57499, fontFamily: _font);
  static const bookOpen = IconData(57439, fontFamily: _font);
  static const tag = IconData(57727, fontFamily: _font);
}
