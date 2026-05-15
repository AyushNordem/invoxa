import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Centralized text style helper
/// Usage: StyleResource.instance.styleSemiBold(fontSize: 16, color: AppTheme.textPrimary)
class StyleResource {
  static StyleResource? _instance;
  static StyleResource get instance => _instance ??= StyleResource._init();
  StyleResource._init();

  // common font weights
  final FontWeight semiBold = FontWeight.w600;
  final FontWeight regular = FontWeight.w400;
  final FontWeight light = FontWeight.w300;
  final FontWeight medium = FontWeight.w500;
  final FontWeight bold = FontWeight.w700;
  final FontWeight extraBold = FontWeight.w900;

  // Default font family and size will be taken from AppTheme
  double get _defaultSize => 14;
  String? get _fontFamily => AppTheme.fontFamily;
  Color get _defaultColor => AppTheme.textPrimary;

  TextStyle styleRobotoBold({double? fontSize, Color? color}) {
    return TextStyle(fontSize: fontSize ?? _defaultSize, color: color ?? _defaultColor, fontFamily: _fontFamily, fontWeight: bold);
  }

  TextStyle styleRobotoMedium({double? fontSize, Color? color}) {
    return TextStyle(fontSize: fontSize ?? _defaultSize, color: color ?? _defaultColor, fontFamily: _fontFamily, fontWeight: medium);
  }

  TextStyle styleRobotoRegular({double? fontSize, Color? color, double? wordSpacing}) {
    return TextStyle(fontSize: fontSize ?? _defaultSize, color: color ?? _defaultColor, fontFamily: _fontFamily, fontWeight: regular, wordSpacing: wordSpacing);
  }

  TextStyle styleBold({double? fontSize, Color? color, Color? decorationColor, TextDecoration? decoration, double? height}) {
    return TextStyle(fontSize: fontSize ?? _defaultSize, color: color ?? _defaultColor, decoration: decoration, height: height, decorationColor: decorationColor, fontFamily: _fontFamily, fontWeight: bold);
  }

  TextStyle styleMedium({double? fontSize, Color? color, double? height, double? letterSpacing}) {
    return TextStyle(fontSize: fontSize ?? _defaultSize, letterSpacing: letterSpacing, color: color ?? _defaultColor, height: height, fontFamily: _fontFamily, fontWeight: medium);
  }

  TextStyle styleRegular({double? fontSize, Color? color, double? wordSpacing, Color? decorationColor, FontStyle? fontStyle, double? height, double? letterSpacing}) {
    return TextStyle(fontSize: fontSize ?? _defaultSize, color: color ?? _defaultColor, fontFamily: _fontFamily, fontWeight: regular, height: height, decorationColor: decorationColor, letterSpacing: letterSpacing, fontStyle: fontStyle ?? FontStyle.normal, wordSpacing: wordSpacing);
  }

  TextStyle styleSemiBold({double? fontSize, Color? color, TextDecoration? decoration, double? height, Color? decorationColor, double? letterSpacing}) {
    return TextStyle(fontSize: fontSize ?? _defaultSize, color: color ?? _defaultColor, fontFamily: _fontFamily, decoration: decoration, height: height, decorationColor: decorationColor, letterSpacing: letterSpacing, fontWeight: semiBold);
  }

  TextStyle styleExtraBold({double? fontSize, Color? color}) {
    return TextStyle(fontSize: fontSize ?? _defaultSize, color: color ?? _defaultColor, fontFamily: _fontFamily, fontWeight: extraBold);
  }

  TextStyle styleLight({double? fontSize, Color? color}) {
    return TextStyle(fontSize: fontSize ?? _defaultSize, color: color ?? _defaultColor, fontFamily: _fontFamily, fontWeight: light);
  }

  /// General purpose: return a TextStyle with an explicit [weight].
  TextStyle styleWithWeight({double? fontSize, Color? color, FontWeight? weight, double? height, double? letterSpacing, TextDecoration? decoration, FontStyle? fontStyle}) {
    return TextStyle(fontSize: fontSize ?? _defaultSize, color: color ?? _defaultColor, fontFamily: _fontFamily, fontWeight: weight ?? regular, height: height, letterSpacing: letterSpacing, decoration: decoration, fontStyle: fontStyle);
  }
}
