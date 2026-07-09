import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _initializeAuth();
  }

  /// Inicializa a autenticação verificando se há usuário logado
  void _initializeAuth() {
    _currentUser = _supabaseService.getCurrentUser();
    _isAuthenticated = _currentUser != null;
    notifyListeners();

    // Escuta as mudanças de estado de autenticação
    _supabaseService.authStateChanges.listen((data) {
      _currentUser = data.session?.user;
      _isAuthenticated = _currentUser != null;
      _error = null;
      notifyListeners();
    });
  }

  /// Faz login com email e senha
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signInWithPassword(
        email: email,
        password: password,
      );

      _currentUser = response.user;
      _isAuthenticated = true;
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

  /// Faz logout
  Future<bool> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.signOut();
      _currentUser = null;
      _isAuthenticated = false;
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

  /// Limpa o erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
