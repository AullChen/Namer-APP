import 'dart:math';
import 'web_query_service.dart';
import 'dynamic_length_service.dart';

class AdvancedAIService {
  static final Random _random = Random();
  
  /// 使用先进AI模型生成高质量名称
  static Future<List<String>> generateAdvancedNames({
    required String prompt,
    required int count,
    String format = 'default',
    String lengthCategory = 'auto',
  }) async {
    try {
      // 1. 语义分析和理解
      Map<String, dynamic> semanticAnalysis = await _analyzeSemantics(prompt);
      
      // 2. 动态长度确定
      String actualLengthCategory = lengthCategory == 'auto' 
          ? DynamicLengthService.determineLengthCategory(prompt)
          : lengthCategory;
      
      // 3. 网络趋势整合
      Map<String, dynamic> trendData = await WebQueryService.queryEmergingConcepts(prompt);
      
      // 4. 创意生成引擎
      List<String> candidates = await _generateCreativeCandidates(
        semanticAnalysis, 
        trendData, 
        actualLengthCategory,
        count * 3 // 生成更多候选项用于筛选
      );
      
      // 5. 质量评估和排序
      List<ScoredName> scoredNames = await _scoreAndRankNames(candidates, semanticAnalysis);
      
      // 6. 多样性优化
      List<String> diversifiedNames = _ensureDiversity(scoredNames, count);
      
      return diversifiedNames;
    } catch (e) {
      // 降级到基础生成方法
      return _generateFallbackNames(prompt, count);
    }
  }

  /// 语义分析
  static Future<Map<String, dynamic>> _analyzeSemantics(String prompt) async {
    return {
      'intent': _extractIntent(prompt),
      'emotions': _extractEmotions(prompt),
      'concepts': _extractConcepts(prompt),
      'style': _determineStyle(prompt),
      'complexity': _calculateComplexity(prompt),
      'domain': _identifyDomain(prompt),
    };
  }

  /// 创意候选生成
  static Future<List<String>> _generateCreativeCandidates(
    Map<String, dynamic> semantics,
    Map<String, dynamic> trends,
    String lengthCategory,
    int count,
  ) async {
    List<String> candidates = [];
    
    // 基于语义的生成
    candidates.addAll(_generateSemanticNames(semantics, count ~/ 4));
    
    // 基于趋势的生成
    candidates.addAll(_generateTrendNames(trends, count ~/ 4));
    
    // 创意组合生成
    candidates.addAll(_generateCreativeCombinations(semantics, trends, count ~/ 4));
    
    // 长度优化生成
    candidates.addAll(_generateLengthOptimizedNames(semantics, lengthCategory, count ~/ 4));
    
    return candidates;
  }

  /// 名称评分和排序
  static Future<List<ScoredName>> _scoreAndRankNames(
    List<String> candidates, 
    Map<String, dynamic> semantics
  ) async {
    List<ScoredName> scoredNames = [];
    
    for (String name in candidates) {
      double score = await _calculateNameScore(name, semantics);
      scoredNames.add(ScoredName(name, score));
    }
    
    // 按分数降序排序
    scoredNames.sort((a, b) => b.score.compareTo(a.score));
    return scoredNames;
  }

  /// 计算名称综合评分
  static Future<double> _calculateNameScore(String name, Map<String, dynamic> semantics) async {
    double score = 0.0;
    
    // 语义匹配度 (30%)
    score += _calculateSemanticMatch(name, semantics) * 0.3;
    
    // 创意度 (25%)
    score += _calculateCreativity(name) * 0.25;
    
    // 记忆度 (20%)
    score += _calculateMemorability(name) * 0.2;
    
    // 发音友好度 (15%)
    score += _calculatePronunciationScore(name) * 0.15;
    
    // 独特性 (10%)
    score += _calculateUniqueness(name) * 0.1;
    
    return score.clamp(0.0, 1.0);
  }

  /// 确保多样性
  static List<String> _ensureDiversity(List<ScoredName> scoredNames, int count) {
    List<String> result = [];
    Set<String> usedPatterns = {};
    
    for (ScoredName scoredName in scoredNames) {
      if (result.length >= count) break;
      
      String pattern = _extractPattern(scoredName.name);
      if (!usedPatterns.contains(pattern) || usedPatterns.length < count ~/ 2) {
        result.add(scoredName.name);
        usedPatterns.add(pattern);
      }
    }
    
    return result;
  }

  // 辅助方法实现
  static String _extractIntent(String prompt) {
    if (prompt.contains('公司') || prompt.contains('企业')) return 'business';
    if (prompt.contains('产品') || prompt.contains('应用')) return 'product';
    if (prompt.contains('项目') || prompt.contains('方案')) return 'project';
    if (prompt.contains('品牌') || prompt.contains('商标')) return 'brand';
    return 'general';
  }

