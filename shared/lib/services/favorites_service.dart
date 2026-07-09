import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorite_ids';

  Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    final list = jsonDecode(raw) as List;
    return list.map((e) => e.toString()).toSet();
  }

  Future<void> toggleFavorite(String businessId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (favorites.contains(businessId)) {
      favorites.remove(businessId);
    } else {
      favorites.add(businessId);
    }
    await prefs.setString(_key, jsonEncode(favorites.toList()));
  }

  Future<bool> isFavorite(String businessId) async {
    final favorites = await getFavorites();
    return favorites.contains(businessId);
  }

  Future<int> count() async {
    final favorites = await getFavorites();
    return favorites.length;
  }
}
