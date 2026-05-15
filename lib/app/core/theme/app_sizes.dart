import 'package:flutter/material.dart';

// ─── Spacing Constants ─────────────────────────────────────────────────────────
class AppSpacing {
  static const double xs = 5;
  static const double sm = 10;
  static const double md = 15;
  static const double lg = 20;
  static const double xl = 30;
  static const double xxl = 45;
  static const double xxxl = 60;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: 15);
}

// ─── Border Radius Constants ───────────────────────────────────────────────────
class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double full = 999;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get button => BorderRadius.circular(10);
  static BorderRadius get input => BorderRadius.circular(md);
  static BorderRadius get chip => BorderRadius.circular(full);
  static BorderRadius get modal => const BorderRadius.vertical(top: Radius.circular(xxl));
}
