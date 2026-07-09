import 'dart:io';
import 'package:flutter/material.dart';
import 'package:movie_app/constants/app_text_styles.dart';
import 'package:movie_app/constants/app_color.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? imagePath;
  final VoidCallback onEditPressed;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.imagePath,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            // ignore: deprecated_member_use
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage: imagePath != null
                ? FileImage(File(imagePath!))
                : null,
            child: imagePath == null
                ? Icon(Icons.person, size: 48, color: theme.colorScheme.primary)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: AppTextStyles.headingLarge.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEditPressed,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.edit, color: AppColors.primary, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
