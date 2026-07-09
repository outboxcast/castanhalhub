import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:shared/theme/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.store, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),

              Text(
                'Castanhal Hub',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'v1.0.0',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),

              Text(
                'Conectando você aos melhores negócios de Castanhal, PA.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppTheme.textDark.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Features
              _buildFeature(Icons.search, 'Encontre', 'Descubra comércios locais perto de você'),
              const SizedBox(height: 16),
              _buildFeature(Icons.map, 'Explore', 'Visualize negócios no mapa interativo'),
              const SizedBox(height: 16),
              _buildFeature(Icons.favorite, 'Favorite', 'Salve seus lugares preferidos'),
              const SizedBox(height: 16),
              _buildFeature(Icons.chat, 'Conecte-se', 'Entre em contato via WhatsApp ou Instagram'),

              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 16),

              Text(
                'Desenvolvido com ❤️ em Castanhal, PA',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
              ),
              const SizedBox(height: 24),

              OutlinedButton.icon(
                onPressed: () {
                  launchUrl(Uri.parse('https://github.com/outboxcast/castanhalhub'));
                },
                icon: const Icon(Icons.code),
                label: const Text('Código aberto no GitHub'),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.accent, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textDark),
              ),
              Text(description,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
