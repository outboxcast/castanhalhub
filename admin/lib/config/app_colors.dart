import 'package:flutter/material.dart';

class AppColors {
  // Paleta principal (Material 3 - Desktop Web)
  static const Color backgroundColor = Color(0xFFF8F9FA); // Fundo geral
  static const Color cardBackground = Color(0xFFFFFFFF); // Branco puro
  static const Color primary = Color(0xFF272D54); // Primária
  static const Color accent = Color(0xFF00A1DF); // Destaque/Ações
  static const Color success = Color(0xFF69C456); // Sucesso/Salvar
  static const Color premium = Color(0xFFEFD127); // Premium/Alertas

  // Cores adicionais para melhor contraste e hierarquia
  static const Color darkText = Color(0xFF1F2937); // Texto escuro
  static const Color lightText = Color(0xFF6B7280); // Texto claro/suporte
  static const Color borderColor = Color(0xFFE5E7EB); // Bordas
  static const Color errorRed = Color(0xFFDC2626); // Erro
  static const Color warningOrange = Color(0xFFF97316); // Aviso

  // Cores de hover e interação
  static const Color accentHover = Color(0xFF0082B5); // Destaque hover
  static const Color primaryHover = Color(0xFF1A1F3A); // Primária hover

  // Transparências
  static Color dividerColor = Colors.grey.withValues(alpha: 0.1);
  static Color shadowColor = Colors.black.withValues(alpha: 0.1);
}
