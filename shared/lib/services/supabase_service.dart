import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business.dart';

class SupabaseService {
  SupabaseClient? _client;

  /// Indica se o Supabase foi inicializado
  bool get isInitialized => _client != null;

  Future<SupabaseClient> _ensureClient() async {
    if (_client != null) {
      return _client!;
    }

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      throw StateError('Supabase disabled in test environment');
    }

    try {
      _client = Supabase.instance.client;
      return _client!;
    } on AssertionError {
      const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
      const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

      if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
        await Supabase.initialize(
          url: supabaseUrl,
          publishableKey: supabaseAnonKey,
          authOptions: const FlutterAuthClientOptions(
            autoRefreshToken: true,
            detectSessionInUri: true,
          ),
        );
      }
      _client = Supabase.instance.client;
      return _client!;
    }
  }

  // ==================== AUTENTICAÇÃO ====================

  /// Obtém o usuário atual logado
  User? getCurrentUser() {
    if (_client == null) return null;
    return _client!.auth.currentUser;
  }

  /// Stream de mudanças no estado de autenticação
  Stream<AuthState> get authStateChanges {
    // Se não inicializado, retorna stream vazia para evitar erros
    if (_client == null) {
      return const Stream.empty();
    }
    return _client!.auth.onAuthStateChange;
  }

  /// Login com email e senha
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final client = await _ensureClient();
    return client.auth.signInWithPassword(email: email, password: password);
  }

  /// Cadastro com email e senha
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final client = await _ensureClient();
    return client.auth.signUp(email: email, password: password);
  }

  /// Login com Google (OAuth) — abre navegador do sistema
  /// ✅ Compatível com Android e iOS
  Future<bool> signInWithGoogle() async {
    final client = await _ensureClient();
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      authScreenLaunchMode: LaunchMode.platformDefault,
    );
    return true;
  }

  /// Login com Apple (OAuth) — abre navegador do sistema
  /// ✅ Compatível com Android e iOS
  /// ⚠️ No iOS requer "Sign in with Apple" capability no Xcode
  Future<bool> signInWithApple() async {
    final client = await _ensureClient();
    await client.auth.signInWithOAuth(
      OAuthProvider.apple,
      authScreenLaunchMode: LaunchMode.platformDefault,
    );
    return true;
  }

  /// Envia email de recuperação de senha
  Future<void> sendPasswordResetEmail({required String email}) async {
    final client = await _ensureClient();
    await client.auth.resetPasswordForEmail(email);
  }

  /// Faz logout
  Future<void> signOut() async {
    final client = await _ensureClient();
    await client.auth.signOut();
  }

  Future<List<Business>> fetchFeed({String? category, String? searchQuery}) async {
    try {
      final client = await _ensureClient();
      var query = client.from('get_feed').select();

      if (category != null && category != 'Todos') {
        query = query.eq('category_name', category);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }

      final response = await query.order('is_premium', ascending: false);
      final list = List<Map<String, dynamic>>.from(response);
      return list.map((e) => Business.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar feed: $e');
      rethrow;
    }
  }

  /// Busca categorias distintas disponíveis no banco
  Future<List<String>> fetchCategories() async {
    try {
      final client = await _ensureClient();
      final response = await client.from('get_feed').select('category_name');
      final categories = <String>{'Todos'};
      for (final row in List<Map<String, dynamic>>.from(response)) {
        final cat = row['category_name'] as String?;
        if (cat != null && cat.isNotEmpty) {
          categories.add(cat);
        }
      }
      return categories.toList()..sort();
    } catch (e) {
      debugPrint('Erro ao buscar categorias: $e');
      return ['Todos', 'Alimentação', 'Saúde', 'Serviços', 'Varejo'];
    }
  }

  /// Busca um negócio pelo ID
  Future<Business?> fetchBusinessById(String id) async {
    try {
      final client = await _ensureClient();
      final response = await client
          .from('get_feed')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) return null;
      return Business.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      debugPrint('Erro ao buscar negócio: $e');
      return null;
    }
  }

  Future<void> logClick(String businessId, String clickType) async {
    try {
      final client = await _ensureClient();
      await client.from('analytics_clicks').insert({
        'business_id': businessId,
        'click_type': clickType,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Erro silencioso no analytics: $e');
    }
  }

  /// ========== MÉTODOS ADMIN ==========

  /// Lista todos os negócios (para o admin)
  Future<List<Business>> fetchAllBusinesses() async {
    try {
      final client = await _ensureClient();
      final response = await client.from('get_feed').select('*').order('is_premium', ascending: false);
      final list = List<Map<String, dynamic>>.from(response);
      return list.map((e) => Business.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar todos os negócios: $e');
      rethrow;
    }
  }

  /// Cria um novo negócio
  Future<void> createBusiness(Map<String, dynamic> data) async {
    try {
      final client = await _ensureClient();
      data['created_at'] = DateTime.now().toIso8601String();
      await client.from('businesses').insert(data);
    } catch (e) {
      debugPrint('Erro ao criar negócio: $e');
      rethrow;
    }
  }

  /// Atualiza um negócio existente
  Future<void> updateBusiness(int id, Map<String, dynamic> data) async {
    try {
      final client = await _ensureClient();
      data['updated_at'] = DateTime.now().toIso8601String();
      await client.from('businesses').update(data).eq('id', id);
    } catch (e) {
      debugPrint('Erro ao atualizar negócio: $e');
      rethrow;
    }
  }

  /// Deleta um negócio
  Future<void> deleteBusiness(int id) async {
    try {
      final client = await _ensureClient();
      await client.from('businesses').delete().eq('id', id);
    } catch (e) {
      debugPrint('Erro ao deletar negócio: $e');
      rethrow;
    }
  }

  /// Busca estatísticas de cliques
  Future<Map<String, dynamic>> fetchAnalytics() async {
    try {
      final client = await _ensureClient();
      final totalBusinesses = await client.from('businesses').select().count();

      final whatsappCount = await client.from('analytics_clicks')
          .select()
          .eq('click_type', 'whatsapp')
          .count();

      final instagramCount = await client.from('analytics_clicks')
          .select()
          .eq('click_type', 'instagram')
          .count();

      return {
        'whatsapp_clicks': whatsappCount,
        'instagram_clicks': instagramCount,
        'total_businesses': totalBusinesses,
      };
    } catch (e) {
      debugPrint('Erro ao buscar analytics: $e');
      return {'whatsapp_clicks': 0, 'instagram_clicks': 0, 'total_businesses': 0};
    }
  }
}
