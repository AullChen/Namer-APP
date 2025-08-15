import 'package:english_words/english_words.dart';
import 'intelligent_naming_service.dart';
import 'dynamic_length_service.dart';

/// 名称生成服务 - 重构为使用智能命名服务
class NameGeneratorService {
  static final IntelligentNamingService _intelligentService = IntelligentNamingService();
  
  /// 基础随机生成
  WordPair generateRandomPair() {
    return WordPair.random();
  }
  
  /// 智能偏好生成
  WordPair generateBasedOnPreferences(Map<String, dynamic> preferences) {
    String lengthPreference = preferences['nameLength'] ?? 'medium';
    String stylePreference = preferences['nameStyle'] ?? 'modern';
    
    // 生成候选词对
    List<WordPair> candidates = List.generate(20, (_) => WordPair.random());
    
    // 应用评分系统
    List<_ScoredWordPair> scoredCandidates = candidates.map((pair) {
      return _ScoredWordPair(
        pair, 
        _calculatePreferenceScore(pair, lengthPreference, stylePreference)
      );
    }).toList();
    
    // 按分数排序并选择最佳候选
    scoredCandidates.sort((a, b) => b.score.compareTo(a.score));
    
    return scoredCandidates.isNotEmpty ? scoredCandidates.first.wordPair : generateRandomPair();
  }
  
  /// 智能关键词生成
  WordPair generateBasedOnKeyword(String keyword) {
    if (keyword.isEmpty) return generateRandomPair();
    
    // 预处理关键词
    String processedKeyword = keyword.toLowerCase().trim();
    
    // 生成候选词
    List<WordPair> candidates = List.generate(30, (_) => WordPair.random());
    
    // 应用相似度评分
    List<_ScoredWordPair> scoredCandidates = candidates.map((pair) {
      return _ScoredWordPair(
        pair, 
        _calculateSimilarity(pair, processedKeyword)
      );
    }).toList();
    
    // 排序并选择最佳匹配
    scoredCandidates.sort((a, b) => b.score.compareTo(a.score));
    
    return scoredCandidates.isNotEmpty ? scoredCandidates.first.wordPair : generateRandomPair();
  }
  
  /// 生成多样化候选名称
  Future<List<WordPair>> generateCandidates({
    int count = 5,
    Map<String, dynamic>? preferences,
    String? keyword,
    String format = 'default',
    String lengthCategory = 'auto',
  }) async {
    try {
      // 优先使用智能命名服务
      List<WordPair> candidates = await _intelligentService.generateWordPairs(
        prompt: keyword ?? '智能名称生成',
        count: count,
        useAI: true,
      );
      
      if (candidates.isNotEmpty) {
        return candidates;
      }
    } catch (e) {
      print("智能生成失败，使用传统方法: $e");
    }
    
    // 回退到传统生成方法
    return _generateTraditionalCandidates(count, preferences, keyword);
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

  /// 静态智能名称生成接口
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
  
  /// 偏好评分计算
  int _calculatePreferenceScore(WordPair pair, String lengthPreference, String stylePreference) {
    int score = 0;
    
    // 长度评分
    int totalLength = pair.first.length + pair.second.length;
    score += _calculateLengthScore(totalLength, lengthPreference);
    
    // 风格评分
    score += _calculateStyleScore(pair, stylePreference);
    
    return score;
  }
  
  /// 相似度计算
  int _calculateSimilarity(WordPair pair, String keyword) {
    int score = 0;
    String combined = '${pair.first} ${pair.second}'.toLowerCase();
    
    // 直接匹配
    if (combined.contains(keyword)) score += 10;
    
    // 首字母匹配
    if (keyword.isNotEmpty) {
      if (pair.first.toLowerCase().startsWith(keyword[0])) score += 3;
      if (pair.second.toLowerCase().startsWith(keyword[0])) score += 3;
    }
    
    return score;
  }
  
  /// 长度评分计算
  int _calculateLengthScore(int totalLength, String lengthPreference) {
    switch (lengthPreference) {
      case 'short':
        if (totalLength <= 8) return 5;
        if (totalLength <= 12) return 3;
        return 1;
      case 'medium':
        if (totalLength >= 10 && totalLength <= 16) return 5;
        if (totalLength >= 8 && totalLength <= 20) return 3;
        return 1;
      case 'long':
        if (totalLength >= 16) return 5;
        if (totalLength >= 12) return 3;
        return 1;
      default:
        return 2;
    }
  }
  
  /// 风格评分计算
  int _calculateStyleScore(WordPair pair, String stylePreference) {
    switch (stylePreference) {
      case 'classic':
        return _isCommonWord(pair.first) && _isCommonWord(pair.second) ? 5 : 2;
      case 'modern':
        return _hasGoodRhythm(pair) ? 4 : 2;
      case 'futuristic':
        return !_isCommonWord(pair.first) || !_isCommonWord(pair.second) ? 4 : 1;
      default:
        return 2;
    }
  }
  
  // 辅助方法
  bool _isCommonWord(String word) {
    const commonWords = [
      'time', 'year', 'day', 'way', 'thing', 'man', 'world', 'life', 'hand', 'part',
      'child', 'eye', 'woman', 'place', 'work', 'week', 'case', 'point', 'company', 'number'
    ];
    return commonWords.contains(word.toLowerCase());
  }
  
  bool _hasGoodRhythm(WordPair pair) {
    return (pair.first.length - pair.second.length).abs() <= 2;
  }
}

/// 带评分的词对类
class _ScoredWordPair {
  final WordPair wordPair;
  final int score;
  
  _ScoredWordPair(this.wordPair, this.score);
}