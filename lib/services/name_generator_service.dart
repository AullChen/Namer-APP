import 'dart:math';
import 'package:english_words/english_words.dart';
import 'package:flutter_application_1/services/semantic_parser_service.dart';
import 'naming_format_service.dart';
import 'dynamic_length_service.dart';
import 'advanced_ai_service.dart';

/// 智能名称生成服务
/// 集成了自然语言处理和上下文理解功能的AI模型
class NameGeneratorService {
  final Random _random = Random();
  final SemanticParserService _semanticParser = SemanticParserService();
  
  // 语义词典 - 用于上下文理解
  static const Map<String, List<String>> _semanticGroups = {
    'technology': ['tech', 'digital', 'cyber', 'smart', 'ai', 'data', 'cloud', 'net', 'code', 'app'],
    'business': ['pro', 'corp', 'biz', 'trade', 'market', 'sales', 'profit', 'growth', 'success', 'elite'],
    'creative': ['art', 'design', 'creative', 'studio', 'craft', 'vision', 'inspire', 'dream', 'magic', 'spark'],
    'nature': ['green', 'eco', 'natural', 'earth', 'forest', 'ocean', 'sky', 'sun', 'moon', 'star'],
    'power': ['force', 'power', 'strong', 'mighty', 'bold', 'fierce', 'dynamic', 'energy', 'impact', 'drive'],
    'speed': ['fast', 'quick', 'rapid', 'swift', 'turbo', 'flash', 'rocket', 'jet', 'speed', 'rush'],
    'luxury': ['premium', 'luxury', 'elite', 'gold', 'platinum', 'royal', 'crown', 'diamond', 'pearl', 'silk'],
    'innovation': ['new', 'next', 'future', 'advance', 'pioneer', 'edge', 'breakthrough', 'revolution', 'evolve', 'transform']
  };
  
