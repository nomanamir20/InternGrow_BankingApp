import 'package:flutter/material.dart';

/// Centralized breakpoints — used across the app instead of each screen
/// picking its own arbitrary width thresholds.
class Responsive {
  Responsive._();

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= tabletBreakpoint;

  /// Caps content width on wide screens so text/cards don't stretch
  /// uncomfortably edge-to-edge — a common, simple responsive pattern.
  static double contentMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 500;
    if (isTablet(context)) return 700;
    return double.infinity;
  }
}