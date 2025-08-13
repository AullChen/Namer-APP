class DynamicLengthService {
  /// 根据提示词内容动态确定名称长度
  static String determineLengthCategory(String prompt) {
    // 分析提示词的复杂度和内容
    int complexity = _analyzeComplexity(prompt);
    List<String> keywords = _extractKeywords(prompt);
    
    // 根据复杂度和关键词数量决定长度
    if (complexity >= 8 || keywords.length >= 4) {
      return 'long'; // 长名称：4-6个词
    } else if (complexity >= 5 || keywords.length >= 2) {
      return 'medium'; // 中等名称：2-3个词
    } else {
      return 'short'; // 短名称：1-2个词
    }
  }

  /// 获取指定长度类别的词数范围
  static Map<String, int> getLengthRange(String lengthCategory) {
    switch (lengthCategory) {
      case 'short':
        return {'min': 1, 'max': 2};
      case 'medium':
        return {'min': 2, 'max': 3};
      case 'long':
        return {'min': 3, 'max': 5};
      default:
        return {'min': 2, 'max': 3};
    }
  }

  /// 分析提示词复杂度
  static int _analyzeComplexity(String prompt) {
    int complexity = 0;
    
    // 基础长度评分
    complexity += (prompt.length / 10).round();
    
    // 技术词汇加分
    if (_containsTechnicalTerms(prompt)) complexity += 3;
    
    // 专业领域词汇加分
    if (_containsProfessionalTerms(prompt)) complexity += 2;
    
    // 情感描述词汇加分
    if (_containsEmotionalTerms(prompt)) complexity += 2;
    
    // 时间相关词汇加分
    if (_containsTimeRelatedTerms(prompt)) complexity += 1;
    
    // 复合概念加分
    if (_containsCompoundConcepts(prompt)) complexity += 3;
    
    // 创新概念加分
    if (_containsInnovativeConcepts(prompt)) complexity += 4;
    
    return complexity;
  }

  /// 提取关键词
  static List<String> _extractKeywords(String prompt) {
    // 移除停用词并提取关键词
    List<String> stopWords = [
      '的', '是', '在', '有', '和', '与', '或', '但', '然而', '因为', '所以',
      'the', 'is', 'in', 'and', 'or', 'but', 'with', 'for', 'to', 'of'
    ];
    
    List<String> words = prompt
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2 && !stopWords.contains(word))
        .toList();
    
    return words;
  }

  /// 检测技术术语
  static bool _containsTechnicalTerms(String prompt) {
    List<String> techTerms = [
      'ai', 'artificial intelligence', '人工智能', 'machine learning', '机器学习',
      'blockchain', '区块链', 'cloud', '云计算', 'iot', '物联网', 'vr', 'ar',
      'algorithm', '算法', 'data', '数据', 'api', 'sdk', 'framework', '框架'
    ];
    
    String lowerPrompt = prompt.toLowerCase();
    return techTerms.any((term) => lowerPrompt.contains(term));
  }

  /// 检测专业术语
  static bool _containsProfessionalTerms(String prompt) {
    List<String> professionalTerms = [
      'business', '商业', 'enterprise', '企业', 'corporate', '公司',
      'finance', '金融', 'marketing', '营销', 'strategy', '策略',
      'management', '管理', 'consulting', '咨询', 'solution', '解决方案'
    ];
    
    String lowerPrompt = prompt.toLowerCase();
    return professionalTerms.any((term) => lowerPrompt.contains(term));
  }

  /// 检测情感术语
  static bool _containsEmotionalTerms(String prompt) {
    List<String> emotionalTerms = [
      'love', '爱', 'passion', '激情', 'dream', '梦想', 'hope', '希望',
      'joy', '快乐', 'peace', '和平', 'power', '力量', 'energy', '能量',
      'inspire', '激励', 'creative', '创意', 'beautiful', '美丽'
    ];
    
    String lowerPrompt = prompt.toLowerCase();
    return emotionalTerms.any((term) => lowerPrompt.contains(term));
  }

  /// 检测时间相关术语
  static bool _containsTimeRelatedTerms(String prompt) {
    List<String> timeTerms = [
      'future', '未来', 'modern', '现代', 'next', '下一代', 'new', '新',
      'innovative', '创新', 'advanced', '先进', 'cutting-edge', '前沿',
      'traditional', '传统', 'classic', '经典', 'vintage', '复古'
    ];
    
    String lowerPrompt = prompt.toLowerCase();
    return timeTerms.any((term) => lowerPrompt.contains(term));
  }

  /// 检测复合概念
  static bool _containsCompoundConcepts(String prompt) {
    // 检测是否包含多个不同领域的概念
    bool hasTech = _containsTechnicalTerms(prompt);
    bool hasBusiness = _containsProfessionalTerms(prompt);
    bool hasEmotion = _containsEmotionalTerms(prompt);
    
    int conceptCount = [hasTech, hasBusiness, hasEmotion].where((x) => x).length;
    return conceptCount >= 2;
  }

  /// 检测创新概念
  static bool _containsInnovativeConcepts(String prompt) {
    List<String> innovativeTerms = [
      'revolutionary', '革命性', 'breakthrough', '突破', 'disruptive', '颠覆',
      'pioneering', '开创性', 'groundbreaking', '开创性', 'cutting-edge', '前沿',
      'next-generation', '下一代', 'futuristic', '未来主义', 'visionary', '有远见'
    ];
    
    String lowerPrompt = prompt.toLowerCase();
    return innovativeTerms.any((term) => lowerPrompt.contains(term));
  }

  /// 根据长度类别生成建议的词数
  static int suggestWordCount(String lengthCategory, String prompt) {
    Map<String, int> range = getLengthRange(lengthCategory);
    int complexity = _analyzeComplexity(prompt);
    
    // 根据复杂度在范围内选择具体词数
    if (complexity >= 10) {
      return range['max']!;
    } else if (complexity >= 6) {
      return ((range['min']! + range['max']!) / 2).round();
    } else {
      return range['min']!;
    }
  }

  /// 获取长度类别的描述
  static String getLengthDescription(String lengthCategory) {
    switch (lengthCategory) {
      case 'short':
        return '简短精炼 (1-2词)';
      case 'medium':
        return '适中平衡 (2-3词)';
      case 'long':
        return '详细描述 (3-5词)';
      default:
        return '自动调整';
    }
  }

  /// 验证生成的名称是否符合长度要求
  static bool validateLength(String name, String expectedCategory) {
    List<String> words = name.split(RegExp(r'[\s_\-\.]+'));
    int wordCount = words.where((word) => word.isNotEmpty).length;
    
    Map<String, int> range = getLengthRange(expectedCategory);
    return wordCount >= range['min']! && wordCount <= range['max']!;
  }
}