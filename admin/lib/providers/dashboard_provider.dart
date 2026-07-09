import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class DashboardProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  int _totalBusinesses = 0;
  int _premiumBusinesses = 0;
  int _totalWhatsappClicks = 0;
  int _totalInstagramClicks = 0;
  List<Map<String, dynamic>> _recentClicks = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  int get totalBusinesses => _totalBusinesses;
  int get premiumBusinesses => _premiumBusinesses;
  int get totalWhatsappClicks => _totalWhatsappClicks;
  int get totalInstagramClicks => _totalInstagramClicks;
  List<Map<String, dynamic>> get recentClicks => _recentClicks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carrega os dados do dashboard
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadTotalBusinesses(),
        _loadPremiumBusinesses(),
        _loadWhatsappClicks(),
        _loadInstagramClicks(),
        _loadRecentClicks(),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadTotalBusinesses() async {
    try {
      _totalBusinesses = await _supabaseService.getTotalBusinesses();
    } catch (e) {
      throw Exception('Erro ao carregar total de empresas: $e');
    }
  }

  Future<void> _loadPremiumBusinesses() async {
    try {
      _premiumBusinesses = await _supabaseService.getTotalPremiumBusinesses();
    } catch (e) {
      throw Exception('Erro ao carregar empresas premium: $e');
    }
  }

  Future<void> _loadWhatsappClicks() async {
    try {
      _totalWhatsappClicks = await _supabaseService.getClicksByType('whatsapp');
    } catch (e) {
      throw Exception('Erro ao carregar cliques de WhatsApp: $e');
    }
  }

  Future<void> _loadInstagramClicks() async {
    try {
      _totalInstagramClicks = await _supabaseService.getClicksByType(
        'instagram',
      );
    } catch (e) {
      throw Exception('Erro ao carregar cliques de Instagram: $e');
    }
  }

  Future<void> _loadRecentClicks() async {
    try {
      _recentClicks = await _supabaseService.getRecentClicks(limit: 20);
    } catch (e) {
      throw Exception('Erro ao carregar cliques recentes: $e');
    }
  }

  /// Limpa o erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
