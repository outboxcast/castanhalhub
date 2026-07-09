import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared/services/supabase_service.dart';

/// Provider de autenticação para o app Castanhal Hub.
///
/// ✅ Suporta: Email/Senha, Google OAuth, Apple OAuth
/// ✅ Compatível com Android e iOS
/// ⚠️ Apple Sign-In requer configuração adicional no Xcode (capability)
class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  User? _currentUser;
  bool _isLoading = false;
  bool _initializing = true;
  String? _error;
  bool _isAuthenticated = false;
  bool _isGuest = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get initializing => _initializing;
  String? get error => _error;

  /// TRUE se o usuário está logado (email, Google ou Apple)
  bool get isAuthenticated => _isAuthenticated;

  /// TRUE se o usuário optou por usar sem login (convidado)
  bool get isGuest => _isGuest;

  /// FALSE para convidados — indica se pode acessar funções restritas
  /// (favoritos, cupons, push, cadastro de loja, contato com app, avaliações)
  bool get isFullyAuthenticated => _isAuthenticated && !_isGuest;

  AuthProvider() {
    _initializeAuth();
  }

  /// Inicializa verificando sessão existente e escutando mudanças
  void _initializeAuth() {
    _currentUser = _supabaseService.getCurrentUser();
    _isAuthenticated = _currentUser != null;
    _initializing = false;
    notifyListeners();

    // Escuta mudanças de autenticação em tempo real
    try {
      _supabaseService.authStateChanges.listen((data) {
        _currentUser = data.session?.user;
        _isAuthenticated = _currentUser != null;
        if (_isAuthenticated) {
          _isGuest = false; // se logou de verdade, não é mais guest
        }
        _error = null;
        _initializing = false;
        notifyListeners();
      });
    } catch (_) {
      // Auth não configurado — segue sem autenticação
      _initializing = false;
      notifyListeners();
    }
  }

  /// Ativa o modo convidado — acesso limitado ao app sem login
  void setGuestMode() {
    _isGuest = true;
    _isAuthenticated = true;
    _error = null;
    _initializing = false;
    notifyListeners();
  }

  /// Login com email e senha
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.signInWithPassword(
        email: email,
        password: password,
      );
      // O listener do authStateChanges atualizará o estado
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cadastro com email e senha
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.signUp(
        email: email,
        password: password,
      );
      _isLoading = false;
      _error =
          'Cadastro realizado! Verifique seu email para confirmar a conta.';
      notifyListeners();
      return false; // não loga automaticamente — precisa confirmar email
    } catch (e) {
      _error = _formatAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login com Google (OAuth)
  ///
  /// ✅ Android: abre Chrome Custom Tab
  /// ✅ iOS: abre SafariViewController
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login com Apple (OAuth)
  ///
  /// ✅ Android: abre navegador
  /// ✅ iOS: abre SafariViewController
  /// ⚠️ Requer "Sign in with Apple" capability habilitada no Xcode
  Future<bool> loginWithApple() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.signInWithApple();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout — sai da conta ou sai do modo convidado
  Future<bool> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_isGuest) {
        await _supabaseService.signOut();
      }
      _currentUser = null;
      _isAuthenticated = false;
      _isGuest = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Limpa mensagens de erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Formata erros de autenticação para mensagens amigáveis
  String _formatAuthError(dynamic error) {
    final message = error.toString();

    if (message.contains('Invalid login credentials')) {
      return 'Email ou senha inválidos.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Email não confirmado. Verifique sua caixa de entrada.';
    }
    if (message.contains('User already registered')) {
      return 'Este email já está cadastrado.';
    }
    if (message.contains('Password should be at least')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    if (message.contains('rate_limit')) {
      return 'Muitas tentativas. Aguarde alguns minutos.';
    }

    return 'Erro ao autenticar. Tente novamente.';
  }
}
