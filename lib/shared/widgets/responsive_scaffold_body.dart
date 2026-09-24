import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';

/// Wraps a screen's body content so it's centered and width-capped on
/// tablet/desktop screens, instead of stretching form fields and cards
/// uncomfortably wide — while staying completely unchanged on phones.
class ResponsiveScaffoldBody extends StatelessWidget {
  final Widget child;

  const ResponsiveScaffoldBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final maxWidth = Responsive.contentMaxWidth(context);

    if (maxWidth == double.infinity) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}