  // 音韵模式 - 用于生成和谐的名称
  static const Map<String, List<String>> _phoneticPatterns = {
    'alliteration': ['b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'r', 's', 't', 'v', 'w'],
    'vowel_harmony': ['a', 'e', 'i', 'o', 'u'],
    'consonant_clusters': ['bl', 'br', 'cl', 'cr', 'dr', 'fl', 'fr', 'gl', 'gr', 'pl', 'pr', 'sc', 'sk', 'sl', 'sm', 'sn', 'sp', 'st', 'sw', 'tr']
  };
  
  // 词频权重 - 基于使用频率的智能评分
  static const Map<String, int> _wordFrequencyWeights = {
    'high': 3, 'medium': 2, 'low': 1, 'rare': 0
  };

  /// 基础随机生成 - 使用改进的随机算法
  WordPair generateRandomPair() {
    return WordPair.random();
  }
  
  /// 智能偏好生成 - 基于用户偏好的AI驱动生成
  WordPair generateBasedOnPreferences(Map<String, dynamic> preferences) {
    String lengthPreference = preferences['nameLength'] ?? 'medium';
    String stylePreference = preferences['nameStyle'] ?? 'modern';
    
    // 使用更大的候选池以提高质量
    List<WordPair> rawCandidates = List.generate(50, (_) => WordPair.random());
    
    // 应用多层评分系统
    List<_ScoredWordPair> scoredCandidates = rawCandidates.map((pair) {
      return _ScoredWordPair(
        pair, 
        _calculateAdvancedPreferenceScore(pair, lengthPreference, stylePreference)
      );
    }).toList();
    
    // 按分数排序并选择最佳候选
    scoredCandidates.sort((a, b) => b.score.compareTo(a.score));
    
    // 从前20%中随机选择，增加多样性
    int topCandidatesCount = (scoredCandidates.length * 0.2).ceil();
    int selectedIndex = _random.nextInt(topCandidatesCount);
    
    return scoredCandidates[selectedIndex].wordPair;
  }
  
  /// 智能关键词生成 - 增强的NLP和上下文理解
  WordPair generateBasedOnKeyword(String keyword) {
    if (keyword.isEmpty) return generateRandomPair();
    
    // 使用语义解析服务分析输入
    SemanticAnalysisResult semanticResult = _semanticParser.parseSemantics(keyword);
    
    // 预处理关键词
    String processedKeyword = _preprocessKeyword(keyword);
    
    // 识别语义类别（结合新的语义分析结果）
    String? semanticCategory = _identifySemanticCategory(processedKeyword);
    if (semanticResult.categories.isNotEmpty) {
      semanticCategory = semanticResult.categories.first;
    }
    
    // 生成上下文相关的候选词（使用语义分析结果）
    List<WordPair> rawCandidates = _generateEnhancedContextualCandidates(
      processedKeyword, 
      semanticCategory, 
      semanticResult
    );
    
    // 应用高级相似度评分（集成语义权重）
    List<_ScoredWordPair> scoredCandidates = rawCandidates.map((pair) {
      return _ScoredWordPair(
        pair, 
        _calculateEnhancedSimilarity(pair, processedKeyword, semanticCategory, semanticResult)
      );
    }).toList();
    
    // 排序并选择最佳匹配
    scoredCandidates.sort((a, b) => b.score.compareTo(a.score));
    
    return scoredCandidates.isNotEmpty ? scoredCandidates.first.wordPair : generateRandomPair();
  }
  
  /// 生成多样化候选名称 - 全面升级版本
  Future<List<WordPair>> generateCandidates({
    int count = 5,
    Map<String, dynamic>? preferences,
    String? keyword,
    String format = 'default',
    String lengthCategory = 'auto',
  }) async {
    try {
      // 使用先进AI服务生成高质量名称
      List<String> aiGeneratedNames = await AdvancedAIService.generateAdvancedNames(
        prompt: keyword ?? '智能名称生成',
        count: count,
        format: format,
        lengthCategory: lengthCategory,
      );
      
      // 转换为WordPair格式并应用格式化
      List<WordPair> candidates = [];
      for (String name in aiGeneratedNames) {
        // 应用命名格式
        String formattedName = NamingFormatService.formatName(name, format);
        
        // 分割为词对（如果可能）
        List<String> parts = formattedName.split(RegExp(r'[\s_\-\.]+'));
        if (parts.length >= 2) {
          candidates.add(WordPair(parts[0], parts.sublist(1).join('')));
        } else {
          // 单词情况，生成配对词
          WordPair randomPair = WordPair.random();
          candidates.add(WordPair(formattedName, randomPair.second));
        }
      }
      
      // 如果AI生成失败，回退到传统方法
      if (candidates.isEmpty) {
        return _generateTraditionalCandidates(count, preferences, keyword);
      }
      
      return candidates;
    } catch (e) {
      // 错误处理：回退到传统生成方法
      return _generateTraditionalCandidates(count, preferences, keyword);
    }
  }

  /// 传统候选名称生成方法（作为备用）
  List<WordPair> _generateTraditionalCandidates(
    int count,
    Map<String, dynamic>? preferences,
    String? keyword,
  ) {
    Set<WordPair> uniqueCandidates = {};
    
    while (uniqueCandidates.length < count) {
      WordPair candidate;
      
      if (keyword != null && keyword.isNotEmpty) {
        candidate = generateBasedOnKeyword(keyword);
      } else if (preferences != null) {
        candidate = generateBasedOnPreferences(preferences);
      } else {
        candidate = generateRandomPair();
      }
      
      uniqueCandidates.add(candidate);
    }
    
    return uniqueCandidates.toList();
  }

  /// 新增：智能名称生成接口
  static Future<List<WordPair>> generateNames({
    required int count,
    String? userInput,
    String preference = 'balanced',
    String lengthCategory = 'auto',
    String format = 'default',
    String style = 'modern',
  }) async {
    final service = NameGeneratorService();
    
    // 动态确定长度类别
    String actualLengthCategory = lengthCategory;
    if (lengthCategory == 'auto' && userInput != null && userInput.isNotEmpty) {
      actualLengthCategory = DynamicLengthService.determineLengthCategory(userInput);
    }
    
    // 构建偏好设置
    Map<String, dynamic> preferences = {
      'nameLength': _mapLengthCategoryToPreference(actualLengthCategory),
      'nameStyle': style,
      'preference': preference,
    };
    
    // 生成候选名称
    List<WordPair> candidates = await service.generateCandidates(
      count: count,
      preferences: preferences,
      keyword: userInput,
      format: format,
      lengthCategory: actualLengthCategory,
    );
    
    return candidates;
  }

  /// 长度类别映射到传统偏好
  static String _mapLengthCategoryToPreference(String lengthCategory) {
    switch (lengthCategory) {
      case 'short':
        return 'short';
      case 'medium':
        return 'medium';
      case 'long':
        return 'long';
      default:
        return 'medium';
    }
  }
  
  /// 预处理关键词 - 清理和标准化输入
  String _preprocessKeyword(String keyword) {
    return keyword
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s]'), '') // 移除特殊字符
        .replaceAll(RegExp(r'\s+'), ' '); // 标准化空格
  }
  
