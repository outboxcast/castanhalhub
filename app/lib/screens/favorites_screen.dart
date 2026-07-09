import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared/models/business.dart';
import 'package:shared/services/supabase_service.dart';
import 'package:shared/services/favorites_service.dart';
import 'package:shared/utils/launcher_utils.dart';
import 'package:shared/theme/theme.dart';
import '../components/business_card.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final SupabaseService _supabase = SupabaseService();
  final FavoritesService _favorites = FavoritesService();
  List<Business> _favoriteBusinesses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    try {
      final ids = await _favorites.getFavorites();
      if (ids.isEmpty) {
        if (mounted) setState(() { _favoriteBusinesses = []; _loading = false; });
        return;
      }

      // Carrega cada negócio pelo ID
      final businesses = <Business>[];
      for (final id in ids) {
        final b = await _supabase.fetchBusinessById(id);
        if (b != null) businesses.add(b);
      }
      if (mounted) setState(() { _favoriteBusinesses = businesses; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadFavorites),
        ],
      ),
      body: _buildBody(isDesktop),
    );
  }

  Widget _buildBody(bool isDesktop) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favoriteBusinesses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border, size: 72, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Nenhum favorito ainda',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toque no coração ao ver um negócio para adicioná-lo aqui.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 2 : 1,
          mainAxisExtent: 400,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _favoriteBusinesses.length,
        itemBuilder: (context, index) {
          final b = _favoriteBusinesses[index];
          return BusinessCard(
            title: b.businessName,
            category: b.categoryName,
            imageUrl: b.coverUrl,
            isPremium: b.isPremium,
            onWhatsAppTap: () => LauncherUtils.openWhatsApp(
              businessId: b.id,
              phone: b.phoneNumber,
            ),
            onInstagramTap: () => LauncherUtils.openInstagram(
              businessId: b.id,
              handle: b.instagramHandle ?? '',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailScreen(business: b)),
              );
            },
          );
        },
      ),
    );
  }
}
