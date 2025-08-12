import 'dart:math' as math;

/// AI模型配置类
/// 包含用于名称生成的机器学习参数和配置
class AIModelConfig {
  // 语义向量权重 - 用于计算词汇语义相似度
  static const Map<String, Map<String, double>> semanticVectors = {
    'technology': {
      'innovation': 0.9,
      'digital': 0.8,
      'smart': 0.7,
      'future': 0.6,
      'advanced': 0.5,
    },
    'business': {
      'professional': 0.9,
      'corporate': 0.8,
      'success': 0.7,
      'growth': 0.6,
      'strategic': 0.5,
    },
    'creative': {
      'artistic': 0.9,
      'imaginative': 0.8,
      'original': 0.7,
      'inspired': 0.6,
      'visionary': 0.5,
    },
    'nature': {
      'organic': 0.9,
      'natural': 0.8,
      'green': 0.7,
      'earth': 0.6,
      'pure': 0.5,
    },
  };

  // 音韵模式权重 - 用于评估名称的音韵美感
  static const Map<String, double> phoneticWeights = {
    'alliteration': 0.3,      // 头韵
    'assonance': 0.2,         // 元音韵
    'consonance': 0.2,        // 辅音韵
    'rhythm': 0.3,            // 节奏感
  };

  // 长度偏好权重矩阵
  static const Map<String, Map<int, double>> lengthPreferenceMatrix = {
    'short': {
      4: 1.0, 5: 0.9, 6: 0.8, 7: 0.7, 8: 0.6,
      9: 0.4, 10: 0.2, 11: 0.1, 12: 0.05,
    },
    'medium': {
      6: 0.5, 7: 0.7, 8: 0.9, 9: 1.0, 10: 1.0,
      11: 1.0, 12: 0.9, 13: 0.7, 14: 0.5, 15: 0.3,
    },
    'long': {
      10: 0.3, 11: 0.5, 12: 0.7, 13: 0.9, 14: 1.0,
      15: 1.0, 16: 0.9, 17: 0.8, 18: 0.7, 19: 0.6, 20: 0.5,
    },
  };

  // 风格特征权重
  static const Map<String, Map<String, double>> styleFeatureWeights = {
    'classic': {
      'commonality': 0.4,      // 常见度
      'tradition': 0.3,        // 传统性
      'simplicity': 0.3,       // 简洁性
    },
    'modern': {
      'balance': 0.3,          // 平衡性
      'innovation': 0.3,       // 创新性
      'readability': 0.4,      // 可读性
    },
    'futuristic': {
      'uniqueness': 0.4,       // 独特性
      'techAppeal': 0.3,       // 科技感
      'novelty': 0.3,          // 新颖性
    },
  };

  // 上下文理解权重
  static const Map<String, double> contextualWeights = {
    'directMatch': 0.4,       // 直接匹配
    'semanticSimilarity': 0.3, // 语义相似度
    'phoneticSimilarity': 0.2, // 音韵相似度
    'characterSimilarity': 0.1, // 字符相似度
  };

  // 学习率参数 - 用于用户偏好学习
  static const double learningRate = 0.1;
  static const double decayRate = 0.95;
  static const int maxHistorySize = 100;

  // 多样性参数 - 确保生成结果的多样性
  static const double diversityThreshold = 0.7;
  static const int maxSimilarResults = 2;

  // 质量阈值 - 过滤低质量结果
  static const int minQualityScore = 5;
  static const int maxQualityScore = 50;

  // 神经网络模拟参数
  static const Map<String, double> neuralNetworkWeights = {
    'inputLayer': 1.0,
    'hiddenLayer1': 0.8,
    'hiddenLayer2': 0.6,
    'outputLayer': 1.0,
  };

  // 激活函数参数
  static const double sigmoidBeta = 1.0;
  static const double reluAlpha = 0.01;

  /// 获取语义相似度权重
  static double getSemanticWeight(String category, String concept) {
    return semanticVectors[category]?[concept] ?? 0.0;
  }

  /// 获取音韵权重
  static double getPhoneticWeight(String pattern) {
    return phoneticWeights[pattern] ?? 0.0;
  }

  /// 获取长度偏好权重
  static double getLengthWeight(String preference, int length) {
    return lengthPreferenceMatrix[preference]?[length] ?? 0.0;
  }

  /// 获取风格特征权重
  static double getStyleWeight(String style, String feature) {
    return styleFeatureWeights[style]?[feature] ?? 0.0;
  }

  /// 获取上下文权重
  static double getContextualWeight(String context) {
    return contextualWeights[context] ?? 0.0;
  }

  /// Sigmoid激活函数
  static double sigmoid(double x) {
    return 1.0 / (1.0 + math.exp(-sigmoidBeta * x));
  }

  /// ReLU激活函数
  static double relu(double x) {
    return x > 0 ? x : reluAlpha * x;
  }

  /// 标准化分数
  static double normalizeScore(double score, double min, double max) {
    if (max == min) return 0.5;
    return (score - min) / (max - min);
  }
}