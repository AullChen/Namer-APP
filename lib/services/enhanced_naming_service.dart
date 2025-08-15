import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/services/language_service.dart';
import 'package:flutter_application_1/services/ai_api_service.dart';
import 'package:flutter_application_1/services/semantic_parser_service.dart';

/// 增强的智能命名服务
class EnhancedNamingService extends StateNotifier<AsyncValue<List<String>>> {
  EnhancedNamingService(this._ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final Ref _ref;
  final Random _random = Random();
  Map<String, Map<String, List<String>>> _multiLanguageResources = {};
  
  /// 多语言词库结构
  final Map<String, String> _languageFiles = {
    'zh': 'names_zh.arb',
    'en': 'names_en.arb',
    'ja': 'names_ja.arb',
    'ko': 'names_ko.arb',
    'fr': 'names_fr.arb',
    'de': 'names_de.arb',
    'es': 'names_es.arb',
    'ru': 'names_ru.arb',
  };

  /// 初始化服务
  Future<void> _initialize() async {
    try {
      await _loadAllLanguageResources();
      state = const AsyncValue.data([]);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 加载所有语言资源
  Future<void> _loadAllLanguageResources() async {
    for (final entry in _languageFiles.entries) {
      try {
        final resourceString = await rootBundle.loadString('assets/locales/${entry.value}');
        final resourceData = json.decode(resourceString) as Map<String, dynamic>;
        
        // 过滤掉元数据，只保留词库数据
        final filteredData = <String, List<String>>{};
        resourceData.forEach((key, value) {
          if (!key.startsWith('@@') && value is List) {
            filteredData[key] = List<String>.from(value);
          }
        });
        
        _multiLanguageResources[entry.key] = filteredData;
      } catch (e) {
        print('Failed to load ${entry.key} resources: $e');
        // 为失败的语言创建空资源
        _multiLanguageResources[entry.key] = {};
      }
    }
  }

  /// 生成名称（主要方法）
  Future<List<String>> generateNames(String prompt, {int count = 5}) async {
    state = const AsyncValue.loading();
    
    try {
      final currentLanguage = _ref.read(currentLanguageProvider);
      final aiApiState = _ref.read(aiApiServiceProvider);
      
      List<String> names = [];
      
      // 如果使用AI模式且配置可用
      if (!aiApiState.useLocalEngine && aiApiState.currentConfig != null) {
        final aiNames = await _ref.read(aiApiServiceProvider.notifier)
            .generateNamesWithAI(prompt, currentLanguage.code);
        
        if (aiNames.isNotEmpty) {
          names.addAll(aiNames);
        }
      }
      
      // 如果AI生成失败或使用本地引擎，使用本地算法补充
      if (names.length < count) {
        final localNames = await _generateLocalNames(prompt, currentLanguage.code, count - names.length);
        names.addAll(localNames);
      }
      
      // 确保返回指定数量的名称
      if (names.length > count) {
        names = names.take(count).toList();
      }
      
      state = AsyncValue.data(names);
      return names;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return [];
    }
  }

  /// 本地名称生成算法 - 增强版本
  Future<List<String>> _generateLocalNames(String prompt, String languageCode, int count) async {
    print('🔧 本地引擎开始生成，提示词: "$prompt", 语言: $languageCode');
    
    final resources = _multiLanguageResources[languageCode] ?? {};
    if (resources.isEmpty) {
      print('⚠️ 语言资源为空，使用智能回退方案');
      return _generateIntelligentFallback(prompt, languageCode, count);
    }

    // 使用语义分析
    final semanticResult = SemanticParserService().parseSemantics(prompt);
    print('🔍 语义分析结果: ${semanticResult.categories}');
    
    final names = <String>[];
    final usedNames = <String>{};
    
    // 基于提示词关键字生成更相关的名称
    final promptKeywords = _extractKeywords(prompt);
    print('🔑 提取的关键词: $promptKeywords');
    
    // 多策略生成名称
    final strategies = [
      () => _generateByPromptDirect(prompt, languageCode), // 直接基于提示词
      () => _generateByKeywords(resources, promptKeywords, languageCode), // 基于关键词
      () => _generateBySemantics(resources, semanticResult, languageCode), // 基于语义
      () => _generateByContext(prompt, languageCode), // 基于上下文
      () => _generateCreative(prompt, languageCode), // 创意生成
    ];
    
    // 使用多种策略生成名称
    for (int attempt = 0; attempt < count * 3 && names.length < count; attempt++) {
      final strategy = strategies[attempt % strategies.length];
      final name = strategy();
      
      if (name.isNotEmpty && !usedNames.contains(name) && _isValidGeneratedName(name)) {
        names.add(name);
        usedNames.add(name);
        print('✅ 生成名称: $name (策略${attempt % strategies.length + 1})');
      }
    }
    
    // 如果生成的名称不够，使用智能回退方法
    while (names.length < count) {
      final fallbackName = _generateSmartFallback(prompt, languageCode, names.length);
      if (!usedNames.contains(fallbackName)) {
        names.add(fallbackName);
        usedNames.add(fallbackName);
        print('🔄 回退名称: $fallbackName');
      }
    }
    
    print('🎯 本地引擎生成完成: $names');
    return names;
  }

  /// 直接基于提示词生成
  String _generateByPromptDirect(String prompt, String languageCode) {
    if (prompt.isEmpty) return '';
    
    final cleanPrompt = prompt.trim();
    
    switch (languageCode) {
      case 'zh':
        if (cleanPrompt.length <= 6) {
          return '${cleanPrompt}助手';
        } else {
          return '智能${cleanPrompt.substring(0, 4)}';
        }
      case 'en':
        final words = cleanPrompt.split(' ');
        if (words.length == 1) {
          return '${words[0].capitalize()}Pro';
        } else {
          return '${words[0].capitalize()}${words.length > 1 ? words[1].capitalize() : ''}Hub';
        }
      case 'ja':
        return '${cleanPrompt}システム';
      case 'ko':
        return '${cleanPrompt}도구';
      default:
        return '${cleanPrompt.capitalize()}Tool';
    }
  }

  /// 基于语义生成
  String _generateBySemantics(Map<String, List<String>> resources, SemanticAnalysisResult semanticResult, String languageCode) {
    if (semanticResult.categories.isEmpty) return '';
    
    return _generateByCategory(resources, semanticResult, languageCode);
  }

  /// 基于上下文生成
  String _generateByContext(String prompt, String languageCode) {
    final contextPatterns = {
      'zh': {
        '游戏': ['游戏工坊', '娱乐中心', '互动平台'],
        '学习': ['学习助手', '教育平台', '知识库'],
        '工作': ['办公助手', '效率工具', '管理系统'],
        '生活': ['生活助手', '便民服务', '智能管家'],
        '创意': ['创意工坊', '设计工具', '艺术平台'],
      },
      'en': {
        'game': ['GameHub', 'PlayCenter', 'FunZone'],
        'learn': ['LearnPro', 'EduPlatform', 'KnowledgeBase'],
        'work': ['WorkFlow', 'ProTools', 'OfficeHub'],
        'life': ['LifeHelper', 'SmartHome', 'DailyAssist'],
        'creative': ['CreativeStudio', 'DesignLab', 'ArtSpace'],
      }
    };
    
    final patterns = contextPatterns[languageCode] ?? contextPatterns['en']!;
    
    for (final entry in patterns.entries) {
      if (prompt.toLowerCase().contains(entry.key)) {
        final options = entry.value;
        return options[_random.nextInt(options.length)];
      }
    }
    
    return '';
  }

  /// 创意生成
  String _generateCreative(String prompt, String languageCode) {
    final creativeTemplates = {
      'zh': [
        '${prompt}星球',
        '超级$prompt',
        '${prompt}魔法师',
        '${prompt}实验室',
        '未来$prompt',
      ],
      'en': [
        '${prompt.capitalize()}Verse',
        'Super${prompt.capitalize()}',
        '${prompt.capitalize()}Wizard',
        '${prompt.capitalize()}Lab',
        'Future${prompt.capitalize()}',
      ],
      'ja': [
        '${prompt}ワールド',
        'スーパー$prompt',
        '${prompt}マスター',
        '${prompt}ラボ',
        '未来の$prompt',
      ],
      'ko': [
        '${prompt}월드',
        '슈퍼$prompt',
        '${prompt}마스터',
        '${prompt}랩',
        '미래$prompt',
      ],
    };
    
    final templates = creativeTemplates[languageCode] ?? creativeTemplates['en']!;
    return templates[_random.nextInt(templates.length)];
  }

  /// 验证生成的名称是否有效
  bool _isValidGeneratedName(String name) {
    if (name.isEmpty || name.length < 2 || name.length > 30) {
      return false;
    }
    
    // 检查是否包含无效字符
    if (name.contains(RegExp(r'[<>{}[\]\\|`~]'))) {
      return false;
    }
    
    return true;
  }

  /// 智能回退方案
  List<String> _generateIntelligentFallback(String prompt, String languageCode, int count) {
    print('🔄 使用智能回退方案生成名称');
    
    final names = <String>[];
    final baseTemplates = _getLanguageTemplates(languageCode);
    
    for (int i = 0; i < count; i++) {
      final template = baseTemplates[i % baseTemplates.length];
      final name = template.replaceAll('{prompt}', prompt.isEmpty ? '智能项目' : prompt)
                          .replaceAll('{index}', '${i + 1}');
      names.add(name);
    }
    
    return names;
  }

  /// 获取语言模板
  List<String> _getLanguageTemplates(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return [
          '{prompt}助手',
          '智能{prompt}',
          '{prompt}平台',
          '{prompt}工具',
          '超级{prompt}',
        ];
      case 'en':
        return [
          '{prompt}Helper',
          'Smart{prompt}',
          '{prompt}Platform',
          '{prompt}Tool',
          'Super{prompt}',
        ];
      case 'ja':
        return [
          '{prompt}ヘルパー',
          'スマート{prompt}',
          '{prompt}プラットフォーム',
          '{prompt}ツール',
          'スーパー{prompt}',
        ];
      case 'ko':
        return [
          '{prompt}도우미',
          '스마트{prompt}',
          '{prompt}플랫폼',
          '{prompt}도구',
          '슈퍼{prompt}',
        ];
      default:
        return [
          '{prompt}Helper',
          'Smart{prompt}',
          '{prompt}Hub',
          '{prompt}Pro',
          'Super{prompt}',
        ];
    }
  }

  /// 提取关键词
  List<String> _extractKeywords(String prompt) {
    if (prompt.isEmpty) return [];
    
    // 简单的关键词提取逻辑
    final keywords = prompt
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\u4e00-\u9fff]'), ' ') // 保留中文字符
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 1)
        .toList();
    
    return keywords;
  }

