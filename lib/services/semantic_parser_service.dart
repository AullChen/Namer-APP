import 'dart:math' as math;

/// 语义解析服务
/// 实现整句语义解析功能和时效信息处理
class SemanticParserService {
  static final SemanticParserService _instance = SemanticParserService._internal();
  factory SemanticParserService() => _instance;
  SemanticParserService._internal();

  // 语义词典
  final Map<String, List<String>> _semanticDictionary = {
    // 科技类
    '科技': ['tech', 'digital', 'smart', 'cyber', 'nano', 'quantum', 'ai', 'cloud'],
    '人工智能': ['ai', 'neural', 'deep', 'machine', 'cognitive', 'intelligent', 'auto'],
    '区块链': ['block', 'chain', 'crypto', 'defi', 'token', 'hash', 'ledger'],
    '物联网': ['iot', 'connected', 'smart', 'sensor', 'mesh', 'edge', 'wireless'],
    
    // 商业类
    '商业': ['business', 'enterprise', 'corporate', 'commercial', 'trade', 'market'],
    '创业': ['startup', 'venture', 'launch', 'pioneer', 'innovate', 'disrupt'],
    '金融': ['finance', 'capital', 'invest', 'fund', 'asset', 'wealth', 'profit'],
    '电商': ['ecommerce', 'retail', 'shop', 'store', 'marketplace', 'platform'],
    
    // 创意类
    '创意': ['creative', 'artistic', 'design', 'inspire', 'imagine', 'vision'],
    '艺术': ['art', 'aesthetic', 'beauty', 'elegant', 'style', 'craft', 'studio'],
    '音乐': ['music', 'sound', 'rhythm', 'melody', 'harmony', 'beat', 'tune'],
    '游戏': ['game', 'play', 'quest', 'adventure', 'hero', 'legend', 'epic'],
    
    // 自然类
    '自然': ['nature', 'eco', 'green', 'earth', 'forest', 'ocean', 'sky'],
    '动物': ['animal', 'wild', 'creature', 'beast', 'fauna', 'species'],
    '植物': ['plant', 'flora', 'bloom', 'garden', 'leaf', 'root', 'seed'],
    '天空': ['sky', 'cloud', 'star', 'moon', 'sun', 'cosmic', 'celestial'],
    
    // 情感类
    '快乐': ['happy', 'joy', 'bright', 'sunny', 'cheerful', 'positive', 'smile'],
    '平静': ['calm', 'peace', 'serene', 'tranquil', 'zen', 'harmony', 'balance'],
    '力量': ['power', 'strong', 'mighty', 'force', 'energy', 'dynamic', 'robust'],
    '优雅': ['elegant', 'graceful', 'refined', 'sophisticated', 'classy', 'noble'],
  };

  // 时效关键词
  final Map<String, List<String>> _timeBasedKeywords = {
    '2024': ['meta', 'ai', 'chatgpt', 'blockchain', 'nft', 'defi', 'web3'],
    '2025': ['quantum', 'neural', 'autonomous', 'sustainable', 'carbon', 'green'],
    '流行': ['viral', 'trending', 'hot', 'buzz', 'hype', 'popular', 'cool'],
    '新兴': ['emerging', 'next', 'future', 'innovative', 'cutting', 'edge', 'novel'],
    '经典': ['classic', 'timeless', 'traditional', 'vintage', 'retro', 'heritage'],
  };

  // 网络流行语映射
  final Map<String, List<String>> _internetSlangMapping = {
    '卷': ['competitive', 'intense', 'grind', 'hustle', 'strive'],
    '躺平': ['chill', 'relax', 'easy', 'simple', 'minimal', 'zen'],
    '内卷': ['intense', 'competitive', 'pressure', 'stress', 'grind'],
    '摆烂': ['casual', 'free', 'loose', 'random', 'wild', 'chaos'],
    '破防': ['breakthrough', 'impact', 'shock', 'surprise', 'wow'],
    '绝绝子': ['amazing', 'awesome', 'fantastic', 'incredible', 'super'],
    'yyds': ['legend', 'eternal', 'forever', 'ultimate', 'supreme'],
    '芭比q': ['barbecue', 'fire', 'hot', 'spicy', 'intense', 'wild'],
    '栓q': ['thanks', 'grateful', 'appreciate', 'kind', 'sweet'],
    '淦': ['power', 'energy', 'force', 'drive', 'push', 'go'],
  };

