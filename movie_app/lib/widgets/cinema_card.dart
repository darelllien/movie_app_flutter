import 'package:flutter/material.dart';
import 'package:movie_app/constants/app_color.dart';
import 'package:movie_app/constants/app_text_styles.dart';
import 'package:movie_app/models/cinema.dart';

class CinemaCard extends StatelessWidget {
  final Cinema cinema;
  final VoidCallback onBuyPressed;

  const CinemaCard({
    super.key,
    required this.cinema,
    required this.onBuyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            cinema.logoUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 50,
                color: AppColors.base,
                child: const Icon(Icons.movie, color: AppColors.primary),
              );
            },
          ),
        ),
        title: Text(
          cinema.name,
          style: AppTextStyles.headingSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              cinema.operatingHours,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cta,
            foregroundColor: AppColors.textOnCta,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onBuyPressed,
          child: Text('Beli', style: AppTextStyles.button),
        ),
      ),
    );
  }
}