  /// 基于关键词生成名称
  String _generateByKeywords(Map<String, List<String>> resources, List<String> keywords, String languageCode) {
    final keyword = keywords[_random.nextInt(keywords.length)];
    
    // 查找与关键词相关的前缀和后缀
    final allPrefixes = <String>[];
    final allSuffixes = <String>[];
    
    resources.forEach((key, value) {
      if (key.startsWith('prefix_')) {
        allPrefixes.addAll(value);
      } else if (key.startsWith('suffix_')) {
        allSuffixes.addAll(value);
      }
    });
    
    if (allPrefixes.isEmpty || allSuffixes.isEmpty) {
      return _generateSmartFallback(keyword, languageCode, 0);
    }
    
    // 根据语言选择合适的组合方式
    switch (languageCode) {
      case 'zh':
        return _generateChineseName(keyword, allPrefixes, allSuffixes);
      case 'en':
        return _generateEnglishName(keyword, allPrefixes, allSuffixes);
      case 'ja':
        return _generateJapaneseName(keyword, allPrefixes, allSuffixes);
      case 'ko':
        return _generateKoreanName(keyword, allPrefixes, allSuffixes);
      default:
        final prefix = allPrefixes[_random.nextInt(allPrefixes.length)];
        final suffix = allSuffixes[_random.nextInt(allSuffixes.length)];
        return _combineWords(prefix, suffix, languageCode);
    }
  }

