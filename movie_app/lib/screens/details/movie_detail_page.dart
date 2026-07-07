import 'package:flutter/material.dart';
import 'package:movie_app/constants/app_color.dart';
import 'package:movie_app/constants/app_text_styles.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/widgets/ticket_buttom_sheet.dart';
import 'package:movie_app/widgets/cinema_card.dart';
import 'package:movie_app/data/dummy_data.dart';

class MovieDetailPage extends StatelessWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. BACKDROP & GRADIENT
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        movie.fullBackdropUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: AppColors.primary);
                        },
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black54,
                              Colors.transparent,
                              Colors.black87,
                            ],
                          ),
                        ),
                      ),
                      // PLAY BUTTON OVERLAY
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. BACK BUTTON (Kiri Atas)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // 3. OVERLAPPING POSTER
                Positioned(
                  top: 190, // 250 (backdrop) - 60 (overlap)
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        movie.fullPosterUrl,
                        width: 110,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 110,
                            height: 160,
                            color: AppColors.primary,
                            child: const Icon(
                              Icons.broken_image,
                              color: AppColors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // 4. TITLE & GENRES (Sebelah kanan poster, di bawah backdrop)
                Positioned(
                  top: 260, // 250 (backdrop) + 10 margin
                  left: 142, // 16 (padding) + 110 (lebar poster) + 16 (jarak)
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.cta,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${movie.voteAverage.toStringAsFixed(1)} [TMDB]',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.title,
                        style: AppTextStyles.headingLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: movie.genreNames.split(', ').map((genre) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.textSecondary,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              genre,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 5. MAIN CONTENT (Overview & Cast)
            Padding(
              padding: const EdgeInsets.only(
                top: 130,
                left: 16,
                right: 16,
              ), // Memberi ruang untuk poster yang menjulur ke bawah
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMovieOverview(),
                  const SizedBox(height: 24),
                  _buildTopCast(),
                  const SizedBox(height: 24),
                  _buildCinemaList(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        // Dibungkus SafeArea agar tombol tidak tertutup oleh system navigation bar OS.
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cta,
              foregroundColor: AppColors.textOnCta,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
            onPressed: () {
              TicketBottomSheet.show(
                context,
                movieTitle: movie.title,
                cinemaName: 'Pilih Bioskop',
              );
            },
            child: Text(
              'Book Tickets',
              style: AppTextStyles.button.copyWith(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovieOverview() {
    return Text(
      movie.overview,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildTopCast() {
    // Dummy data untuk mensimulasikan foto cast yang elegan
    final List<Map<String, String>> dummyCast = [
      {'image': 'https://randomuser.me/api/portraits/men/32.jpg'},
      {'image': 'https://randomuser.me/api/portraits/women/44.jpg'},
      {'image': 'https://randomuser.me/api/portraits/men/46.jpg'},
      {'image': 'https://randomuser.me/api/portraits/men/22.jpg'},
      {'image': 'https://randomuser.me/api/portraits/women/12.jpg'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Cast :',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100, // Tinggi untuk menampung gambar kapsul vertikal
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dummyCast.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  color: AppColors.textSecondary.withValues(alpha: 0.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Image.network(
                    dummyCast[index]['image']!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        color: AppColors.textSecondary,
                        size: 32,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCinemaList() {
    // Assignment mewajibkan list maksimal 5 bioskop di detail film.
    final cinemas = DummyData.cinemas.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bioskop Tersedia',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...cinemas.map((cinema) {
          return CinemaCard(
            cinema: cinema,
            onBuyPressed: () {},
          );
        }),
      ],
    );
  }
}
