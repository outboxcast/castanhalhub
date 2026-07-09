import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  late SupabaseClient _client;

  SupabaseClient get client => _client;

  /// Inicializa o serviço do Supabase
  /// Variáveis de ambiente: SUPABASE_URL e SUPABASE_ANON_KEY
  Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
    _client = Supabase.instance.client;
  }

  // ==================== AUTENTICAÇÃO ====================

  /// Faz login com email e senha
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  /// Faz logout
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  /// Obtém o usuário atual
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// Stream de autenticação
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ==================== NEGÓCIOS/LOJAS ====================

  /// Obtém todas as lojas com paginação
  Future<List<Map<String, dynamic>>> getBusinesses({
    int limit = 10,
    int offset = 0,
    String? searchQuery,
  }) async {
    try {
      var query = _client.from('businesses').select('*');

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response;
    } catch (e) {
      throw Exception('Erro ao buscar lojas: $e');
    }
  }

  /// Obtém o total de lojas
  Future<int> getBusinessesCount({String? searchQuery}) async {
    try {
      var query = _client.from('businesses').select('id');

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }

      final result = await query;
      return (result as List).length;
    } catch (e) {
      throw Exception('Erro ao contar lojas: $e');
    }
  }

  /// Obtém uma loja por ID
  Future<Map<String, dynamic>?> getBusinessById(String id) async {
    try {
      final response = await _client
          .from('businesses')
          .select('*')
          .eq('id', id)
          .single();
      return response;
    } catch (e) {
      throw Exception('Erro ao buscar loja: $e');
    }
  }

  /// Cria uma nova loja
  Future<Map<String, dynamic>> createBusiness({
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
    try {
      final response = await _client
          .from('businesses')
          .insert({
            'name': name,
            'category_id': categoryId,
            'description': description,
            'address': address,
            'latitude': latitude,
            'longitude': longitude,
            'whatsapp_number': whatsappNumber,
            'instagram_url': instagramUrl,
            'image_url': imageUrl,
            'is_premium': isPremium,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Erro ao criar loja: $e');
    }
  }

  /// Atualiza uma loja
  Future<Map<String, dynamic>> updateBusiness({
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
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (categoryId != null) updateData['category_id'] = categoryId;
      if (description != null) updateData['description'] = description;
      if (address != null) updateData['address'] = address;
      if (latitude != null) updateData['latitude'] = latitude;
      if (longitude != null) updateData['longitude'] = longitude;
      if (whatsappNumber != null) {
        updateData['whatsapp_number'] = whatsappNumber;
      }
      if (instagramUrl != null) updateData['instagram_url'] = instagramUrl;
      if (imageUrl != null) {
        updateData['image_url'] = imageUrl;
      }
      if (isPremium != null) updateData['is_premium'] = isPremium;

      final response = await _client
          .from('businesses')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Erro ao atualizar loja: $e');
    }
  }

  /// Deleta uma loja
  Future<void> deleteBusiness(String id) async {
    try {
      await _client.from('businesses').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar loja: $e');
    }
  }

  // ==================== CATEGORIAS ====================

  /// Obtém todas as categorias
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select('*')
          .order('name', ascending: true);

      return response;
    } catch (e) {
      throw Exception('Erro ao buscar categorias: $e');
    }
  }

  // ==================== ANALYTICS ====================

  /// Obtém os últimos cliques registrados
  Future<List<Map<String, dynamic>>> getRecentClicks({int limit = 20}) async {
    try {
      final response = await _client
          .from('analytics_clicks')
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);

      return response;
    } catch (e) {
      throw Exception('Erro ao buscar cliques: $e');
    }
  }

  /// Obtém total de empresas
  Future<int> getTotalBusinesses() async {
    try {
      final result = await _client.from('businesses').select('id');
      return (result as List).length;
    } catch (e) {
      throw Exception('Erro ao contar empresas: $e');
    }
  }

  /// Obtém total de empresas premium
  Future<int> getTotalPremiumBusinesses() async {
    try {
      final result = await _client
          .from('businesses')
          .select('id')
          .eq('is_premium', true);
      return (result as List).length;
    } catch (e) {
      throw Exception('Erro ao contar empresas premium: $e');
    }
  }

  /// Obtém total de cliques
  Future<int> getTotalClicks() async {
    try {
      final result = await _client.from('analytics_clicks').select('id');
      return (result as List).length;
    } catch (e) {
      throw Exception('Erro ao contar cliques: $e');
    }
  }

  /// Obtém cliques por tipo
  Future<int> getClicksByType(String type) async {
    try {
      final result = await _client
          .from('analytics_clicks')
          .select('id')
          .eq('click_type', type);
      return (result as List).length;
    } catch (e) {
      throw Exception('Erro ao contar cliques de $type: $e');
    }
  }

  // ==================== STORAGE (IMAGENS) ====================

  /// Bucket usado para imagens dos negócios
  static const String _bucketName = 'business-images';

  /// Faz upload de uma imagem para o Storage e retorna a URL pública
  Future<String> uploadBusinessImage({
    required String fileName,
    required List<int> bytes,
  }) async {
    try {
      final filePath = 'businesses/$fileName';

      await _client.storage
          .from(_bucketName)
          .uploadBinary(filePath, Uint8List.fromList(bytes),
              fileOptions: const FileOptions(upsert: true));

      final publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  /// Deleta uma imagem do Storage
  Future<void> deleteBusinessImage(String filePath) async {
    try {
      await _client.storage.from(_bucketName).remove([filePath]);
    } catch (e) {
      throw Exception('Erro ao deletar imagem: $e');
    }
  }

  /// Extrai o path do arquivo a partir da URL pública
  static String? extractStoragePathFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    // A URL pública tem formato:
    // {SUPABASE_URL}/storage/v1/object/public/business-images/businesses/arquivo.jpg
    final pathSegments = uri.pathSegments;
    final bucketIndex = pathSegments.indexOf(_bucketName);
    if (bucketIndex == -1) return null;

    return pathSegments.sublist(bucketIndex + 1).join('/');
  }
}