  /// 生成中文名称
  String _generateChineseName(String keyword, List<String> prefixes, List<String> suffixes) {
    final patterns = [
      () => '${prefixes[_random.nextInt(prefixes.length)]}$keyword',
      () => '$keyword${suffixes[_random.nextInt(suffixes.length)]}',
      () => '${prefixes[_random.nextInt(prefixes.length)]}$keyword${suffixes[_random.nextInt(suffixes.length)]}',
      () => '智能$keyword',
      () => '创新$keyword',
      () => '$keyword平台',
      () => '$keyword工具',
    ];
    
    return patterns[_random.nextInt(patterns.length)]();
  }

  /// 生成英文名称
  String _generateEnglishName(String keyword, List<String> prefixes, List<String> suffixes) {
    final patterns = [
      () => '${prefixes[_random.nextInt(prefixes.length)]} ${keyword.capitalize()}',
      () => '${keyword.capitalize()} ${suffixes[_random.nextInt(suffixes.length)]}',
      () => '${prefixes[_random.nextInt(prefixes.length)]}${keyword.capitalize()}',
      () => '${keyword.capitalize()}${suffixes[_random.nextInt(suffixes.length)]}',
      () => 'Smart ${keyword.capitalize()}',
      () => '${keyword.capitalize()} Pro',
      () => '${keyword.capitalize()} Hub',
    ];
    
    return patterns[_random.nextInt(patterns.length)]();
  }