  // 情感强度词汇
  final Map<String, double> _emotionIntensity = {
    '非常': 0.9,
    '超级': 0.95,
    '极其': 0.98,
    '特别': 0.8,
    '很': 0.7,
    '比较': 0.6,
    '稍微': 0.4,
    '有点': 0.3,
  };

  /// 解析用户输入的语义信息
  SemanticAnalysisResult parseSemantics(String input) {
    if (input.trim().isEmpty) {
      return SemanticAnalysisResult.empty();
    }

    final result = SemanticAnalysisResult();
    
    // 1. 识别主要语义类别
    _identifySemanticCategories(input, result);
    
    // 2. 处理时效信息
    _processTimeBasedInfo(input, result);
    
    // 3. 处理网络流行语
    _processInternetSlang(input, result);
    
    // 4. 分析情感强度
    _analyzeEmotionIntensity(input, result);
    
    // 5. 提取关键词
    _extractKeywords(input, result);
    
    // 6. 生成语义权重
    _calculateSemanticWeights(result);
    
    return result;
  }

  void _identifySemanticCategories(String input, SemanticAnalysisResult result) {
    for (final entry in _semanticDictionary.entries) {
      if (input.contains(entry.key)) {
        result.categories.add(entry.key);
        result.relatedWords.addAll(entry.value);
        result.confidence += 0.2;
      }
    }
  }

  void _processTimeBasedInfo(String input, SemanticAnalysisResult result) {
    final now = DateTime.now();
    
    // 检查年份相关
    if (input.contains('${now.year}') || input.contains('今年')) {
      result.timeContext = 'current';
      result.relatedWords.addAll(_timeBasedKeywords['${now.year}'] ?? []);
      result.confidence += 0.15;
    }
    
    // 检查流行趋势
    for (final entry in _timeBasedKeywords.entries) {
      if (input.contains(entry.key)) {
        result.timeContext = entry.key;
        result.relatedWords.addAll(entry.value);
        result.confidence += 0.1;
      }
    }
    
    // 季节性检测
    final month = now.month;
    if (input.contains('春') || (month >= 3 && month <= 5)) {
      result.relatedWords.addAll(['spring', 'fresh', 'bloom', 'new', 'growth']);
    } else if (input.contains('夏') || (month >= 6 && month <= 8)) {
      result.relatedWords.addAll(['summer', 'hot', 'bright', 'energy', 'active']);
    } else if (input.contains('秋') || (month >= 9 && month <= 11)) {
      result.relatedWords.addAll(['autumn', 'harvest', 'golden', 'mature', 'wise']);
    } else if (input.contains('冬') || (month == 12 || month <= 2)) {
      result.relatedWords.addAll(['winter', 'cool', 'calm', 'pure', 'crystal']);
    }
  }

  void _processInternetSlang(String input, SemanticAnalysisResult result) {
    for (final entry in _internetSlangMapping.entries) {
      if (input.contains(entry.key)) {
        result.internetSlang.add(entry.key);
        result.relatedWords.addAll(entry.value);
        result.confidence += 0.25; // 网络流行语权重较高
      }
    }
  }

  void _analyzeEmotionIntensity(String input, SemanticAnalysisResult result) {
    double maxIntensity = 0.5; // 默认中等强度
    
    for (final entry in _emotionIntensity.entries) {
      if (input.contains(entry.key)) {
        maxIntensity = math.max(maxIntensity, entry.value);
      }
    }
    
    result.emotionIntensity = maxIntensity;
    result.confidence += maxIntensity * 0.1;
  }

