import 'package:flutter/material.dart';

/// Design tokens for spacing, radii and motion used by premium UI.
class DT {
  // Spacing scale (allowed values only)
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s48 = 48.0;

  // Radii
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(14));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(20));

  // Motion
  static const Duration motionShort = Duration(milliseconds: 180);
  static const Duration motionMed = Duration(milliseconds: 300);
  static const Duration motionLong = Duration(milliseconds: 420);
}
