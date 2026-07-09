import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared/models/business.dart';
import 'package:shared/services/supabase_service.dart';
import 'package:shared/utils/launcher_utils.dart';
import 'package:shared/theme/theme.dart';
import '../components/business_card.dart';
import '../components/shimmer_loading.dart';
import '../utils/route_transitions.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabase = SupabaseService();

  String _selectedCategory = 'Todos';
  String _searchQuery = '';

  List<String> _categories = ['Todos', 'Alimentação', 'Saúde', 'Serviços', 'Varejo'];
  List<Business> _businesses = [];
  bool _loading = true;
  bool _initialLoading = true;
  String? _error;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final cats = await _supabase.fetchCategories();
    if (mounted) setState(() => _categories = cats);
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _supabase.fetchFeed(
        category: _selectedCategory,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      if (mounted) {
        setState(() {
          _businesses = data;
          _loading = false;
          _initialLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
          _initialLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _loadData();
  }

  void _onCategoryChanged(String category) {
    setState(() => _selectedCategory = category);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Castanhal Hub',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'O que você procura em Castanhal?',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Lista de Categorias
          Container(
            height: 60,
            color: AppTheme.background,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => _onCategoryChanged(cat),
                    selectedColor: AppTheme.accent,
                    labelStyle: GoogleFonts.inter(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppTheme.accent : Colors.grey[300]!,
                    ),
                  ),
                );
              },
            ),
          ),

          // Conteúdo principal
          Expanded(child: _buildContent(isDesktop)),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDesktop) {
    if (_initialLoading && _loading) {
      return _buildLoadingGrid(isDesktop);
    }

    if (_error != null && _businesses.isEmpty) {
      return _buildError();
    }

    if (!_loading && _businesses.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.accent,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 2 : 1,
          mainAxisExtent: 400,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _businesses.length + (_loading ? 2 : 0),
        itemBuilder: (context, index) {
          // Loading shimmer ao final ao carregar mais
          if (index >= _businesses.length) {
            return ShimmerLoading.businessCard();
          }

          final b = _businesses[index];
          return BusinessCard(
            title: b.businessName,
            category: b.categoryName,
            imageUrl: b.coverUrl,
            rating: b.rating,
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
                RouteTransitions.slideFromRight(DetailScreen(business: b)),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Ops! Não foi possível carregar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verifique sua conexão e tente novamente.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.store_mall_directory_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Nenhum estabelecimento encontrado',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Tente buscar por outro termo.'
                : 'Nenhum negócio cadastrado nesta categoria.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid(bool isDesktop) {
    return ShimmerLoading.businessGrid(isDesktop: isDesktop);
  }
}