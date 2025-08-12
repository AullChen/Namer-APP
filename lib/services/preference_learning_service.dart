import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/word_pair_model.dart';
import 'package:flutter_application_1/services/ai_model_config.dart';

/// 用户偏好学习服务
/// 基于用户行为数据学习和优化名称生成偏好
class PreferenceLearningService {
  static const String _userHistoryKey = 'user_history';
  static const String _learnedPreferencesKey = 'learned_preferences';
  
  /// 用户行为记录
  Future<void> recordUserAction(String action, WordPairModel wordPair, {
    Map<String, dynamic>? context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 获取现有历史记录
    List<String> historyJson = prefs.getStringList(_userHistoryKey) ?? [];
    
    // 创建新的行为记录
    Map<String, dynamic> actionRecord = {
      'timestamp': DateTime.now().toIso8601String(),
      'action': action, // 'favorite', 'skip', 'generate', 'search'
      'wordPair': wordPair.toJson(),
      'context': context ?? {},
    };
    
    // 添加到历史记录
    historyJson.add(jsonEncode(actionRecord));
    
    // 限制历史记录大小
    if (historyJson.length > AIModelConfig.maxHistorySize) {
      historyJson = historyJson.sublist(historyJson.length - AIModelConfig.maxHistorySize);
    }
    
    // 保存历史记录
    await prefs.setStringList(_userHistoryKey, historyJson);
    
    // 更新学习到的偏好
    await _updateLearnedPreferences();
  }
  
  /// 获取用户历史记录
  Future<List<Map<String, dynamic>>> getUserHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyJson = prefs.getStringList(_userHistoryKey) ?? [];
    
    return historyJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }
  
  /// 获取学习到的偏好
  Future<Map<String, dynamic>> getLearnedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? preferencesJson = prefs.getString(_learnedPreferencesKey);
    
    if (preferencesJson == null) {
      return _getDefaultLearnedPreferences();
    }
    
