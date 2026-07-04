import 'package:flutter/material.dart';
import '../../constants/app_color.dart';
import '../../constants/app_text_styles.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _searchHint = 'Cari film...';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      setState(() {
        if (_tabController.index == 0) {
          _searchHint = 'Cari film...';
        }
        else {
          _searchHint = 'Cari bioskop...';
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,

        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          titleSpacing: 0,

          title: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: _searchHint,
              hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              border: InputBorder.none,
            ),
            style: AppTextStyles.bodyLarge,
          ),

          bottom: TabBar(
            controller: _tabController,

            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            dividerColor: Colors.transparent,
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),

            tabs: const [
              Tab(text: 'Film'),
              Tab(text: 'Bioskop'),
            ],
          ),
        ),

        body: TabBarView(
          controller: _tabController,

          children: const [
            Center(child: Text('Daftar pencarian Film nanti di sini')),
            Center(child: Text('Daftar pencarian Bioskop nanti di sini')),
          ],
        ),
      ),
    );
  }
}