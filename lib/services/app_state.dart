import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter_application_1/models/word_pair_model.dart';
import 'package:flutter_application_1/utils/name_formatter.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:flutter_application_1/services/name_generator_service.dart';
import 'package:flutter_application_1/services/intelligent_naming_service.dart';

// 存储服务提供者
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// 名称生成服务提供者
final nameGeneratorServiceProvider = Provider<NameGeneratorService>((ref) {
  return NameGeneratorService();
});

// 智能命名服务提供者
final intelligentNamingServiceProvider = Provider<IntelligentNamingService>((ref) {
  return IntelligentNamingService();
});

// 当前单词对提供者
final currentWordPairProvider = StateNotifierProvider<CurrentWordPairNotifier, WordPairModel>((ref) {
  final nameGenerator = ref.watch(nameGeneratorServiceProvider);
  final initialPair = nameGenerator.generateRandomPair();
  return CurrentWordPairNotifier(WordPairModel(wordPair: initialPair), ref);
});

// 收藏列表提供者
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<WordPairModel>>((ref) {
  return FavoritesNotifier(ref);
});

// 分类列表提供者
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<CategoryModel>>((ref) {
  return CategoriesNotifier(ref);
});

// 用户偏好提供者
final preferencesProvider = StateNotifierProvider<PreferencesNotifier, Map<String, dynamic>>((ref) {
  return PreferencesNotifier(ref);
});

// 候选名称列表提供者
final candidatesProvider = StateNotifierProvider<CandidatesNotifier, List<WordPairModel>>((ref) {
  return CandidatesNotifier(ref);
});

// 搜索关键词提供者
final searchKeywordProvider = StateProvider<String>((ref) => '');

// 当前选中分类提供者
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// 当前单词对状态管理
class CurrentWordPairNotifier extends StateNotifier<WordPairModel> {
  final Ref _ref;

  CurrentWordPairNotifier(WordPairModel initialState, this._ref) : super(initialState);

  Future<void> getNext() async {
    final keyword = _ref.read(searchKeywordProvider);
    
    print('🔄 CurrentWordPairNotifier.getNext() 被调用');
    print('🔑 当前关键词: "$keyword"');
    
    try {
      // 使用传统方法生成，避免WordPair构造函数问题
      _generateTraditionalPair();
    } catch (e) {
      print('❌ getNext() 异常: $e');
      // 创建一个简单的随机WordPair作为回退
      final newPair = WordPair.random();
      state = WordPairModel(wordPair: newPair);
    }
  }

  // 新增：直接更新名称的方法（修复：将传入的名称映射到 WordPair 而非随机）
  void updateWithName(String name) {
    print('🔄 直接更新名称: $name');

    final newPair = NameFormatter.toWordPair(name);
    state = WordPairModel(wordPair: newPair);

    // 不要用生成结果污染搜索关键词
    // _ref.read(searchKeywordProvider.notifier).state = name;

    print('✅ 状态已更新，名称: $name -> (${newPair.first}, ${newPair.second})');
  }

  void _generateTraditionalPair() {
    final nameGenerator = _ref.read(nameGeneratorServiceProvider);
    final preferences = _ref.read(preferencesProvider);
    final keyword = _ref.read(searchKeywordProvider);
    
    WordPair newPair;
    if (keyword.isNotEmpty) {
      newPair = nameGenerator.generateBasedOnKeyword(keyword);
    } else {
      newPair = nameGenerator.generateBasedOnPreferences(preferences);
    }
    
    state = WordPairModel(wordPair: newPair);
  }

  void toggleFavorite() {
    final favorites = _ref.read(favoritesProvider.notifier);
    favorites.toggleFavorite(state);
  }

  void updateCategories(List<String> categories) {
    state = state.copyWith(categories: categories);
    
    // 如果当前单词对在收藏列表中，更新它
    final favorites = _ref.read(favoritesProvider);
    final index = favorites.indexWhere((item) => item.id == state.id);
    if (index != -1) {
      _ref.read(favoritesProvider.notifier).updateFavorite(state);
    }
  }
}

// 收藏列表状态管理
class FavoritesNotifier extends StateNotifier<List<WordPairModel>> {
  final Ref _ref;
  bool _isLoading = false;

  FavoritesNotifier(this._ref) : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (_isLoading) return;
    _isLoading = true;
    
    final storageService = _ref.read(storageServiceProvider);
    final favorites = await storageService.loadFavorites();
    state = favorites;
    