  static List<String> _extractEmotions(String prompt) {
    List<String> emotions = [];
    Map<String, String> emotionMap = {
      '激情': 'passion', '创新': 'innovation', '稳定': 'stability',
      '活力': 'energy', '专业': 'professional', '友好': 'friendly',
      '高端': 'premium', '简约': 'minimal', '温暖': 'warm'
    };
    
    emotionMap.forEach((chinese, english) {
      if (prompt.contains(chinese)) emotions.add(english);
    });
    
    return emotions.isEmpty ? ['neutral'] : emotions;
  }

  static List<String> _extractConcepts(String prompt) {
    List<String> concepts = [];
    List<String> conceptKeywords = [
      '科技', '智能', '数字', '云端', '未来', '创新', '专业', '高效',
      '安全', '绿色', '环保', '健康', '教育', '娱乐', '社交', '商务'
    ];
    
    for (String keyword in conceptKeywords) {
      if (prompt.contains(keyword)) concepts.add(keyword);
    }
    
    return concepts;
  }

  static String _determineStyle(String prompt) {
    if (prompt.contains('简约') || prompt.contains('极简')) return 'minimal';
    if (prompt.contains('现代') || prompt.contains('时尚')) return 'modern';
    if (prompt.contains('经典') || prompt.contains('传统')) return 'classic';
    if (prompt.contains('创意') || prompt.contains('艺术')) return 'creative';
    return 'balanced';
  }

  static int _calculateComplexity(String prompt) {
    int complexity = prompt.length ~/ 10;
    complexity += prompt.split(' ').length;
    complexity += RegExp(r'[，。！？；：]').allMatches(prompt).length;
    return complexity;
  }

  static String _identifyDomain(String prompt) {
    Map<String, List<String>> domainKeywords = {
      'tech': ['科技', '技术', 'AI', '智能', '数字', '云', '算法'],
      'business': ['商业', '企业', '公司', '市场', '销售', '管理'],
      'creative': ['创意', '设计', '艺术', '美学', '视觉', '品牌'],
      'health': ['健康', '医疗', '养生', '运动', '营养', '康复'],
      'education': ['教育', '学习', '培训', '知识', '技能', '课程'],
    };
    
    String lowerPrompt = prompt.toLowerCase();
    for (String domain in domainKeywords.keys) {
      if (domainKeywords[domain]!.any((keyword) => lowerPrompt.contains(keyword.toLowerCase()))) {
        return domain;
      }
    }
    return 'general';
  }

  static List<String> _generateSemanticNames(Map<String, dynamic> semantics, int count) {
    List<String> names = [];
    List<String> concepts = semantics['concepts'] ?? [];
    String style = semantics['style'] ?? 'balanced';
    
    for (int i = 0; i < count; i++) {
      String name = _combineSemanticElements(concepts, style);
      if (name.isNotEmpty) names.add(name);
    }
    
    return names;
  }

  static List<String> _generateTrendNames(Map<String, dynamic> trends, int count) {
    List<String> names = [];
    List<String> trendTerms = trends['relatedTerms'] ?? [];
    
    for (int i = 0; i < count && i < trendTerms.length; i++) {
      names.add(trendTerms[i] + _getRandomSuffix());
    }
    
    return names;
  }

  static List<String> _generateCreativeCombinations(
    Map<String, dynamic> semantics, 
    Map<String, dynamic> trends, 
    int count
  ) {
    List<String> names = [];
    List<String> concepts = semantics['concepts'] ?? [];
    List<String> trendTerms = trends['relatedTerms'] ?? [];
    
    for (int i = 0; i < count; i++) {
      if (concepts.isNotEmpty && trendTerms.isNotEmpty) {
        String concept = concepts[_random.nextInt(concepts.length)];
        String trend = trendTerms[_random.nextInt(trendTerms.length)];
        names.add('$concept$trend');
      }
    }
    
    return names;
  }

  static List<String> _generateLengthOptimizedNames(
    Map<String, dynamic> semantics, 
    String lengthCategory, 
    int count
  ) {
    List<String> names = [];
    Map<String, int> lengthRange = DynamicLengthService.getLengthRange(lengthCategory);
    
    for (int i = 0; i < count; i++) {
      int targetWords = _random.nextInt(lengthRange['max']! - lengthRange['min']! + 1) + lengthRange['min']!;
      String name = _generateNameWithWordCount(semantics, targetWords);
      if (name.isNotEmpty) names.add(name);
    }
    
    return names;
  }

  static String _combineSemanticElements(List<String> concepts, String style) {
    if (concepts.isEmpty) return '';
    
    String base = concepts[_random.nextInt(concepts.length)];
    String modifier = _getStyleModifier(style);
    
    return base + modifier;
  }