  /// 生成日文名称
  String _generateJapaneseName(String keyword, List<String> prefixes, List<String> suffixes) {
    final patterns = [
      () => '${prefixes[_random.nextInt(prefixes.length)]}$keyword',
      () => '$keyword${suffixes[_random.nextInt(suffixes.length)]}',
      () => 'スマート$keyword',
      () => '$keywordシステム',
      () => '$keywordプロジェクト',
    ];
    
    return patterns[_random.nextInt(patterns.length)]();
  }

  /// 生成韩文名称
  String _generateKoreanName(String keyword, List<String> prefixes, List<String> suffixes) {
    final patterns = [
      () => '${prefixes[_random.nextInt(prefixes.length)]}$keyword',
      () => '$keyword${suffixes[_random.nextInt(suffixes.length)]}',
      () => '스마트$keyword',
      () => '$keyword시스템',
      () => '$keyword프로젝트',
    ];
    
    return patterns[_random.nextInt(patterns.length)]();
  }

  /// 智能回退生成
  String _generateSmartFallback(String prompt, String languageCode, int index) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    final suffix = index > 0 ? '${index + 1}' : timestamp;
    
    if (prompt.isNotEmpty) {
      switch (languageCode) {
        case 'zh':
          return prompt.length > 10 ? '智能项目$suffix' : '$prompt项目$suffix';
        case 'ja':
          return prompt.length > 10 ? 'スマートプロジェクト$suffix' : '$promptプロジェクト$suffix';
        case 'ko':
          return prompt.length > 10 ? '스마트프로젝트$suffix' : '$prompt프로젝트$suffix';
        default:
          return prompt.length > 20 ? 'SmartProject$suffix' : '${prompt.capitalize()}Project$suffix';
      }
    }
    
