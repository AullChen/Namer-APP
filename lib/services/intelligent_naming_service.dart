import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:english_words/english_words.dart';

/// 智能命名服务 - 本地规则算法实现
class IntelligentNamingService {
  final Random _random = Random();
  Map<String, dynamic> _currentResources = {};
  bool _isInitialized = false;

  /// 初始化服务，加载规则和词库
  Future<void> initialize([String locale = 'zh']) async {
    if (_isInitialized) return;
    
    try {
      await loadResources(locale);
      _isInitialized = true;
    } catch (e) {
      print("初始化智能命名服务失败: $e");
      // 使用默认资源
      _currentResources = _getDefaultResources();
      _isInitialized = true;
    }
  }

  /// 根据当前语言加载对应的词库资源
  Future<void> loadResources(String locale) async {
    try {
      final String resourceString = await rootBundle.loadString('assets/locales/names_$locale.arb');
      _currentResources = json.decode(resourceString);
    } catch (e) {
      print("加载词库资源失败 ($locale): $e");
      _currentResources = _getDefaultResources();
    }
  }

  /// 核心智能命名函数
  /// [prompt] 用户输入的提示词
  /// [locale] 当前语言 (e.g., 'en', 'zh')
  /// [count] 生成名称数量
  /// [useAI] 是否使用AI生成（本地实现，不依赖网络）
  Future<List<String>> generateNames({
    required String prompt,
    String locale = 'zh',
    int count = 5,
    bool useAI = true,
  }) async {
    await initialize(locale);

    // 使用本地智能算法生成
    return await _generateWithLocalRules(prompt, locale, count);
  }

  /// 使用本地规则算法生成名称
  Future<List<String>> _generateWithLocalRules(String prompt, String locale, int count) async {
    List<String> names = [];
    
    // 分析提示词类别
    String category = _classifyPrompt(prompt, locale);
    
    // 获取对应类别的词汇
    List<String> prefixes = _getWordsForCategory(category, 'prefix');
    List<String> suffixes = _getWordsForCategory(category, 'suffix');
    
    // 生成名称
    Set<String> uniqueNames = {};
    int attempts = 0;
    
    while (uniqueNames.length < count && attempts < count * 3) {
      String prefix = prefixes[_random.nextInt(prefixes.length)];
      String suffix = suffixes[_random.nextInt(suffixes.length)];
      
      // 组合名称
      String name = _combineName(prefix, suffix, locale);
      if (name.isNotEmpty && !uniqueNames.contains(name)) {
        uniqueNames.add(name);
      }
      attempts++;
    }
    
    names.addAll(uniqueNames);
    
    // 如果生成的名称不够，使用英文词库补充
    if (names.length < count) {
      while (names.length < count) {
        WordPair pair = WordPair.random();
        String name = _formatWordPair(pair, locale);
        if (!names.contains(name)) {
          names.add(name);
        }
      }
    }
    
    return names.take(count).toList();
  }

  /// 分析提示词类别
  String _classifyPrompt(String prompt, String locale) {
    String lowerPrompt = prompt.toLowerCase();
    
    if (locale == 'zh') {
      if (lowerPrompt.contains('科技') || lowerPrompt.contains('技术') || 
          lowerPrompt.contains('数字') || lowerPrompt.contains('智能') ||
          lowerPrompt.contains('软件') || lowerPrompt.contains('网络') ||
          lowerPrompt.contains('人工智能') || lowerPrompt.contains('AI')) {
        return 'tech';
      } else if (lowerPrompt.contains('创意') || lowerPrompt.contains('设计') || 
                 lowerPrompt.contains('艺术') || lowerPrompt.contains('工作室') ||
                 lowerPrompt.contains('视觉') || lowerPrompt.contains('美术')) {
        return 'creative';
      } else if (lowerPrompt.contains('商业') || lowerPrompt.contains('企业') || 
                 lowerPrompt.contains('公司') || lowerPrompt.contains('贸易') ||
                 lowerPrompt.contains('商务') || lowerPrompt.contains('投资')) {
        return 'business';
      } else if (lowerPrompt.contains('自然') || lowerPrompt.contains('生态') || 
                 lowerPrompt.contains('绿色') || lowerPrompt.contains('环保') ||
                 lowerPrompt.contains('森林') || lowerPrompt.contains('海洋')) {
        return 'nature';
      }
    } else {
      if (lowerPrompt.contains('tech') || lowerPrompt.contains('digital') || 
          lowerPrompt.contains('software') || lowerPrompt.contains('smart') ||
          lowerPrompt.contains('ai') || lowerPrompt.contains('data')) {
        return 'tech';
      } else if (lowerPrompt.contains('creative') || lowerPrompt.contains('design') || 
                 lowerPrompt.contains('art') || lowerPrompt.contains('studio') ||
                 lowerPrompt.contains('visual') || lowerPrompt.contains('media')) {
        return 'creative';
      } else if (lowerPrompt.contains('business') || lowerPrompt.contains('company') || 
                 lowerPrompt.contains('corporate') || lowerPrompt.contains('trade') ||
                 lowerPrompt.contains('commerce') || lowerPrompt.contains('enterprise')) {
        return 'business';
      } else if (lowerPrompt.contains('nature') || lowerPrompt.contains('eco') || 
                 lowerPrompt.contains('green') || lowerPrompt.contains('natural') ||
                 lowerPrompt.contains('forest') || lowerPrompt.contains('ocean')) {
        return 'nature';
      }
    }
    
    // 默认返回科技类别
    return 'tech';
  }

  /// 获取指定类别的词汇
  List<String> _getWordsForCategory(String category, String type) {
    String key = '${type}_$category';
    if (_currentResources.containsKey(key) && _currentResources[key] is List) {
      return List<String>.from(_currentResources[key]);
    }
    
    // 回退到默认词汇
    return _getDefaultWords(category, type);
  }