  static String _getStyleModifier(String style) {
    Map<String, List<String>> modifiers = {
      'minimal': ['极', '简', '纯', '净'],
      'modern': ['新', '潮', '尚', '锐'],
      'classic': ['典', '雅', '韵', '华'],
      'creative': ['奇', '妙', '灵', '巧'],
      'balanced': ['优', '佳', '好', '美'],
    };
    
    List<String> styleModifiers = modifiers[style] ?? modifiers['balanced']!;
    return styleModifiers[_random.nextInt(styleModifiers.length)];
  }

  static String _getRandomSuffix() {
    List<String> suffixes = ['Pro', 'Plus', 'Max', 'Elite', 'Prime', 'Ultra', 'Smart', 'Tech'];
    return suffixes[_random.nextInt(suffixes.length)];
  }

  static String _generateNameWithWordCount(Map<String, dynamic> semantics, int wordCount) {
    List<String> concepts = semantics['concepts'] ?? ['智能', '创新', '未来'];
    List<String> words = [];
    
    for (int i = 0; i < wordCount && i < concepts.length; i++) {
      words.add(concepts[i]);
    }
    
    return words.join('');
  }

  static double _calculateSemanticMatch(String name, Map<String, dynamic> semantics) {
    List<String> concepts = semantics['concepts'] ?? [];
    double match = 0.0;
    
    for (String concept in concepts) {
      if (name.toLowerCase().contains(concept.toLowerCase())) {
        match += 0.2;
      }
    }
    
    return match.clamp(0.0, 1.0);
  }

  static double _calculateCreativity(String name) {
    // 基于名称的独特性和组合方式评估创意度
    double creativity = 0.5;
    
    // 长度适中加分
    if (name.length >= 4 && name.length <= 12) creativity += 0.2;
    
    // 包含数字或特殊组合加分
    if (RegExp(r'[0-9]').hasMatch(name)) creativity += 0.1;
    
    // 中英文混合加分
    if (RegExp(r'[a-zA-Z]').hasMatch(name) && RegExp(r'[\u4e00-\u9fa5]').hasMatch(name)) {
      creativity += 0.2;
    }
    
    return creativity.clamp(0.0, 1.0);
  }

  static double _calculateMemorability(String name) {
    double memorability = 0.5;
    
    // 长度适中更容易记忆
    if (name.length >= 3 && name.length <= 8) memorability += 0.3;
    
    // 有韵律感加分
    if (_hasRhythm(name)) memorability += 0.2;
    
    return memorability.clamp(0.0, 1.0);
  }

  static double _calculatePronunciationScore(String name) {
    // 简化的发音友好度评估
    double score = 0.7;
    
    // 避免连续的辅音
    if (!RegExp(r'[bcdfghjklmnpqrstvwxyz]{3,}', caseSensitive: false).hasMatch(name)) {
      score += 0.2;
    }
    
    // 长度适中
    if (name.length <= 10) score += 0.1;
    
    return score.clamp(0.0, 1.0);
  }

  static double _calculateUniqueness(String name) {
    // 基于名称的罕见程度评估独特性
    double uniqueness = 0.6;
    
    // 包含不常见的组合
    if (name.length >= 6) uniqueness += 0.2;
    
    // 创新的词汇组合
    if (_hasInnovativeCombination(name)) uniqueness += 0.2;
    
    return uniqueness.clamp(0.0, 1.0);
  }

  static String _extractPattern(String name) {
    // 提取名称的模式用于多样性检查
    if (RegExp(r'^[a-zA-Z]+$').hasMatch(name)) return 'english';
    if (RegExp(r'^[\u4e00-\u9fa5]+$').hasMatch(name)) return 'chinese';
    if (RegExp(r'[a-zA-Z].*[\u4e00-\u9fa5]|[\u4e00-\u9fa5].*[a-zA-Z]').hasMatch(name)) return 'mixed';
    return 'other';
  }

  static bool _hasRhythm(String name) {
    // 简化的韵律检测
    return name.length % 2 == 0 || RegExp(r'(.)\1').hasMatch(name);
  }

  static bool _hasInnovativeCombination(String name) {
    // 检测创新的词汇组合
    return RegExp(r'[A-Z][a-z]+[A-Z]').hasMatch(name) || 
           name.contains('智') && name.contains('Tech');
  }

  static List<String> _generateFallbackNames(String prompt, int count) {
    List<String> fallbackNames = [];
    List<String> baseWords = ['智能', '创新', '未来', '科技', '数字'];
    List<String> suffixes = ['Pro', 'Plus', 'Smart', 'Tech', 'Lab'];
    
    for (int i = 0; i < count; i++) {
      String base = baseWords[_random.nextInt(baseWords.length)];
      String suffix = suffixes[_random.nextInt(suffixes.length)];
      fallbackNames.add('$base$suffix');
    }
    
    return fallbackNames;
  }
}

/// 评分名称类
class ScoredName {
  final String name;
  final double score;
  
  ScoredName(this.name, this.score);
}