  /// 识别语义类别 - AI驱动的上下文理解
  String? _identifySemanticCategory(String keyword) {
    for (String category in _semanticGroups.keys) {
      List<String> words = _semanticGroups[category]!;
      for (String word in words) {
        if (keyword.contains(word) || _calculateLevenshteinDistance(keyword, word) <= 2) {
          return category;
        }
      }
    }
    return null;
  }
  
  /// 生成上下文相关候选词
  List<WordPair> _generateContextualCandidates(String keyword, String? category) {
    List<WordPair> candidates = [];
    
    // 生成基础候选词
    candidates.addAll(List.generate(30, (_) => WordPair.random()));
    
    // 如果识别到语义类别，生成相关候选词
    if (category != null) {
      List<String> relatedWords = _semanticGroups[category]!;
      for (int i = 0; i < 20; i++) {
        String relatedWord = relatedWords[_random.nextInt(relatedWords.length)];
        WordPair randomPair = WordPair.random();
        
        // 创建混合词对
        if (_random.nextBool()) {
          candidates.add(WordPair(relatedWord, randomPair.second));
        } else {
          candidates.add(WordPair(randomPair.first, relatedWord));
        }
      }
    }
    
    return candidates;
  }

  /// 生成增强的上下文相关候选词（集成语义分析）
  List<WordPair> _generateEnhancedContextualCandidates(
    String keyword, 
    String? category, 
    SemanticAnalysisResult semanticResult
  ) {
    List<WordPair> candidates = [];
    
    // 生成基础候选词
    candidates.addAll(List.generate(20, (_) => WordPair.random()));
    
    // 基于语义分析结果生成候选词
    if (semanticResult.relatedWords.isNotEmpty) {
      for (int i = 0; i < 15; i++) {
        String relatedWord = semanticResult.relatedWords[_random.nextInt(semanticResult.relatedWords.length)];
        WordPair randomPair = WordPair.random();
        
        // 创建混合词对
        if (_random.nextBool()) {
          candidates.add(WordPair(relatedWord, randomPair.second));
        } else {
          candidates.add(WordPair(randomPair.first, relatedWord));
        }
      }
    }
    
    // 基于网络流行语生成候选词
    if (semanticResult.internetSlang.isNotEmpty) {
      for (String slang in semanticResult.internetSlang.take(3)) {
        WordPair randomPair = WordPair.random();
        candidates.add(WordPair(slang, randomPair.second));
      }
    }
    
    // 如果识别到传统语义类别，也生成相关候选词
    if (category != null && _semanticGroups.containsKey(category)) {
      List<String> relatedWords = _semanticGroups[category]!;
      for (int i = 0; i < 10; i++) {
        String relatedWord = relatedWords[_random.nextInt(relatedWords.length)];
        WordPair randomPair = WordPair.random();
        
        if (_random.nextBool()) {
          candidates.add(WordPair(relatedWord, randomPair.second));
        } else {
          candidates.add(WordPair(randomPair.first, relatedWord));
        }
      }
    }
    
    return candidates;
  }
  
  /// 高级偏好评分系统
  int _calculateAdvancedPreferenceScore(WordPair pair, String lengthPreference, String stylePreference) {
    int score = 0;
    
    // 长度评分 - 更精确的长度匹配
    int totalLength = pair.first.length + pair.second.length;
    score += _calculateLengthScore(totalLength, lengthPreference);
    
    // 风格评分 - 增强的风格识别
    score += _calculateStyleScore(pair, stylePreference);
    
    // 音韵评分 - 新增的音韵和谐度
    score += _calculatePhoneticScore(pair);
    
    // 可读性评分 - 名称的易读性
    score += _calculateReadabilityScore(pair);
    
    // 独特性评分 - 名称的独特程度
    score += _calculateUniquenessScore(pair);
    
    return score;
  }
  