    return _generateFallbackName(prompt, languageCode);
  }

  /// 基于分类生成名称
  String _generateByCategory(Map<String, List<String>> resources, SemanticAnalysisResult semanticResult, String languageCode) {
    final category = semanticResult.categories.first;
    
    // 查找相关的前缀和后缀
    final prefixKey = 'prefix_${_getCategoryKey(category)}';
    final suffixKey = 'suffix_${_getCategoryKey(category)}';
    
    final prefixes = resources[prefixKey] ?? resources['prefix_general'] ?? ['Smart', 'New', 'Pro'];
    final suffixes = resources[suffixKey] ?? resources['suffix_general'] ?? ['Hub', 'Lab', 'Studio'];
    
    final prefix = prefixes[_random.nextInt(prefixes.length)];
    final suffix = suffixes[_random.nextInt(suffixes.length)];
    
    return _combineWords(prefix, suffix, languageCode);
  }


  /// 组合词汇
  String _combineWords(String prefix, String suffix, String languageCode) {
    switch (languageCode) {
      case 'zh':
      case 'ja':
      case 'ko':
        // 中日韩语言直接连接
        return '$prefix$suffix';
      default:
        // 其他语言用空格连接
        return '$prefix $suffix';
    }
  }

  /// 获取分类键
  String _getCategoryKey(String category) {
    final categoryMap = {
      '科技': 'tech',
      '创意': 'creative',
      '商业': 'business',
      '自然': 'nature',
      '艺术': 'art',
      '游戏': 'game',
      '音乐': 'music',
    };
    
    return categoryMap[category] ?? 'general';
  }


  /// 单个回退名称生成
  String _generateFallbackName(String prompt, String languageCode) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    
    if (prompt.isNotEmpty) {
      switch (languageCode) {
        case 'zh':
          return '$prompt项目$timestamp';
        case 'ja':
          return '$promptプロジェクト$timestamp';
        case 'ko':
          return '$prompt프로젝트$timestamp';
        default:
          return '${prompt.capitalize()}Project$timestamp';
      }
    }
    
    switch (languageCode) {
      case 'zh':
        return '智能项目$timestamp';
      case 'ja':
        return 'スマートプロジェクト$timestamp';
      case 'ko':
        return '스마트프로젝트$timestamp';
      default:
        return 'SmartProject$timestamp';
    }
  }

  /// 根据关键词生成名称
  Future<List<String>> generateByKeywords(List<String> keywords, {int count = 5}) async {
    final prompt = keywords.join(' ');
    return generateNames(prompt, count: count);
  }

  /// 生成特定风格的名称
  Future<List<String>> generateByStyle(String prompt, String style, {int count = 5}) async {
    final styledPrompt = '$style风格的$prompt';
    return generateNames(styledPrompt, count: count);
  }

  /// 批量生成名称
  Future<Map<String, List<String>>> batchGenerate(List<String> prompts, {int countPerPrompt = 3}) async {
    final results = <String, List<String>>{};
    
    for (final prompt in prompts) {
      final names = await generateNames(prompt, count: countPerPrompt);
      results[prompt] = names;
    }
    
    return results;
  }

  /// 获取支持的语言列表
  List<String> getSupportedLanguages() {
    return _languageFiles.keys.toList();
  }

  /// 检查语言是否支持
  bool isLanguageSupported(String languageCode) {
    return _multiLanguageResources.containsKey(languageCode);
  }

  /// 获取当前语言的统计信息
  Map<String, int> getLanguageStats(String languageCode) {
    final resources = _multiLanguageResources[languageCode] ?? {};
    final stats = <String, int>{};
    
    resources.forEach((key, value) {
      stats[key] = value.length;
    });
    
    return stats;
  }
}

/// 字符串扩展
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

/// 增强命名服务提供者
final enhancedNamingServiceProvider = StateNotifierProvider<EnhancedNamingService, AsyncValue<List<String>>>((ref) {
  return EnhancedNamingService(ref);
});

/// 当前生成的名称提供者
final currentGeneratedNamesProvider = Provider<List<String>>((ref) {
  final asyncValue = ref.watch(enhancedNamingServiceProvider);
  return asyncValue.when(
    data: (names) => names,
    loading: () => [],
    error: (_, __) => [],
  );
});