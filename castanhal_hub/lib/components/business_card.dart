import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

class BusinessCard extends StatelessWidget {
  final String title;
  final String category;
  final String imageUrl;
  final double rating;
  final bool isPremium;
  final VoidCallback onWhatsAppTap;
  final VoidCallback onInstagramTap;

  const BusinessCard({
    super.key,
    required this.title,
    required this.category,
    required this.imageUrl,
    this.rating = 5.0,
    this.isPremium = false,
    required this.onWhatsAppTap,
    required this.onInstagramTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350, // Largura ideal para Grid Responsivo
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isPremium ? Border.all(color: AppTheme.premium, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem e Badge
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, _) => Container(color: Colors.grey[200]),
                  ),
                ),
                if (isPremium)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.premium,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Text(
                        'Destaque',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Estrelas
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: AppTheme.premium,
                        size: 20,
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 20),

                  // Botões de Ação
                  Row(
                    children: [
                      // Botão WhatsApp Largo
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onWhatsAppTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text("WhatsApp"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botão Instagram
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: onInstagramTap,
                          icon: const Icon(Icons.camera_alt_outlined),
                          color: AppTheme.primary,
                          tooltip: "Instagram",
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