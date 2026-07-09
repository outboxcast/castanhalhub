import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Componente reutilizável de shimmer para cards de carregamento.
class ShimmerLoading {
  /// Card shimmer no estilo dos cards de negócio
  static Widget businessCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 10, width: 80, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 16, width: 180, color: Colors.white),
                  const SizedBox(height: 12),
                  Container(height: 14, width: 120, color: Colors.white),
                  const SizedBox(height: 20),
                  Container(height: 40, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Grid de shimmer cards
  static Widget businessGrid({int itemCount = 4, bool isDesktop = false}) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 2 : 1,
        mainAxisExtent: 400,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => businessCard(),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
    );
  }

  /// Shimmer para o mapa (placeholder de mapa carregando)
  static Widget mapPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Simula o AppBar
            Container(
              height: 56,
              color: Colors.white,
            ),
            // Simula um card de informações
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                height: 40,
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Simula o mapa
            const Expanded(
              child: ColoredBox(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer inline simples para listas
  static Widget inline({double height = 20, double width = double.infinity}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
