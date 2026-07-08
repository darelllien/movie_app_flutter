import 'package:flutter/material.dart';
import 'package:movie_app/constants/app_color.dart';
import 'package:movie_app/constants/app_text_styles.dart';

class CinemaScheduleCard extends StatelessWidget {
  final Map<String, dynamic> cinema;
  final String? selectedCinemaName;
  final String? selectedShowtime;
  final Function(String cinemaName, String showtime) onShowtimeSelected;
  final VoidCallback onViewMore;
  final bool isFirst;

  const CinemaScheduleCard({
    super.key,
    required this.cinema,
    required this.selectedCinemaName,
    required this.selectedShowtime,
    required this.onShowtimeSelected,
    required this.onViewMore,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final allShowtimes = cinema['showtimes'] as List<String>;
    List<String> displayedShowtimes = allShowtimes.length > 6 ? allShowtimes.sublist(0, 6) : allShowtimes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isFirst)
          Container(
            height: 8,
            color: Colors.grey[200],
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CINEMA HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cinema['cinemaName']!,
                      style: AppTextStyles.headingSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      cinema['brand']!,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // TYPE & PRICE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cinema['type']!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    cinema['price']!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // SHOWTIMES GRID
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ...displayedShowtimes.map((time) {
                    final isSelected = selectedCinemaName == cinema['cinemaName'] && selectedShowtime == time;
                    return GestureDetector(
                      onTap: () => onShowtimeSelected(cinema['cinemaName']!, time),
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 32 - 36) / 4,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          time,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
