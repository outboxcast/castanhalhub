import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseClient? _client;

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
      const supabaseUrl = String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://xhnrlrvplvtrkzinivxx.supabase.co',
      );
      const supabaseAnonKey = String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhobnJscnZwbHZ0cmt6aW5pdnh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMzODE0MDAsImV4cCI6MjA5ODk1NzQwMH0.WHg7GnAAenC1o4MqLuqKCCJ87QXHDPWssRDC0OokME8',
      );

      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          autoRefreshToken: true,
          detectSessionInUri: true,
        ),
      );
      _client = Supabase.instance.client;
      return _client!;
    }
  }

  Future<List<Map<String, dynamic>>> fetchFeed({String? category, String? searchQuery}) async {
    try {
      final client = await _ensureClient();
      var query = client.from('get_feed').select();

      if (category != null && category != 'Todos') {
        query = query.eq('category_name', category);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('business_name', '%$searchQuery%');
      }

      final response = await query.order('is_premium', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Erro ao buscar feed: $e');
      return [];
    }
  }

  Future<void> logClick(int businessId, String platform) async {
    try {
      final client = await _ensureClient();
      await client.from('analytics_clicks').insert({
        'business_id': businessId,
        'platform': platform,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Erro silencioso no analytics: $e');
    }
  }
}