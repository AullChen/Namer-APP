import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AI模型配置
class AIModelConfig {
  final String name;
  final String apiUrl;
  final String apiKey;
  final String model;
  final bool isDefault;

  const AIModelConfig({
    required this.name,
    required this.apiUrl,
    required this.apiKey,
    required this.model,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'apiUrl': apiUrl,
      'apiKey': apiKey,
      'model': model,
      'isDefault': isDefault,
    };
  }

  factory AIModelConfig.fromJson(Map<String, dynamic> json) {
    return AIModelConfig(
      name: json['name'] ?? '',
      apiUrl: json['apiUrl'] ?? '',
      apiKey: json['apiKey'] ?? '',
      model: json['model'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  AIModelConfig copyWith({
    String? name,
    String? apiUrl,
    String? apiKey,
    String? model,
    bool? isDefault,
  }) {
    return AIModelConfig(
      name: name ?? this.name,
      apiUrl: apiUrl ?? this.apiUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

/// AI API服务状态
class AIApiState {
  final List<AIModelConfig> configs;
  final AIModelConfig? currentConfig;
  final bool useLocalEngine;
  final bool isLoading;
  final String? error;

  const AIApiState({
    this.configs = const [],
    this.currentConfig,
    this.useLocalEngine = true,
    this.isLoading = false,
    this.error,
  });

  AIApiState copyWith({
    List<AIModelConfig>? configs,
    AIModelConfig? currentConfig,
    bool? useLocalEngine,
    bool? isLoading,
    String? error,
  }) {
    return AIApiState(
      configs: configs ?? this.configs,
      currentConfig: currentConfig ?? this.currentConfig,
      useLocalEngine: useLocalEngine ?? this.useLocalEngine,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// AI API服务
class AIApiService extends StateNotifier<AIApiState> {
  AIApiService() : super(const AIApiState()) {
    _loadConfigs();
  }

  static const String _configsKey = 'ai_model_configs';
  static const String _currentConfigKey = 'current_ai_config';
  static const String _useLocalEngineKey = 'use_local_engine';

  // 默认配置
  static const AIModelConfig defaultConfig = AIModelConfig(
    name: '算力云 QwQ-32B',
    apiUrl: 'https://api.suanli.cn/v1',
    apiKey: 'sk-W0rpStc95T7JVYVwDYc29IyirjtpPPby6SozFMQr17m8KWeo',
    model: 'free:QwQ-32B',
    isDefault: true,
  );

  /// 加载配置
  Future<void> _loadConfigs() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载配置列表
      final configsJson = prefs.getString(_configsKey);
      List<AIModelConfig> configs = [defaultConfig];
      
      if (configsJson != null) {
        final List<dynamic> configsList = json.decode(configsJson);
        final customConfigs = configsList.map((json) => AIModelConfig.fromJson(json)).toList();
        configs.addAll(customConfigs);
      }
      
      // 加载当前配置
      final currentConfigName = prefs.getString(_currentConfigKey);
      AIModelConfig? currentConfig = configs.firstWhere(
        (config) => config.name == currentConfigName,
        orElse: () => defaultConfig,
      );
      
      // 加载引擎选择
      final useLocalEngine = prefs.getBool(_useLocalEngineKey) ?? true;
      
      state = state.copyWith(
        configs: configs,
        currentConfig: currentConfig,
        useLocalEngine: useLocalEngine,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载配置失败: $e',
      );
    }
  }

  /// 添加自定义配置
  Future<void> addConfig(AIModelConfig config) async {
    try {
      final customConfigs = state.configs.where((c) => !c.isDefault).toList();
      customConfigs.add(config);
      
      final prefs = await SharedPreferences.getInstance();
      final configsJson = json.encode(customConfigs.map((c) => c.toJson()).toList());
      await prefs.setString(_configsKey, configsJson);
      
      final newConfigs = [defaultConfig, ...customConfigs];
      state = state.copyWith(configs: newConfigs);
    } catch (e) {
      state = state.copyWith(error: '添加配置失败: $e');
    }
  }

  /// 删除配置
  Future<void> removeConfig(String configName) async {
    if (configName == defaultConfig.name) return; // 不能删除默认配置
    
    try {
      final customConfigs = state.configs.where((c) => !c.isDefault && c.name != configName).toList();
      
      final prefs = await SharedPreferences.getInstance();
      final configsJson = json.encode(customConfigs.map((c) => c.toJson()).toList());
      await prefs.setString(_configsKey, configsJson);
      
      final newConfigs = [defaultConfig, ...customConfigs];
      AIModelConfig? newCurrentConfig = state.currentConfig;
      
      if (state.currentConfig?.name == configName) {
        newCurrentConfig = defaultConfig;
        await prefs.setString(_currentConfigKey, defaultConfig.name);
      }
      
      state = state.copyWith(
        configs: newConfigs,
        currentConfig: newCurrentConfig,
      );
    } catch (e) {
      state = state.copyWith(error: '删除配置失败: $e');
    }
  }

  /// 切换当前配置
  Future<void> setCurrentConfig(AIModelConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentConfigKey, config.name);
      
      state = state.copyWith(currentConfig: config);
    } catch (e) {
      state = state.copyWith(error: '切换配置失败: $e');
    }
  }

  /// 切换引擎模式
  Future<void> toggleEngineMode() async {
    try {
      final newUseLocalEngine = !state.useLocalEngine;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_useLocalEngineKey, newUseLocalEngine);
      
      state = state.copyWith(useLocalEngine: newUseLocalEngine);
    } catch (e) {
      state = state.copyWith(error: '切换引擎模式失败: $e');
    }
  }

  /// 测试API连接
  Future<bool> testConnection(AIModelConfig config) async {
    try {
      final response = await http.post(
        Uri.parse('${config.apiUrl}/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${config.apiKey}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': config.model,
          'messages': [
            {'role': 'user', 'content': 'test'}
          ],
          'max_tokens': 10,
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 使用AI生成名称 - 核心方法
  Future<List<String>> generateNamesWithAI(String prompt, String language) async {
    if (state.useLocalEngine || state.currentConfig == null) {
      print('🔄 使用本地引擎模式或无AI配置');
      return []; // 使用本地引擎
    }

    print('🚀 开始AI生成，提示词: $prompt, 语言: $language');
    state = state.copyWith(isLoading: true);
    
    try {
      final config = state.currentConfig!;
      final systemPrompt = _buildSystemPrompt(language);
      final userPrompt = _buildUserPrompt(prompt, language);

      print('🔧 系统提示词: $systemPrompt');
      print('🔧 用户提示词: $userPrompt');

      final response = await http.post(
        Uri.parse('${config.apiUrl}/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${config.apiKey}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': config.model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt}
          ],
          'max_tokens': 500,
          'temperature': 0.8,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📡 API响应状态码: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📦 API完整响应: $data');
        
        final content = data['choices'][0]['message']['content'] as String;
        print('📝 AI生成内容: $content');
        
        final names = _parseNamesFromResponse(content);
        print('✅ 解析后的名称列表: $names');
        
        state = state.copyWith(isLoading: false);
        return names;
      } else {
        print('❌ API请求失败: ${response.statusCode}, 响应: ${response.body}');
        throw Exception('API请求失败: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 AI生成异常: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'AI生成失败: $e',
      );
      return [];
    }
  }

  /// 构建系统提示词 - 优化版本
  String _buildSystemPrompt(String language) {
    switch (language) {
      case 'zh':
        return '''你是专业的命名助手。请严格按照以下格式输出5个名称：

名称一
名称二  
名称三
名称四
名称五

重要规则：
- 只输出名称，不要编号、解释、思考过程
- 每行一个名称
- 名称要创意、简洁、有意义
- 严格遵循中文命名规范
- 不要包含任何思考标签如<think>等''';
      case 'en':
        return '''You are a professional naming assistant. Output exactly 5 names in this format:

Name One
Name Two
Name Three
Name Four
Name Five

STRICT RULES:
- Output ONLY names, no numbering, explanations, or thinking process
- One name per line
- Names must be creative, concise, and meaningful
- Follow English naming conventions
- Do not include any thinking tags like <think>''';
      default:
        return '''Professional naming assistant. Output exactly 5 names, one per line.
No explanations, no numbering, just names.
Creative, concise, meaningful names only.
No thinking tags or process explanations.''';
    }
  }

  /// 构建用户提示词
  String _buildUserPrompt(String prompt, String language) {
    switch (language) {
      case 'zh':
        return '请为以下描述生成5个创意名称：$prompt';
      case 'en':
        return 'Please generate 5 creative names for the following description: $prompt';
      default:
        return 'Generate 5 creative names for: $prompt';
    }
  }

  /// 解析AI响应中的名称 - 增强版本
  List<String> _parseNamesFromResponse(String content) {
    print('🔍 AI原始响应内容: $content');
    
    // 第一步：移除思考过程标签和其他无关内容
    String cleanContent = content;
    
    // 移除各种思考标签
    cleanContent = cleanContent.replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '');
    cleanContent = cleanContent.replaceAll(RegExp(r'<thinking>.*?</thinking>', dotAll: true), '');
    cleanContent = cleanContent.replaceAll(RegExp(r'思考过程：.*?(?=\n\n|\n[^\n])', dotAll: true), '');
    
    print('🧹 移除思考标签后: $cleanContent');
    
    // 第二步：按行分割并清理
    final lines = cleanContent.split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    
    print('🔍 清理后分割的行数: ${lines.length}');
    
    final names = <String>[];
    
    for (final line in lines) {
      // 第三步：移除各种格式标记
      String cleanLine = line
          .replaceAll(RegExp(r'^\d+\.?\s*'), '') // 移除编号 1. 2. 等
          .replaceAll(RegExp(r'^[-*•]\s*'), '') // 移除列表符号
          .replaceAll(RegExp(r'^[：:]\s*'), '') // 移除冒号
          .replaceAll(RegExp(r'["""''`]'), '') // 移除引号
          .replaceAll(RegExp(r'^\s*[（(].*?[）)]\s*'), '') // 移除括号内容
          .replaceAll(RegExp(r'^\s*【.*?】\s*'), '') // 移除中文方括号
          .trim();
      
      // 第四步：严格过滤无效内容
      if (_isValidName(cleanLine)) {
        names.add(cleanLine);
        print('✅ 提取到有效名称: $cleanLine');
      } else {
        print('❌ 过滤掉无效内容: $cleanLine');
      }
      
      if (names.length >= 5) break; // 最多5个名称
    }
    
    // 第五步：如果没有提取到有效名称，尝试更宽松的解析
    if (names.isEmpty) {
      print('⚠️ 未提取到有效名称，尝试宽松解析...');
      for (final line in lines) {
        final simpleLine = line.replaceAll(RegExp(r'[^\u4e00-\u9fff\w\s-]'), '').trim();
        if (simpleLine.length >= 2 && simpleLine.length <= 30) {
          names.add(simpleLine);
          print('🔄 宽松解析提取: $simpleLine');
          if (names.length >= 5) break;
        }
      }
    }
    
    print('🎯 最终解析结果: $names');
    return names;
  }

  /// 验证名称是否有效 - 增强版本
  bool _isValidName(String name) {
    if (name.isEmpty || name.length < 2 || name.length > 50) {
      return false;
    }
    
    // 过滤掉解释性文字和无效内容
    final invalidPatterns = [
      // 中文无效模式
      '以下是', '根据', '这些名称', '我现在需要', '首先得仔细', '接下来考虑', '然后要确保',
      '生成', '命名', '建议', '推荐', '可以', '适合', '比如', '例如', '分别是', '如下',
      '思考', '分析', '考虑', '确保', '需要', '应该', '可能', '或者', '因为', '所以',
      
      // 英文无效模式
      'here are', 'based on', 'i need to', 'first', 'next', 'then', 'these names',
      'generate', 'naming', 'suggest', 'recommend', 'suitable', 'example', 'following',
      'thinking', 'analysis', 'consider', 'ensure', 'should', 'could', 'might', 'because'
    ];
    
    final lowerName = name.toLowerCase();
    for (final pattern in invalidPatterns) {
      if (lowerName.contains(pattern.toLowerCase())) {
        return false;
      }
    }
    
    // 检查是否包含过多的解释性词汇
    final explanatoryWords = ['的', '是', '了', '在', '有', 'the', 'is', 'are', 'and', 'or', 'but'];
    int explanatoryCount = 0;
    for (final word in explanatoryWords) {
      if (lowerName.contains(word)) {
        explanatoryCount++;
      }
    }
    
    // 如果解释性词汇过多，可能是句子而不是名称
    if (explanatoryCount > 2) {
      return false;
    }
    
    return true;
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// AI API服务提供者
final aiApiServiceProvider = StateNotifierProvider<AIApiService, AIApiState>((ref) {
  return AIApiService();
});