    return jsonDecode(preferencesJson);
  }
  
  /// 更新学习到的偏好
  Future<void> _updateLearnedPreferences() async {
    final history = await getUserHistory();
    
    if (history.isEmpty) return;
    
    // 分析用户行为模式
    Map<String, dynamic> learnedPreferences = await _analyzeUserBehavior(history);
    
    // 保存学习到的偏好
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_learnedPreferencesKey, jsonEncode(learnedPreferences));
  }
  
  /// 分析用户行为模式
  Future<Map<String, dynamic>> _analyzeUserBehavior(List<Map<String, dynamic>> history) async {
    Map<String, dynamic> preferences = _getDefaultLearnedPreferences();
    
    // 分析收藏的名称特征
    List<Map<String, dynamic>> favoriteActions = history
        .where((action) => action['action'] == 'favorite')
        .toList();
    
    if (favoriteActions.isNotEmpty) {
      // 分析长度偏好
      preferences['lengthPreference'] = _analyzeLengthPreference(favoriteActions);
      
      // 分析风格偏好
      preferences['stylePreference'] = _analyzeStylePreference(favoriteActions);
      
      // 分析音韵偏好
      preferences['phoneticPreference'] = _analyzePhoneticPreference(favoriteActions);
      
      // 分析语义偏好
      preferences['semanticPreference'] = _analyzeSemanticPreference(favoriteActions);
      
      // 分析时间模式
      preferences['timePattern'] = _analyzeTimePattern(favoriteActions);
    }
    
    // 分析跳过的名称特征（负面偏好）
    List<Map<String, dynamic>> skipActions = history
        .where((action) => action['action'] == 'skip')
        .toList();
    
    if (skipActions.isNotEmpty) {
      preferences['avoidancePatterns'] = _analyzeAvoidancePatterns(skipActions);
    }
    
    return preferences;
  }
  
  /// 分析长度偏好
  Map<String, dynamic> _analyzeLengthPreference(List<Map<String, dynamic>> favoriteActions) {
    List<int> lengths = [];
    
    for (var action in favoriteActions) {
      var wordPair = WordPairModel.fromJson(action['wordPair']);
      int totalLength = wordPair.wordPair.first.length + wordPair.wordPair.second.length;
      lengths.add(totalLength);
    }
    
    if (lengths.isEmpty) return {'preferred': 'medium', 'confidence': 0.0};
    
    // 计算平均长度和标准差
    double avgLength = lengths.reduce((a, b) => a + b) / lengths.length;
    double variance = lengths.map((l) => (l - avgLength) * (l - avgLength)).reduce((a, b) => a + b) / lengths.length;
    double stdDev = math.sqrt(variance);
    
    // 确定偏好类别
    String preferred;
    if (avgLength < 10) {
      preferred = 'short';
    } else if (avgLength > 16) {
      preferred = 'long';
    } else {
      preferred = 'medium';
    }
    
    // 计算置信度
    double confidence = math.max(0.0, 1.0 - (stdDev / avgLength));
    
    return {
      'preferred': preferred,
      'averageLength': avgLength,
      'standardDeviation': stdDev,
      'confidence': confidence,
    };
  }
  
  /// 分析风格偏好
  Map<String, dynamic> _analyzeStylePreference(List<Map<String, dynamic>> favoriteActions) {
    Map<String, int> styleScores = {'classic': 0, 'modern': 0, 'futuristic': 0};
    
    for (var action in favoriteActions) {
      var wordPair = WordPairModel.fromJson(action['wordPair']);
      
      // 简化的风格分析
      if (_isClassicStyle(wordPair)) styleScores['classic'] = styleScores['classic']! + 1;
      if (_isModernStyle(wordPair)) styleScores['modern'] = styleScores['modern']! + 1;
      if (_isFuturisticStyle(wordPair)) styleScores['futuristic'] = styleScores['futuristic']! + 1;
    }
    
    // 找到最高分的风格
    String preferredStyle = styleScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    int totalActions = favoriteActions.length;
    double confidence = totalActions > 0 ? styleScores[preferredStyle]! / totalActions : 0.0;
    
    return {
      'preferred': preferredStyle,
      'scores': styleScores,
      'confidence': confidence,
    };
  }
  
  /// 分析音韵偏好
  Map<String, dynamic> _analyzePhoneticPreference(List<Map<String, dynamic>> favoriteActions) {
    int alliterationCount = 0;
    int rhythmCount = 0;
    int totalCount = favoriteActions.length;
    
    for (var action in favoriteActions) {
      var wordPair = WordPairModel.fromJson(action['wordPair']);
      
      // 检查头韵
      if (wordPair.wordPair.first.isNotEmpty && 
          wordPair.wordPair.second.isNotEmpty &&
          wordPair.wordPair.first[0].toLowerCase() == wordPair.wordPair.second[0].toLowerCase()) {
        alliterationCount++;
      }
      
      // 检查节奏感
      if ((wordPair.wordPair.first.length - wordPair.wordPair.second.length).abs() <= 2) {
        rhythmCount++;
      }
    }
    
    return {
      'alliterationPreference': totalCount > 0 ? alliterationCount / totalCount : 0.0,
      'rhythmPreference': totalCount > 0 ? rhythmCount / totalCount : 0.0,
      'confidence': totalCount >= 5 ? 0.8 : totalCount * 0.16,
    };
  }
  
  /// 分析语义偏好
  Map<String, dynamic> _analyzeSemanticPreference(List<Map<String, dynamic>> favoriteActions) {
    Map<String, int> categoryCount = {};
    
    for (var action in favoriteActions) {
      var wordPair = WordPairModel.fromJson(action['wordPair']);
      List<String> categories = wordPair.categories;
      
      for (String category in categories) {
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }
    }
    
    // 找到最常用的类别
    String? preferredCategory;
    int maxCount = 0;
    
    categoryCount.forEach((category, count) {
      if (count > maxCount) {
        maxCount = count;
        preferredCategory = category;
      }
    });
    
    double confidence = favoriteActions.isNotEmpty ? maxCount / favoriteActions.length : 0.0;
    
    return {
      'preferredCategory': preferredCategory,
      'categoryDistribution': categoryCount,
      'confidence': confidence,
    };
  }
  
  /// 分析时间模式
  Map<String, dynamic> _analyzeTimePattern(List<Map<String, dynamic>> favoriteActions) {
    Map<int, int> hourCount = {};
    Map<int, int> dayOfWeekCount = {};
    
    for (var action in favoriteActions) {
      DateTime timestamp = DateTime.parse(action['timestamp']);
      
      int hour = timestamp.hour;
      int dayOfWeek = timestamp.weekday;
      
      hourCount[hour] = (hourCount[hour] ?? 0) + 1;
      dayOfWeekCount[dayOfWeek] = (dayOfWeekCount[dayOfWeek] ?? 0) + 1;
    }
    
    return {
      'preferredHours': hourCount,
      'preferredDaysOfWeek': dayOfWeekCount,
      'totalActions': favoriteActions.length,
    };
  }
  
  /// 分析回避模式
  Map<String, dynamic> _analyzeAvoidancePatterns(List<Map<String, dynamic>> skipActions) {
    List<int> avoidedLengths = [];
    Map<String, int> avoidedPatterns = {};
    
    for (var action in skipActions) {
      var wordPair = WordPairModel.fromJson(action['wordPair']);
      int totalLength = wordPair.wordPair.first.length + wordPair.wordPair.second.length;
      avoidedLengths.add(totalLength);
      
      // 分析回避的模式
      if (wordPair.wordPair.first.length > 10 || wordPair.wordPair.second.length > 10) {
        avoidedPatterns['longWords'] = (avoidedPatterns['longWords'] ?? 0) + 1;
      }
      
      if (wordPair.wordPair.first.length < 3 || wordPair.wordPair.second.length < 3) {
        avoidedPatterns['shortWords'] = (avoidedPatterns['shortWords'] ?? 0) + 1;
      }
    }
    
    return {
      'avoidedLengths': avoidedLengths,
      'avoidedPatterns': avoidedPatterns,
      'confidence': skipActions.length >= 3 ? 0.7 : skipActions.length * 0.23,
    };
  }
  
  /// 获取默认学习偏好
  Map<String, dynamic> _getDefaultLearnedPreferences() {
    return {
      'lengthPreference': {'preferred': 'medium', 'confidence': 0.0},
      'stylePreference': {'preferred': 'modern', 'confidence': 0.0},
      'phoneticPreference': {'alliterationPreference': 0.0, 'rhythmPreference': 0.0, 'confidence': 0.0},
      'semanticPreference': {'preferredCategory': null, 'confidence': 0.0},
      'timePattern': {'preferredHours': {}, 'preferredDaysOfWeek': {}},
      'avoidancePatterns': {'avoidedLengths': [], 'avoidedPatterns': {}, 'confidence': 0.0},
    };
  }
  
  /// 风格判断辅助方法
  bool _isClassicStyle(WordPairModel wordPair) {
    // 简化实现：检查是否使用常见词汇
    const commonWords = ['time', 'day', 'way', 'life', 'work', 'place', 'world', 'hand', 'eye', 'part'];
    return commonWords.contains(wordPair.wordPair.first.toLowerCase()) ||
           commonWords.contains(wordPair.wordPair.second.toLowerCase());
  }
  
  bool _isModernStyle(WordPairModel wordPair) {
    // 简化实现：检查长度平衡和现代感
    int lengthDiff = (wordPair.wordPair.first.length - wordPair.wordPair.second.length).abs();
    int totalLength = wordPair.wordPair.first.length + wordPair.wordPair.second.length;
    return lengthDiff <= 2 && totalLength >= 8 && totalLength <= 16;
  }
  
  bool _isFuturisticStyle(WordPairModel wordPair) {
    // 简化实现：检查科技感词汇
    const techWords = ['tech', 'cyber', 'digital', 'smart', 'ai', 'net', 'web', 'app', 'code', 'data'];
    String combined = wordPair.wordPair.first.toLowerCase() + wordPair.wordPair.second.toLowerCase();
    return techWords.any((word) => combined.contains(word));
  }
  
  /// 清除用户历史记录
  Future<void> clearUserHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userHistoryKey);
    await prefs.remove(_learnedPreferencesKey);
  }
  
  /// 获取用户偏好置信度
  Future<double> getPreferenceConfidence() async {
    final learnedPreferences = await getLearnedPreferences();
    
    double totalConfidence = 0.0;
    int confidenceCount = 0;
    
    // 计算各项偏好的平均置信度
    if (learnedPreferences['lengthPreference']?['confidence'] != null) {
      totalConfidence += learnedPreferences['lengthPreference']['confidence'];
      confidenceCount++;
    }
    
    if (learnedPreferences['stylePreference']?['confidence'] != null) {
      totalConfidence += learnedPreferences['stylePreference']['confidence'];
      confidenceCount++;
    }
    
    if (learnedPreferences['phoneticPreference']?['confidence'] != null) {
      totalConfidence += learnedPreferences['phoneticPreference']['confidence'];
      confidenceCount++;
    }
    
    return confidenceCount > 0 ? totalConfidence / confidenceCount : 0.0;
  }
}