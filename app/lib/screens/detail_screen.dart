import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:shared/models/business.dart';
import 'package:shared/services/supabase_service.dart';
import 'package:shared/services/favorites_service.dart';
import 'package:shared/theme/theme.dart';
import '../providers/auth_provider.dart';
import '../components/login_required_sheet.dart';

class DetailScreen extends StatefulWidget {
  final Business business;

  const DetailScreen({super.key, required this.business});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final SupabaseService _supabase = SupabaseService();
  final FavoritesService _favorites = FavoritesService();
  bool _isFavorite = false;
  bool _showFullDescription = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final fav = await _favorites.isFavorite(widget.business.id);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    // Proteção: apenas usuários logados podem favoritar
    final auth = context.read<AuthProvider>();
    if (!auth.isFullyAuthenticated) {
      LoginRequiredSheet.show(context, featureName: 'favoritos');
      return;
    }

    await _favorites.toggleFavorite(widget.business.id);
    await _loadFavoriteState();
  }

  void _share() {
    final text = '''
🏪 ${widget.business.businessName}
📍 ${widget.business.address ?? 'Castanhal, PA'}
📱 ${widget.business.phoneNumber}

Confira no Castanhal Hub!
''';
    Share.share(text);
  }

  Future<void> _call() async {
    final uri = Uri.parse('tel:${widget.business.phoneNumber}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.business;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar com imagem de capa
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    b.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      child: const Icon(Icons.store, size: 80, color: Colors.white24),
                    ),
                  ),
                  // Gradiente escuro sobre a imagem
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                        ),
                      ),
                    ),
                  ),
                  // Nome e categoria na imagem
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.categoryName.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b.businessName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge Premium
                  if (b.isPremium)
                    Positioned(
                      top: 60,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.premium,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 16, color: AppTheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Destaque',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              // Favoritar
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
                tooltip: 'Favoritar',
              ),
              // Compartilhar
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _share,
                tooltip: 'Compartilhar',
              ),
            ],
          ),

          // Conteúdo
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Informações principais
                _buildInfoRow(Icons.star_half, '${b.rating.toStringAsFixed(1)} / 5.0'),
                if (b.address != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.location_on_outlined, b.address!),
                ],
                const SizedBox(height: 12),
                _buildInfoRow(Icons.phone_outlined, b.phoneNumber),

                const SizedBox(height: 24),

                // Descrição
                if (b.description != null && b.description!.isNotEmpty) ...[
                  _buildSectionTitle('Sobre'),
                  const SizedBox(height: 8),
                  Text(
                    b.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                    maxLines: _showFullDescription ? null : 3,
                    overflow: _showFullDescription ? null : TextOverflow.ellipsis,
                  ),
                  if (b.description!.length > 120)
                    GestureDetector(
                      onTap: () => setState(() => _showFullDescription = !_showFullDescription),
                      child: Text(
                        _showFullDescription ? 'Mostrar menos' : 'Ler mais',
                        style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],

                // Ações rápidas
                _buildSectionTitle('Ações'),
                const SizedBox(height: 12),
                _buildActionButtons(b),

                const SizedBox(height: 32),

                // Mapa
                _buildSectionTitle('Localização'),
                const SizedBox(height: 12),
                _buildMap(b),

                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDark)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.accent,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildActionButtons(Business b) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _supabase.logClick(b.id, 'whatsapp').then((_) {
              final phone = b.phoneNumber.replaceAll(RegExp(r'\D'), '');
              launchUrl(Uri.parse('https://wa.me/$phone'), mode: LaunchMode.externalApplication);
            }),
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text('WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _call,
            icon: const Icon(Icons.phone_outlined, size: 18),
            label: const Text('Ligar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (b.instagramHandle != null)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                _supabase.logClick(b.id, 'instagram');
                launchUrl(
                  Uri.parse('https://instagram.com/${b.instagramHandle!.replaceAll('@', '')}'),
                  mode: LaunchMode.externalApplication,
                );
              },
              icon: const Icon(Icons.camera_alt_outlined),
              color: AppTheme.primary,
              tooltip: 'Instagram',
            ),
          ),
      ],
    );
  }

  Widget _buildMap(Business b) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(b.latitude, b.longitude),
            initialZoom: 15,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.castanhalhub.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(b.latitude, b.longitude),
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