  void _extractKeywords(String input, SemanticAnalysisResult result) {
    // 简单的关键词提取（实际应用中可以使用更复杂的NLP算法）
    final words = input.split(RegExp(r'[\s，。！？、]+'))
        .where((word) => word.length > 1)
        .toList();
    
    result.keywords.addAll(words);
  }

  void _calculateSemanticWeights(SemanticAnalysisResult result) {
    // 根据分析结果计算各维度权重
    result.weights = {
      'creativity': _calculateCreativityWeight(result),
      'technology': _calculateTechnologyWeight(result),
      'business': _calculateBusinessWeight(result),
      'nature': _calculateNatureWeight(result),
      'emotion': result.emotionIntensity,
      'trending': _calculateTrendingWeight(result),
    };
  }

  double _calculateCreativityWeight(SemanticAnalysisResult result) {
    double weight = 0.3; // 基础权重
    
    if (result.categories.any((cat) => ['创意', '艺术', '音乐', '游戏'].contains(cat))) {
      weight += 0.4;
    }
    
    if (result.internetSlang.isNotEmpty) {
      weight += 0.2;
    }
    
    return math.min(weight, 1.0);
  }

  double _calculateTechnologyWeight(SemanticAnalysisResult result) {
    double weight = 0.2;
    
    if (result.categories.any((cat) => ['科技', '人工智能', '区块链', '物联网'].contains(cat))) {
      weight += 0.5;
    }
    
    if (result.timeContext == 'current' || result.timeContext == '新兴') {
      weight += 0.2;
    }
    
    return math.min(weight, 1.0);
  }

  double _calculateBusinessWeight(SemanticAnalysisResult result) {
    double weight = 0.25;
    
    if (result.categories.any((cat) => ['商业', '创业', '金融', '电商'].contains(cat))) {
      weight += 0.4;
    }
    
    return math.min(weight, 1.0);
  }

  double _calculateNatureWeight(SemanticAnalysisResult result) {
    double weight = 0.2;
    
    if (result.categories.any((cat) => ['自然', '动物', '植物', '天空'].contains(cat))) {
      weight += 0.5;
    }
    
    return math.min(weight, 1.0);
  }

  double _calculateTrendingWeight(SemanticAnalysisResult result) {
    double weight = 0.1;
    
    if (result.timeContext == '流行' || result.internetSlang.isNotEmpty) {
      weight += 0.6;
    }
    
    if (result.timeContext == 'current') {
      weight += 0.2;
    }
    
    return math.min(weight, 1.0);
  }

  /// 生成基于语义分析的建议词汇
  List<String> generateSuggestions(SemanticAnalysisResult analysis) {
    final suggestions = <String>[];
    
    // 基于分类添加建议
    for (final category in analysis.categories) {
      final words = _semanticDictionary[category];
      if (words != null) {
        suggestions.addAll(words.take(3));
      }
    }
    
    // 基于时效信息添加建议
    if (analysis.timeContext.isNotEmpty) {
      final timeWords = _timeBasedKeywords[analysis.timeContext];
      if (timeWords != null) {
        suggestions.addAll(timeWords.take(2));
      }
    }
    
    // 基于网络流行语添加建议
    for (final slang in analysis.internetSlang) {
      final words = _internetSlangMapping[slang];
      if (words != null) {
        suggestions.addAll(words.take(2));
      }
    }
    
    // 去重并限制数量
    return suggestions.toSet().take(10).toList();
  }
}

/// 语义分析结果
class SemanticAnalysisResult {
  List<String> categories = [];
  List<String> keywords = [];
  List<String> relatedWords = [];
  List<String> internetSlang = [];
  String timeContext = '';
  double emotionIntensity = 0.5;
  double confidence = 0.0;
  Map<String, double> weights = {};

  SemanticAnalysisResult();
  
  factory SemanticAnalysisResult.empty() {
    return SemanticAnalysisResult();
  }

  bool get isEmpty => categories.isEmpty && keywords.isEmpty && relatedWords.isEmpty;
  
  bool get isValid => confidence > 0.3;
  
  @override
  String toString() {
    return 'SemanticAnalysisResult(categories: $categories, confidence: $confidence, weights: $weights)';
  }
}