  /// 组合名称
  String _combineName(String prefix, String suffix, String locale) {
    if (locale == 'zh') {
      // 中文直接连接，避免重复
      if (prefix == suffix) {
        return prefix + _getRandomSuffix(locale);
      }
      return prefix + suffix;
    } else {
      // 英文用空格连接
      if (prefix.toLowerCase() == suffix.toLowerCase()) {
        return '$prefix ${_getRandomSuffix(locale)}';
      }
      return '$prefix $suffix';
    }
  }

  /// 获取随机后缀
  String _getRandomSuffix(String locale) {
    List<String> suffixes = locale == 'zh' 
      ? ['工作室', '科技', '系统', '平台', '中心']
      : ['Studio', 'Tech', 'Systems', 'Platform', 'Hub'];
    return suffixes[_random.nextInt(suffixes.length)];
  }

  /// 格式化WordPair
  String _formatWordPair(WordPair pair, String locale) {
    if (locale == 'zh') {
      // 对于中文环境，使用音译或保持英文
      return '${_capitalizeFirst(pair.first)}${_capitalizeFirst(pair.second)}';
    } else {
      return '${_capitalizeFirst(pair.first)} ${_capitalizeFirst(pair.second)}';
    }
  }

  /// 首字母大写
  String _capitalizeFirst(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  /// 获取默认资源
  Map<String, dynamic> _getDefaultResources() {
    return {
      'prefix_tech': ['智能', '数字', '科技', '创新', '网络', '云端', '数据', '代码', '未来', '极客'],
      'suffix_tech': ['系统', '平台', '中心', '工作室', '科技', '实验室', '引擎', '核心', '网络', '云'],
      'prefix_creative': ['创意', '艺术', '设计', '视觉', '灵感', '梦想', '魔法', '火花', '光影', '色彩'],
      'suffix_creative': ['工作室', '设计', '创意', '艺术', '视觉', '媒体', '影像', '空间', '美学', '创作'],
      'prefix_business': ['专业', '精英', '成功', '全球', '战略', '优质', '卓越', '领先', '顶级', '王牌'],
      'suffix_business': ['企业', '集团', '公司', '合作', '投资', '控股', '资本', '商务', '贸易', '联盟'],
      'prefix_nature': ['绿色', '生态', '自然', '环保', '清新', '森林', '海洋', '天空', '阳光', '月光'],
      'suffix_nature': ['自然', '生态', '环保', '绿色', '清新', '森林', '海洋', '天空', '阳光', '月光'],
    };
  }

  /// 获取默认词汇
  List<String> _getDefaultWords(String category, String type) {
    Map<String, List<String>> defaultWords = {
      'prefix_tech': ['智能', '数字', '科技', '创新', '网络', '云端', '数据', '代码', '未来', '极客'],
      'suffix_tech': ['系统', '平台', '中心', '工作室', '科技', '实验室', '引擎', '核心', '网络', '云'],
      'prefix_creative': ['创意', '艺术', '设计', '视觉', '灵感', '梦想', '魔法', '火花', '光影', '色彩'],
      'suffix_creative': ['工作室', '设计', '创意', '艺术', '视觉', '媒体', '影像', '空间', '美学', '创作'],
      'prefix_business': ['专业', '精英', '成功', '全球', '战略', '优质', '卓越', '领先', '顶级', '王牌'],
      'suffix_business': ['企业', '集团', '公司', '合作', '投资', '控股', '资本', '商务', '贸易', '联盟'],
      'prefix_nature': ['绿色', '生态', '自然', '环保', '清新', '森林', '海洋', '天空', '阳光', '月光'],
      'suffix_nature': ['自然', '生态', '环保', '绿色', '清新', '森林', '海洋', '天空', '阳光', '月光'],
    };
    
    String key = '${type}_$category';
    return defaultWords[key] ?? ['默认', '名称'];
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
      // 尝试分割名称为两部分
      if (locale == 'zh') {
        // 中文名称分割
        if (name.length >= 4) {
          int mid = name.length ~/ 2;
          return WordPair(name.substring(0, mid), name.substring(mid));
        } else {
          return WordPair(name, _getRandomSuffix(locale));
        }
      } else {
        // 英文名称分割
        List<String> parts = name.split(RegExp(r'[\s\-_]+'));
        if (parts.length >= 2) {
          return WordPair(parts[0], parts.sublist(1).join(''));
        } else {
          WordPair randomPair = WordPair.random();
          return WordPair(name, randomPair.second);
        }
      }
    }).toList();
  }

  /// 智能评分系统 - 根据提示词对生成的名称进行评分
  int scoreNameForPrompt(String name, String prompt, String locale) {
    int score = 0;
    String lowerName = name.toLowerCase();
    String lowerPrompt = prompt.toLowerCase();
    
    // 直接匹配加分
    if (lowerName.contains(lowerPrompt)) {
      score += 20;
    }
    
    // 关键词匹配加分
    List<String> promptWords = lowerPrompt.split(RegExp(r'\s+'));
    for (String word in promptWords) {
      if (word.length > 1 && lowerName.contains(word)) {
        score += 10;
      }
    }
    
    // 类别匹配加分
    String category = _classifyPrompt(prompt, locale);
    List<String> categoryWords = _getWordsForCategory(category, 'prefix') + 
                                _getWordsForCategory(category, 'suffix');
    
    for (String categoryWord in categoryWords) {
      if (lowerName.contains(categoryWord.toLowerCase())) {
        score += 15;
      }
    }
    
    // 长度适中加分
    if (name.length >= 4 && name.length <= 12) {
      score += 5;
    }
    
    return score;
  }
}