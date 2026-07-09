import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class BusinessProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Map<String, dynamic>> _businesses = [];
  int _totalBusinesses = 0;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<Map<String, dynamic>> get businesses => _businesses;
  int get totalBusinesses => _totalBusinesses;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int get totalPages => (_totalBusinesses / _pageSize).ceil();

  /// Carrega as lojas com paginação e filtros
  Future<void> loadBusinesses({int page = 1, String? searchQuery}) async {
    _isLoading = true;
    _error = null;
    _currentPage = page;
    if (searchQuery != null) _searchQuery = searchQuery;
    notifyListeners();

    try {
      final offset = (page - 1) * _pageSize;

      // Busca as lojas
      _businesses = await _supabaseService.getBusinesses(
        limit: _pageSize,
        offset: offset,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      // Busca o total de lojas
      _totalBusinesses = await _supabaseService.getBusinessesCount(
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Busca as lojas (com debounce)
  Future<void> searchBusinesses(String query) async {
    _searchQuery = query;
    await loadBusinesses(page: 1, searchQuery: query);
  }

  /// Limpa a busca
  Future<void> clearSearch() async {
    _searchQuery = '';
    await loadBusinesses(page: 1);
  }

  /// Cria uma nova loja
  Future<bool> createBusiness({
    required String name,
    required String categoryId,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? whatsappNumber,
    String? instagramUrl,
    String? imageUrl,
    bool isPremium = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.createBusiness(
        name: name,
        categoryId: categoryId,
        description: description,
        address: address,
        latitude: latitude,
        longitude: longitude,
        whatsappNumber: whatsappNumber,
        instagramUrl: instagramUrl,
        imageUrl: imageUrl,
        isPremium: isPremium,
      );

      await loadBusinesses(page: 1);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Atualiza uma loja
  Future<bool> updateBusiness({
    required String id,
    String? name,
    String? categoryId,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? whatsappNumber,
    String? instagramUrl,
    String? imageUrl,
    bool? isPremium,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.updateBusiness(
        id: id,
        name: name,
        categoryId: categoryId,
        description: description,
        address: address,
        latitude: latitude,
        longitude: longitude,
        whatsappNumber: whatsappNumber,
        instagramUrl: instagramUrl,
        imageUrl: imageUrl,
        isPremium: isPremium,
      );

      await loadBusinesses(page: _currentPage);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Deleta uma loja
  Future<bool> deleteBusiness(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.deleteBusiness(id);
      await loadBusinesses(page: _currentPage);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Alterna o status premium de uma loja
  Future<bool> togglePremiumStatus({
    required String id,
    required bool currentStatus,
  }) async {
    try {
      await _supabaseService.updateBusiness(id: id, isPremium: !currentStatus);

      // Atualiza localmente
      final index = _businesses.indexWhere((b) => b['id'] == id);
      if (index != -1) {
        _businesses[index]['is_premium'] = !currentStatus;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Limpa o erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
