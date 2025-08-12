import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/word_pair_model.dart';
import 'package:flutter_application_1/models/category_model.dart';

class StorageService {
  static const String _favoritesKey = 'favorites';
  static const String _categoriesKey = 'categories';
  static const String _preferencesKey = 'preferences';

  // 保存收藏的单词对
  Future<bool> saveFavorites(List<WordPairModel> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = favorites.map((pair) => jsonEncode(pair.toJson())).toList();
    return await prefs.setStringList(_favoritesKey, jsonList);
  }

  // 加载收藏的单词对
  Future<List<WordPairModel>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_favoritesKey) ?? [];
    
    return jsonList
        .map((jsonString) => WordPairModel.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  // 保存分类
  Future<bool> saveCategories(List<CategoryModel> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = categories.map((category) => jsonEncode(category.toJson())).toList();
    return await prefs.setStringList(_categoriesKey, jsonList);
  }

  // 加载分类
  Future<List<CategoryModel>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_categoriesKey) ?? [];
    
    if (jsonList.isEmpty) {
      // 创建默认分类
      final defaultCategories = [
        CategoryModel(name: '未分类'),
        CategoryModel(name: '产品名称', color: 'blue'),
        CategoryModel(name: '项目代号', color: 'green'),
        CategoryModel(name: '角色名称', color: 'purple'),
      ];
      await saveCategories(defaultCategories);
      return defaultCategories;
    }
    
    return jsonList
        .map((jsonString) => CategoryModel.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  // 保存用户偏好设置
  Future<bool> savePreferences(Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_preferencesKey, jsonEncode(preferences));
  }

  // 加载用户偏好设置
  Future<Map<String, dynamic>> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_preferencesKey);
    
    if (jsonString == null) {
      // 默认偏好设置
      final defaultPreferences = {
        'nameLength': 'medium', // short, medium, long
        'nameStyle': 'modern', // classic, modern, futuristic
        'darkMode': false,
      };
      await savePreferences(defaultPreferences);
      return defaultPreferences;
    }
    
    return jsonDecode(jsonString);
  }

  // 添加单个收藏
  Future<bool> addFavorite(WordPairModel wordPair) async {
    final favorites = await loadFavorites();
    if (!favorites.contains(wordPair)) {
      favorites.add(wordPair);
      return await saveFavorites(favorites);
    }
    return true;
  }

  // 删除单个收藏
  Future<bool> removeFavorite(WordPairModel wordPair) async {
    final favorites = await loadFavorites();
    favorites.removeWhere((item) => item.id == wordPair.id);
    return await saveFavorites(favorites);
  }

  // 更新单个收藏
  Future<bool> updateFavorite(WordPairModel wordPair) async {
    final favorites = await loadFavorites();
    final index = favorites.indexWhere((item) => item.id == wordPair.id);
    if (index != -1) {
      favorites[index] = wordPair;
      return await saveFavorites(favorites);
    }
    return false;
  }
}