    _isLoading = false;
  }

  Future<void> toggleFavorite(WordPairModel wordPair) async {
    final storageService = _ref.read(storageServiceProvider);
    
    if (state.any((item) => item.id == wordPair.id)) {
      // 如果已经在收藏列表中，则移除
      state = state.where((item) => item.id != wordPair.id).toList();
      await storageService.removeFavorite(wordPair);
    } else {
      // 否则添加到收藏列表
      state = [...state, wordPair];
      await storageService.addFavorite(wordPair);
    }
  }

  Future<void> updateFavorite(WordPairModel wordPair) async {
    final storageService = _ref.read(storageServiceProvider);
    
    final index = state.indexWhere((item) => item.id == wordPair.id);
    if (index != -1) {
      final newList = List<WordPairModel>.from(state);
      newList[index] = wordPair;
      state = newList;
      await storageService.updateFavorite(wordPair);
    }
  }

  Future<void> removeFavorite(String id) async {
    final storageService = _ref.read(storageServiceProvider);
    final wordPair = state.firstWhere((item) => item.id == id);
    
    state = state.where((item) => item.id != id).toList();
    await storageService.removeFavorite(wordPair);
  }

  List<WordPairModel> getFavoritesByCategory(String categoryId) {
    return state.where((item) => item.categories.contains(categoryId)).toList();
  }

  Future<void> clear() async {
    final storageService = _ref.read(storageServiceProvider);
    state = [];
    await storageService.clearFavorites();
  }
}

// 分类列表状态管理
class CategoriesNotifier extends StateNotifier<List<CategoryModel>> {
  final Ref _ref;
  bool _isLoading = false;

  CategoriesNotifier(this._ref) : super([]) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    if (_isLoading) return;
    _isLoading = true;
    
    final storageService = _ref.read(storageServiceProvider);
    final categories = await storageService.loadCategories();
    state = categories;
    
    _isLoading = false;
  }

  Future<void> addCategory(CategoryModel category) async {
    final storageService = _ref.read(storageServiceProvider);
    
    state = [...state, category];
    await storageService.saveCategories(state);
  }

  Future<void> updateCategory(CategoryModel category) async {
    final storageService = _ref.read(storageServiceProvider);
    
    final index = state.indexWhere((item) => item.id == category.id);
    if (index != -1) {
      final newList = List<CategoryModel>.from(state);
      newList[index] = category;
      state = newList;
      await storageService.saveCategories(state);
    }
  }

  Future<void> removeCategory(String id) async {
    final storageService = _ref.read(storageServiceProvider);
    
    // 不允许删除"未分类"分类
    if (state.firstWhere((item) => item.id == id).name == '未分类') {
      return;
    }
    
    state = state.where((item) => item.id != id).toList();
    await storageService.saveCategories(state);
    
    // 更新收藏列表中的分类
    final favorites = _ref.read(favoritesProvider);
    for (var favorite in favorites) {
      if (favorite.categories.contains(id)) {
        final newCategories = List<String>.from(favorite.categories);
        newCategories.remove(id);
        if (newCategories.isEmpty) {
          newCategories.add(state.first.id); // 添加到"未分类"
        }
        
        final updatedFavorite = favorite.copyWith(categories: newCategories);
        _ref.read(favoritesProvider.notifier).updateFavorite(updatedFavorite);
      }
    }
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return state.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}

// 用户偏好状态管理
class PreferencesNotifier extends StateNotifier<Map<String, dynamic>> {
  final Ref _ref;
  bool _isLoading = false;

  PreferencesNotifier(this._ref) : super({}) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    if (_isLoading) return;
    _isLoading = true;
    
    final storageService = _ref.read(storageServiceProvider);
    final preferences = await storageService.loadPreferences();
    state = preferences;
    
    _isLoading = false;
  }

  Future<void> updatePreference(String key, dynamic value) async {
    final storageService = _ref.read(storageServiceProvider);
    
    state = {...state, key: value};
    await storageService.savePreferences(state);
  }
}

// 候选名称列表状态管理
class CandidatesNotifier extends StateNotifier<List<WordPairModel>> {
  final Ref _ref;

  CandidatesNotifier(this._ref) : super([]) {
    generateCandidates();
  }

  // 新增：直接使用生成的字符串列表更新候选项
  void updateCandidates(List<String> names) {
    state = names.map((name) => WordPairModel(wordPair: NameFormatter.toWordPair(name))).toList();
    print('✅ 候选列表已更新，包含 ${state.length} 个名称');
  }

  Future<void> generateCandidates({int count = 5}) async {
    final intelligentService = _ref.read(intelligentNamingServiceProvider);
    final keyword = _ref.read(searchKeywordProvider);
    
    try {
      // 优先使用智能命名服务
      final wordPairs = await intelligentService.generateWordPairs(
        prompt: keyword.isNotEmpty ? keyword : '智能名称生成',
        count: count,
        useAI: true,
      );
      
      state = wordPairs.map((pair) => WordPairModel(wordPair: pair)).toList();
    } catch (e) {
      // 错误处理：使用传统生成方法
      final nameGenerator = _ref.read(nameGeneratorServiceProvider);
      final preferences = _ref.read(preferencesProvider);
      final wordPairs = <WordPair>[];
      
      for (int i = 0; i < count; i++) {
        if (keyword.isNotEmpty) {
          wordPairs.add(nameGenerator.generateBasedOnKeyword(keyword));
        } else {
          wordPairs.add(nameGenerator.generateBasedOnPreferences(preferences));
        }
      }
      state = wordPairs.map((pair) => WordPairModel(wordPair: pair)).toList();
    }
  }

  void selectCandidate(int index) {
    if (index >= 0 && index < state.length) {
      _ref.read(currentWordPairProvider.notifier).state = state[index];
    }
  }
}
