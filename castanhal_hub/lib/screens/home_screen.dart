import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../utils/launcher_utils.dart';
import '../components/business_card.dart'; // Componente criado anteriormente
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabase = SupabaseService();
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  
  final List<String> _categories = ['Todos', 'Alimentação', 'Saúde', 'Serviços', 'Varejo'];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Castanhal Hub"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: "O que você procura em Castanhal?",
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Lista de Categorias
          SizedBox(
            height: 60,
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
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: const Color(0xFF00A1DF),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  ),
                );
              },
            ),
          ),

          // Grid de Negócios
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _supabase.fetchFeed(category: _selectedCategory, searchQuery: _searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingGrid(isDesktop);
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Erro ao carregar dados. Tente novamente."));
                }

                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Center(child: Text("Nenhum estabelecimento encontrado."));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 2 : 1, // 2 colunas Web, 1 Mobile
                    mainAxisExtent: 400,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final b = data[index];
                    return BusinessCard(
                      title: b['business_name'],
                      category: b['category_name'],
                      imageUrl: b['cover_url'],
                      isPremium: b['is_premium'] ?? false,
                      onWhatsAppTap: () => LauncherUtils.openWhatsApp(
                        businessId: b['id'],
                        phone: b['phone_number'],
                      ),
                      onInstagramTap: () => LauncherUtils.openInstagram(
                        businessId: b['id'],
                        handle: b['instagram_handle'],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid(bool isDesktop) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 2 : 1,
        mainAxisExtent: 400,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
      ),
    );
  }
}