  /// 高级相似度计算
  int _calculateAdvancedSimilarity(WordPair pair, String keyword, String? category) {
    int score = 0;
    
    // 直接匹配评分
    score += _calculateDirectMatchScore(pair, keyword);
    
    // 语义相似度评分
    if (category != null) {
      score += _calculateSemanticSimilarityScore(pair, category);
    }
    
    // 音韵相似度评分
    score += _calculatePhoneticSimilarityScore(pair, keyword);
    
    // 字符相似度评分（使用编辑距离）
    score += _calculateCharacterSimilarityScore(pair, keyword);
    
    return score;
  }

  /// 增强的相似度计算（集成语义分析结果）
  int _calculateEnhancedSimilarity(
    WordPair pair, 
    String keyword, 
    String? category, 
    SemanticAnalysisResult semanticResult
  ) {
    int score = 0;
    
    // 基础相似度评分
    score += _calculateAdvancedSimilarity(pair, keyword, category);
    
    // 语义权重加成
    if (semanticResult.weights.isNotEmpty) {
      score += _calculateSemanticWeightBonus(pair, semanticResult.weights);
    }
    
    // 时效信息加成
    if (semanticResult.timeContext.isNotEmpty) {
      score += _calculateTimeContextBonus(pair, semanticResult.timeContext);
    }
    
    // 网络流行语加成
    if (semanticResult.internetSlang.isNotEmpty) {
      score += _calculateInternetSlangBonus(pair, semanticResult.internetSlang);
    }
    
    // 情感强度加成
    score += _calculateEmotionIntensityBonus(pair, semanticResult.emotionIntensity);
    
    // 置信度调整
    score = (score * semanticResult.confidence).round();
    
    return score;
  }
  
  /// 长度评分计算
  int _calculateLengthScore(int totalLength, String lengthPreference) {
    switch (lengthPreference) {
      case 'short':
        if (totalLength <= 8) return 5;
        if (totalLength <= 12) return 3;
        if (totalLength <= 16) return 1;
        return 0;
      case 'medium':
        if (totalLength >= 10 && totalLength <= 16) return 5;
        if (totalLength >= 8 && totalLength <= 20) return 3;
        return 1;
      case 'long':
        if (totalLength >= 16) return 5;
        if (totalLength >= 12) return 3;
        if (totalLength >= 8) return 1;
        return 0;
      default:
        return 2;
    }
  }
  
  /// 风格评分计算
  int _calculateStyleScore(WordPair pair, String stylePreference) {
    switch (stylePreference) {
      case 'classic':
        int score = 0;
        score += _isCommonWord(pair.first) ? 3 : 0;
        score += _isCommonWord(pair.second) ? 3 : 0;
        score += _hasTraditionalPattern(pair) ? 2 : 0;
        return score;
      case 'modern':
        int score = 0;
        score += _hasGoodRhythm(pair) ? 4 : 0;
        score += _hasModernAppeal(pair) ? 3 : 0;
        score += _isBalanced(pair) ? 2 : 0;
        return score;
      case 'futuristic':
        int score = 0;
        score += !_isCommonWord(pair.first) ? 3 : 0;
        score += !_isCommonWord(pair.second) ? 3 : 0;
        score += _hasUnusualCombination(pair) ? 4 : 0;
        score += _hasTechAppeal(pair) ? 2 : 0;
        return score;
      default:
        return 2;
    }
  }
  
  /// 音韵评分计算
  int _calculatePhoneticScore(WordPair pair) {
    int score = 0;
    
    // 头韵检查
    if (pair.first.isNotEmpty && pair.second.isNotEmpty) {
      if (pair.first[0].toLowerCase() == pair.second[0].toLowerCase()) {
        score += 3;
      }
    }
    
    // 元音和谐检查
    if (_hasVowelHarmony(pair)) {
      score += 2;
    }
    
    // 辅音群检查
    if (_hasGoodConsonantFlow(pair)) {
      score += 2;
    }
    
    return score;
  }
  
