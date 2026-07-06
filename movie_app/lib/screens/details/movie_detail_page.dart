import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../constants/app_color.dart';

class MovieDetailPage extends StatelessWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Detail Film',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: Center(
        child: Text(
          'Ini halaman detail film: ${movie.title}',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}