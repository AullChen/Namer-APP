import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:english_words/english_words.dart';

/// 智能命名服务 - 本地规则算法实现
class IntelligentNamingService {
  final Random _random = Random();
  final Map<String, Map<String, dynamic>> _resourceCache = {};

  // 内置的默认备用词库，确保服务的健壮性
  static final Map<String, Map<String, List<String>>> _defaultResources = {
    'tech': {
      'prefix': ['智能', '数字', '科技', '创新', '网络', '云端', '数据', '代码', '未来', '极客'],
      'suffix': ['系统', '平台', '中心', '工作室', '科技', '实验室', '引擎', '核心', '网络', '云'],
    },
    'creative': {
      'prefix': ['创意', '艺术', '设计', '视觉', '灵感', '梦想', '魔法', '火花', '光影', '色彩'],
      'suffix': ['工作室', '设计', '创意', '艺术', '视觉', '媒体', '影像', '空间', '美学', '创作'],
    },
    'business': {
      'prefix': ['专业', '精英', '成功', '全球', '战略', '优质', '卓越', '领先', '顶级', '王牌'],
      'suffix': ['企业', '集团', '公司', '合作', '投资', '控股', '资本', '商务', '贸易', '联盟'],
    },
    'nature': {
      'prefix': ['绿色', '生态', '自然', '环保', '清新', '森林', '海洋', '天空', '阳光', '月光'],
      'suffix': ['自然', '生态', '环保', '绿色', '清新', '森林', '海洋', '天空', '阳光', '月光'],
    },
  };

  /// 按需加载类别词库
  Future<Map<String, dynamic>> _loadCategoryResources(String category, String locale) async {
    final cacheKey = '$locale/$category';
    if (_resourceCache.containsKey(cacheKey)) {
      return _resourceCache[cacheKey]!;
    }

    try {
      final path = 'assets/locales/$locale/$category.json';
      final jsonString = await rootBundle.loadString(path);
      final resources = json.decode(jsonString) as Map<String, dynamic>;
      _resourceCache[cacheKey] = resources;
      return resources;
    } catch (e) {
      print("加载类别 '$category' 词库失败 ($locale): $e. 将使用内置备用词库。");
      return {};
    }
  }

  /// 核心智能命名函数
  Future<List<String>> generateNames({
    required String prompt,
    String locale = 'zh',
    int count = 5,
    bool useAI = true,
  }) async {
    return await _generateWithLocalRules(prompt, locale, count);
  }

  /// 使用本地规则算法生成名称
  Future<List<String>> _generateWithLocalRules(String prompt, String locale, int count) async {
    String category = _classifyPrompt(prompt, locale);
    var resources = await _loadCategoryResources(category, locale);

    if (resources.isEmpty) {
      resources = _defaultResources[category] ?? {};
    }

    final prefixes = List<String>.from(resources['prefix'] ?? []);
    final suffixes = List<String>.from(resources['suffix'] ?? []);

    if (prefixes.isEmpty || suffixes.isEmpty) {
      return List.generate(count, (_) => WordPair.random().asPascalCase);
    }

    final uniqueNames = <String>{};
    prefixes.shuffle(_random);
    suffixes.shuffle(_random);

    for (int i = 0; i < prefixes.length && uniqueNames.length < count; i++) {
      for (int j = 0; j < suffixes.length && uniqueNames.length < count; j++) {
        final name = _combineName(prefixes[i], suffixes[j], locale);
        uniqueNames.add(name);
      }
    }

    while (uniqueNames.length < count) {
      final prefix = prefixes[_random.nextInt(prefixes.length)];
      final suffix = suffixes[_random.nextInt(suffixes.length)];
      uniqueNames.add(_combineName(prefix, suffix, locale));
    }
    
    return uniqueNames.take(count).toList();
  }

  /// 分析提示词类别
  String _classifyPrompt(String prompt, String locale) {
    String lowerPrompt = prompt.toLowerCase();
    
    if (locale == 'zh') {
      if (lowerPrompt.contains('科技') || lowerPrompt.contains('智能')) return 'tech';
      if (lowerPrompt.contains('创意') || lowerPrompt.contains('设计')) return 'creative';
      if (lowerPrompt.contains('商业') || lowerPrompt.contains('公司')) return 'business';
      if (lowerPrompt.contains('自然') || lowerPrompt.contains('绿色')) return 'nature';
    } else {
      if (lowerPrompt.contains('tech') || lowerPrompt.contains('smart')) return 'tech';
      if (lowerPrompt.contains('creative') || lowerPrompt.contains('design')) return 'creative';
      if (lowerPrompt.contains('business') || lowerPrompt.contains('company')) return 'business';
      if (lowerPrompt.contains('nature') || lowerPrompt.contains('green')) return 'nature';
    }
    
    return 'tech';
  }

  /// 组合名称
  String _combineName(String prefix, String suffix, String locale) {
    if (locale == 'zh') {
      return (prefix == suffix) ? prefix : prefix + suffix;
    } else {
      return (prefix.toLowerCase() == suffix.toLowerCase()) ? prefix : '$prefix $suffix';
    }
  }

  /// 生成WordPair列表（兼容现有接口）
  Future<List<WordPair>> generateWordPairs({
    required String prompt,
    String locale = 'zh',
    int count = 5,
    bool useAI = true,
  }) async {
    List<String> names = await generateNames(
      prompt: prompt,
      locale: locale,
      count: count,
      useAI: useAI,
    );
    
    return names.map((name) {
      if (locale == 'zh') {
        if (name.length >= 4) {
          int mid = name.length ~/ 2;
          return WordPair(name.substring(0, mid), name.substring(mid));
        } else {
          return WordPair(name, '科技');
        }
      } else {
        List<String> parts = name.split(RegExp(r'[\s\-_]+'));
        if (parts.length >= 2) {
          return WordPair(parts[0], parts.sublist(1).join(''));
        } else {
          return WordPair(name, 'Plus');
        }
      }
    }).toList();
  }

  /// 智能评分系统 - 根据提示词对生成的名称进行评分
  int scoreNameForPrompt(String name, String prompt, String locale) {
    int score = 0;
    String lowerName = name.toLowerCase();
    String lowerPrompt = prompt.toLowerCase();
    
    if (lowerName.contains(lowerPrompt)) {
      score += 20;
    }
    
    List<String> promptWords = lowerPrompt.split(RegExp(r'\s+'));
    for (String word in promptWords) {
      if (word.length > 1 && lowerName.contains(word)) {
        score += 10;
      }
    }
    
    if (name.length >= 4 && name.length <= 12) {
      score += 5;
    }
    
    return score;
  }
}
