import 'package:flutter/material.dart';
import '../../models/cinema.dart';
import '../../data/dummy_data.dart';
import '../../constants/app_color.dart';
import '../../constants/app_text_styles.dart';

class CinemaListTab extends StatefulWidget {
  const CinemaListTab({super.key});

  @override
  State<CinemaListTab> createState() => _CinemaListTabState();
}

class _CinemaListTabState extends State<CinemaListTab> {
  static const double _pagePadding = 20;
  static const String _allCitiesLabel = 'Semua';

  String _selectedCity = _allCitiesLabel;

  List<String> get _availableCities {
    final cities = DummyData.cinemas.map((cinema) => cinema.city).toSet().toList();
    cities.sort();
    return [_allCitiesLabel, ...cities];
  }

  List<Cinema> get _filteredCinemas {
    if (_selectedCity == _allCitiesLabel) return DummyData.cinemas;
    return DummyData.cinemas.where((cinema) => cinema.city == _selectedCity).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cinemas = _filteredCinemas;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Daftar Bioskop',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: _pagePadding),
            child: PopupMenuButton<String>(
              initialValue: _selectedCity,
              onSelected: (city) {
                setState(() {
                  _selectedCity = city;
                });
              },
              itemBuilder: (context) {
                return _availableCities.map((city) {
                  return PopupMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    _selectedCity,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
      body: cinemas.isEmpty
          ? Center(
        child: Text(
          _selectedCity == _allCitiesLabel
              ? 'Belum ada bioskop untuk ditampilkan.'
              : 'Belum ada bioskop di $_selectedCity.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(_pagePadding),
        itemCount: cinemas.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildCinemaCard(cinemas[index]);
        },
      ),
    );
  }

  Widget _buildCinemaCard(Cinema cinema) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fitur detail bioskop akan hadir')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  cinema.logoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.business, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cinema.name,
                    style: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cinema.address,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 12, color: AppColors.cta),
                            const SizedBox(width: 4),
                            Text(
                              cinema.rating.toStringAsFixed(1),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        cinema.operatingHours,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}