  /// 可读性评分计算
  int _calculateReadabilityScore(WordPair pair) {
    int score = 0;
    
    // 长度平衡
    int lengthDiff = (pair.first.length - pair.second.length).abs();
    if (lengthDiff <= 1) score += 3;
    else if (lengthDiff <= 3) score += 1;
    
    // 音节平衡
    if (_hasSyllableBalance(pair)) score += 2;
    
    // 避免难读组合
    if (!_hasDifficultCombination(pair)) score += 2;
    
    return score;
  }
  
  /// 独特性评分计算
  int _calculateUniquenessScore(WordPair pair) {
    int score = 0;
    
    // 罕见词汇奖励
    if (!_isCommonWord(pair.first)) score += 1;
    if (!_isCommonWord(pair.second)) score += 1;
    
    // 独特组合奖励
    if (_isUniqueCombination(pair)) score += 2;
    
    return score;
  }
  
  /// 直接匹配评分
  int _calculateDirectMatchScore(WordPair pair, String keyword) {
    int score = 0;
    String combined = '${pair.first} ${pair.second}'.toLowerCase();
    String keywordLower = keyword.toLowerCase();
    
    // 完全包含
    if (combined.contains(keywordLower)) score += 10;
    
    // 部分包含
    List<String> keywordParts = keywordLower.split(' ');
    for (String part in keywordParts) {
      if (part.length > 2 && combined.contains(part)) {
        score += 5;
      }
    }
    
    // 首字母匹配
    if (keywordLower.isNotEmpty) {
      if (pair.first.toLowerCase().startsWith(keywordLower[0])) score += 3;
      if (pair.second.toLowerCase().startsWith(keywordLower[0])) score += 3;
    }
    
    return score;
  }
  
  /// 语义相似度评分
  int _calculateSemanticSimilarityScore(WordPair pair, String category) {
    int score = 0;
    List<String> categoryWords = _semanticGroups[category] ?? [];
    
    for (String word in categoryWords) {
      if (pair.first.toLowerCase().contains(word) || 
          pair.second.toLowerCase().contains(word)) {
        score += 4;
      }
      
      // 使用编辑距离检查相似性
      if (_calculateLevenshteinDistance(pair.first.toLowerCase(), word) <= 2) {
        score += 2;
      }
      if (_calculateLevenshteinDistance(pair.second.toLowerCase(), word) <= 2) {
        score += 2;
      }
    }
    
    return score;
  }
  
  /// 音韵相似度评分
  int _calculatePhoneticSimilarityScore(WordPair pair, String keyword) {
    int score = 0;
    
    // 检查相似的音韵模式
    if (keyword.isNotEmpty) {
      String firstChar = keyword[0].toLowerCase();
      if (pair.first.toLowerCase().startsWith(firstChar) || 
          pair.second.toLowerCase().startsWith(firstChar)) {
        score += 2;
      }
    }
    
    return score;
  }
  
  /// 字符相似度评分
  int _calculateCharacterSimilarityScore(WordPair pair, String keyword) {
    int score = 0;
    String combined = pair.first.toLowerCase() + pair.second.toLowerCase();
    String keywordLower = keyword.toLowerCase();
    
    // 计算共同字符
    Set<String> keywordChars = keywordLower.split('').toSet();
    Set<String> combinedChars = combined.split('').toSet();
    int commonChars = keywordChars.intersection(combinedChars).length;
    
    score += commonChars;
    
    return score;
  }
  
  /// Levenshtein距离计算
  int _calculateLevenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;
    
