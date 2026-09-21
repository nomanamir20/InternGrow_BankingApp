import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Renders a profile photo regardless of whether it's a web base64 data URL
/// or a native file path — the two storage formats from ImageStorageService.
class ProfileAvatar extends StatelessWidget {
  final String? photoPath;
  final String initial;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.photoPath,
    required this.initial,
    this.radius = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (photoPath == null || photoPath!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary,
        child: Text(
          initial,
          style: TextStyle(color: Colors.white, fontSize: radius * 0.8, fontWeight: FontWeight.w700),
        ),
      );
    }

    if (kIsWeb || photoPath!.startsWith('data:image')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary,
        backgroundImage: NetworkImage(photoPath!),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      backgroundImage: FileImage(File(photoPath!)),
    );
  }
}