    List<List<int>> matrix = List.generate(
      s1.length + 1, 
      (i) => List.generate(s2.length + 1, (j) => 0)
    );
    
    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }
    
      for (int i = 1; i <= s1.length; i++) {
        for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    return matrix[s1.length][s2.length];
  }
  
  // 辅助方法
  bool _isCommonWord(String word) {
    const commonWords = [
      'time', 'year', 'day', 'way', 'thing', 'man', 'world', 'life', 'hand', 'part',
      'child', 'eye', 'woman', 'place', 'work', 'week', 'case', 'point', 'company', 'number',
      'group', 'problem', 'fact', 'good', 'new', 'first', 'last', 'long', 'great', 'little',
      'own', 'other', 'old', 'right', 'big', 'high', 'different', 'small', 'large', 'next'
    ];
    return commonWords.contains(word.toLowerCase());
  }
  
  bool _hasGoodRhythm(WordPair pair) {
    return (pair.first.length - pair.second.length).abs() <= 2;
  }
  
  bool _hasUnusualCombination(WordPair pair) {
    return pair.first.isNotEmpty && 
           pair.second.isNotEmpty && 
           pair.first[0].toLowerCase() == pair.second[0].toLowerCase();
  }
  
  bool _hasTraditionalPattern(WordPair pair) {
    // 检查是否符合传统命名模式
    return _isCommonWord(pair.first) && _isCommonWord(pair.second);
  }
  
  bool _hasModernAppeal(WordPair pair) {
    // 检查现代感 - 长度适中，不太常见但不太生僻
    int totalLength = pair.first.length + pair.second.length;
    return totalLength >= 8 && totalLength <= 16 && 
           (!_isCommonWord(pair.first) || !_isCommonWord(pair.second));
  }
  
  bool _isBalanced(WordPair pair) {
    return (pair.first.length - pair.second.length).abs() <= 1;
  }
  
  bool _hasTechAppeal(WordPair pair) {
    const techSuffixes = ['tech', 'net', 'web', 'app', 'soft', 'ware', 'data', 'code'];
    String combined = pair.first.toLowerCase() + pair.second.toLowerCase();
    return techSuffixes.any((suffix) => combined.contains(suffix));
  }
  
  bool _hasVowelHarmony(WordPair pair) {
    String vowels1 = pair.first.toLowerCase().replaceAll(RegExp(r'[^aeiou]'), '');
    String vowels2 = pair.second.toLowerCase().replaceAll(RegExp(r'[^aeiou]'), '');
    
    if (vowels1.isEmpty || vowels2.isEmpty) return false;
    
    // 检查主要元音是否和谐
    return vowels1[0] == vowels2[0] || 
           (vowels1.contains('a') && vowels2.contains('a')) ||
           (vowels1.contains('e') && vowels2.contains('e'));
  }
  
  bool _hasGoodConsonantFlow(WordPair pair) {
    // 检查辅音流畅性
    if (pair.first.isEmpty || pair.second.isEmpty) return false;
    
    String lastChar = pair.first[pair.first.length - 1].toLowerCase();
    String firstChar = pair.second[0].toLowerCase();
    
    // 避免难发音的辅音组合
    const difficultCombinations = ['dt', 'kt', 'pt', 'bt', 'ft'];
    String combination = lastChar + firstChar;
    
    return !difficultCombinations.contains(combination);
  }
  
  bool _hasSyllableBalance(WordPair pair) {
    // 简化的音节计算
    int syllables1 = _countSyllables(pair.first);
    int syllables2 = _countSyllables(pair.second);
    
    return (syllables1 - syllables2).abs() <= 1;
  }
  
  int _countSyllables(String word) {
    // 简化的音节计数
    int count = word.toLowerCase().replaceAll(RegExp(r'[^aeiou]'), '').length;
    return count > 0 ? count : 1;
  }
  
  bool _hasDifficultCombination(WordPair pair) {
    // 检查是否有难读的字母组合
    String combined = pair.first.toLowerCase() + pair.second.toLowerCase();
    const difficultPatterns = ['xz', 'qx', 'zx', 'jq', 'vw', 'wv'];
    
    return difficultPatterns.any((pattern) => combined.contains(pattern));
  }
  
  bool _isUniqueCombination(WordPair pair) {
    // 检查是否是独特的组合（简化实现）
    return !_isCommonWord(pair.first) && !_isCommonWord(pair.second) &&
           _hasUnusualCombination(pair);
  }

  /// 语义权重加成计算
  int _calculateSemanticWeightBonus(WordPair pair, Map<String, double> weights) {
    int bonus = 0;
    String combined = '${pair.first} ${pair.second}'.toLowerCase();
    
    // 创意权重加成
    if (weights['creativity'] != null && weights['creativity']! > 0.7) {
      if (_hasCreativeElements(combined)) bonus += 5;
    }
    
    // 科技权重加成
    if (weights['technology'] != null && weights['technology']! > 0.7) {
      if (_hasTechElements(combined)) bonus += 5;
    }
    
    // 商业权重加成
    if (weights['business'] != null && weights['business']! > 0.7) {
      if (_hasBusinessElements(combined)) bonus += 5;
    }
    
    // 自然权重加成
    if (weights['nature'] != null && weights['nature']! > 0.7) {
      if (_hasNatureElements(combined)) bonus += 5;
    }
    
    return bonus;
  }

  /// 时效信息加成计算
  int _calculateTimeContextBonus(WordPair pair, String timeContext) {
    int bonus = 0;
    String combined = '${pair.first} ${pair.second}'.toLowerCase();
    
    switch (timeContext) {
      case 'current':
      case '2024':
      case '2025':
        if (_hasModernElements(combined)) bonus += 4;
        break;
      case '流行':
        if (_hasTrendyElements(combined)) bonus += 6;
        break;
      case '新兴':
        if (_hasInnovativeElements(combined)) bonus += 5;
        break;
      case '经典':
        if (_hasClassicElements(combined)) bonus += 3;
        break;
    }
    
    return bonus;
  }

  /// 网络流行语加成计算
  int _calculateInternetSlangBonus(WordPair pair, List<String> internetSlang) {
    int bonus = 0;
    String combined = '${pair.first} ${pair.second}'.toLowerCase();
    
    for (String slang in internetSlang) {
      if (combined.contains(slang.toLowerCase())) {
        bonus += 8; // 网络流行语匹配给予高分
      }
    }
    
    return bonus;
  }

  /// 情感强度加成计算
  int _calculateEmotionIntensityBonus(WordPair pair, double emotionIntensity) {
    // 根据情感强度调整分数
    int bonus = (emotionIntensity * 10).round();
    
    // 如果名称本身具有强烈的情感色彩，给予额外加成
    String combined = '${pair.first} ${pair.second}'.toLowerCase();
    if (_hasEmotionalElements(combined)) {
      bonus += (emotionIntensity * 5).round();
    }
    
    return bonus;
  }

  // 辅助检测方法
  bool _hasCreativeElements(String text) {
    const creativeWords = ['art', 'design', 'creative', 'studio', 'craft', 'vision', 'inspire', 'dream', 'magic', 'spark'];
    return creativeWords.any((word) => text.contains(word));
  }

  bool _hasTechElements(String text) {
    const techWords = ['tech', 'digital', 'cyber', 'smart', 'ai', 'data', 'cloud', 'net', 'code', 'app'];
    return techWords.any((word) => text.contains(word));
  }

  bool _hasBusinessElements(String text) {
    const businessWords = ['pro', 'corp', 'biz', 'trade', 'market', 'sales', 'profit', 'growth', 'success', 'elite'];
    return businessWords.any((word) => text.contains(word));
  }

  bool _hasNatureElements(String text) {
    const natureWords = ['green', 'eco', 'natural', 'earth', 'forest', 'ocean', 'sky', 'sun', 'moon', 'star'];
    return natureWords.any((word) => text.contains(word));
  }

  bool _hasModernElements(String text) {
    const modernWords = ['next', 'future', 'advance', 'smart', 'digital', 'new', 'modern', 'fresh'];
    return modernWords.any((word) => text.contains(word));
  }

  bool _hasTrendyElements(String text) {
    const trendyWords = ['viral', 'trending', 'hot', 'buzz', 'hype', 'popular', 'cool', 'awesome'];
    return trendyWords.any((word) => text.contains(word));
  }

  bool _hasInnovativeElements(String text) {
    const innovativeWords = ['innovative', 'breakthrough', 'revolutionary', 'cutting', 'edge', 'pioneer', 'disrupt'];
    return innovativeWords.any((word) => text.contains(word));
  }

  bool _hasClassicElements(String text) {
    const classicWords = ['classic', 'traditional', 'timeless', 'heritage', 'vintage', 'retro', 'elegant'];
    return classicWords.any((word) => text.contains(word));
  }

  bool _hasEmotionalElements(String text) {
    const emotionalWords = ['love', 'joy', 'happy', 'bright', 'power', 'strong', 'peace', 'calm', 'energy', 'passion'];
    return emotionalWords.any((word) => text.contains(word));
  }
}

/// 带评分的词对类 - 用于内部评分系统
class _ScoredWordPair {
  final WordPair wordPair;
  final int score;
  
  _ScoredWordPair(this.wordPair, this.score);
}
