import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_state.dart';
import '../services/language_service.dart';
import '../services/ai_api_service.dart';
import '../services/enhanced_naming_service.dart';
import '../widgets/big_card.dart';
import '../widgets/candidate_list.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({super.key});

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGenerating = false;
  String _selectedEngine = 'local'; // 'local' or 'ai'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _generateName() async {
    if (_isGenerating) return;
    
    setState(() {
      _isGenerating = true;
    });

    try {
      final languageService = ref.read(languageServiceProvider);
      final currentLanguage = languageService.currentLanguage;
      final searchKeyword = ref.read(searchKeywordProvider);
      
      print('🚀 开始生成名称...');
      print('📝 提示词: "$searchKeyword"');
      print('🌍 语言: ${currentLanguage.displayName} (${currentLanguage.code})');
      print('⚙️ 引擎: $_selectedEngine');
      
      // 使用增强的命名服务生成名称
      await _generateWithEnhancedService(
        prompt: searchKeyword.isEmpty ? '智能项目' : searchKeyword,
        language: currentLanguage,
        useAI: _selectedEngine == 'ai',
      );
      
    } catch (e) {
      print('❌ 生成失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('生成失败: $e'),
            backgroundColor: Colors.red.shade600,
            action: SnackBarAction(
              label: '重试',
              textColor: Colors.white,
              onPressed: () => _generateName(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  // 使用增强命名服务生成名称
  Future<void> _generateWithEnhancedService({
    required String prompt,
    required SupportedLanguage language,
    required bool useAI,
  }) async {
    try {
      print('🔧 配置生成引擎...');
      
      List<String> generatedNames = [];
      
      if (useAI) {
        print('🤖 使用AI引擎生成');
        // 使用AI API服务生成名称
        final aiService = ref.read(aiApiServiceProvider.notifier);
        final enhancedPrompt = _buildLanguageConsistentPrompt(language, prompt);
        
        print('📝 AI提示词: $enhancedPrompt');
        
        try {
          generatedNames = await aiService.generateNamesWithAI(enhancedPrompt, language.code);
          print('🎯 AI返回结果: $generatedNames');
        } catch (e) {
          print('❌ AI生成失败: $e，回退到本地引擎');
          generatedNames = [];
        }
      }
      
      // 如果AI生成失败或使用本地引擎，使用增强命名服务
      if (generatedNames.isEmpty) {
        print('💻 使用本地引擎生成');
        try {
          final enhancedService = ref.read(enhancedNamingServiceProvider.notifier);
          generatedNames = await enhancedService.generateNames(prompt, count: 5);
          print('🎯 本地引擎返回结果: $generatedNames');
        } catch (e) {
          print('❌ 增强服务失败: $e，使用基础生成');
          generatedNames = await _generateBasicNames(prompt, language);
        }
      }
      
      print('✅ 生成完成，获得 ${generatedNames.length} 个名称:');
      for (int i = 0; i < generatedNames.length; i++) {
        print('   ${i + 1}. ${generatedNames[i]}');
      }
      
      if (generatedNames.isNotEmpty) {
        // 更新当前显示的名称
        await _updateCurrentName(generatedNames.first);
        
        // 更新候选名称列表
        await _updateCandidateNames(generatedNames);
        
        print('🎯 界面已更新，当前名称: ${generatedNames.first}');
        
        // 语言一致性验证
        await _validateLanguageConsistency(language);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✨ 成功生成 ${generatedNames.length} 个名称'),
              backgroundColor: Colors.green.shade600,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('⚠️ 未生成任何名称，使用回退方案');
        await _generateFallbackName(prompt, language);
      }
      
    } catch (e) {
      print('❌ 生成服务失败: $e');
      await _generateFallbackName(prompt, language);
      rethrow;
    }
  }

  // 基础名称生成（回退方案）
  Future<List<String>> _generateBasicNames(String prompt, SupportedLanguage language) async {
    print('🔄 使用基础生成方案...');
    
    final names = <String>[];
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    
    // 根据语言生成基础名称
    switch (language.code) {
      case 'zh':
        names.addAll([
          prompt.isEmpty ? '智能项目$timestamp' : '$prompt项目$timestamp',
          prompt.isEmpty ? '创新平台$timestamp' : '$prompt平台$timestamp',
          prompt.isEmpty ? '数字化解决方案$timestamp' : '$prompt解决方案$timestamp',
          prompt.isEmpty ? '智慧系统$timestamp' : '$prompt系统$timestamp',
          prompt.isEmpty ? '科技工具$timestamp' : '$prompt工具$timestamp',
        ]);
        break;
      case 'ja':
        names.addAll([
          prompt.isEmpty ? 'スマートプロジェクト$timestamp' : '$promptプロジェクト$timestamp',
          prompt.isEmpty ? 'イノベーションプラットフォーム$timestamp' : '$promptプラットフォーム$timestamp',
          prompt.isEmpty ? 'デジタルソリューション$timestamp' : '$promptソリューション$timestamp',
          prompt.isEmpty ? 'インテリジェントシステム$timestamp' : '$promptシステム$timestamp',
          prompt.isEmpty ? 'テクノロジーツール$timestamp' : '$promptツール$timestamp',
        ]);
        break;
      case 'ko':
        names.addAll([
          prompt.isEmpty ? '스마트프로젝트$timestamp' : '$prompt프로젝트$timestamp',
          prompt.isEmpty ? '혁신플랫폼$timestamp' : '$prompt플랫폼$timestamp',
          prompt.isEmpty ? '디지털솔루션$timestamp' : '$prompt솔루션$timestamp',
          prompt.isEmpty ? '지능형시스템$timestamp' : '$prompt시스템$timestamp',
          prompt.isEmpty ? '기술도구$timestamp' : '$prompt도구$timestamp',
        ]);
        break;
      default:
        names.addAll([
          prompt.isEmpty ? 'SmartProject$timestamp' : '${prompt}Project$timestamp',
          prompt.isEmpty ? 'InnovationPlatform$timestamp' : '${prompt}Platform$timestamp',
          prompt.isEmpty ? 'DigitalSolution$timestamp' : '${prompt}Solution$timestamp',
          prompt.isEmpty ? 'IntelligentSystem$timestamp' : '${prompt}System$timestamp',
          prompt.isEmpty ? 'TechTool$timestamp' : '${prompt}Tool$timestamp',
        ]);
        break;
    }
    
    return names;
  }

  // 更新当前名称 - 修复版本
  Future<void> _updateCurrentName(String name) async {
    try {
      print('🔄 开始更新当前名称: $name');
      
      // 直接更新状态，不再污染搜索关键词
      ref.read(currentWordPairProvider.notifier).updateWithName(name);
      
      print('✅ 当前名称更新完成');
    } catch (e) {
      print('❌ 更新当前名称失败: $e');
    }
  }

  // 更新候选名称列表
  Future<void> _updateCandidateNames(List<String> names) async {
    try {
      // 直接使用已生成的名称列表更新候选项
      ref.read(candidatesProvider.notifier).updateCandidates(names);
    } catch (e) {
      print('⚠️ 更新候选名称失败: $e');
    }
  }

  // 回退名称生成
  Future<void> _generateFallbackName(String prompt, SupportedLanguage language) async {
    print('🔄 使用回退方案生成名称...');
    
    final names = await _generateBasicNames(prompt, language);
    if (names.isNotEmpty) {
      await _updateCurrentName(names.first);
      await _updateCandidateNames(names);
      print('🎯 回退方案完成，生成名称: ${names.first}');
    }
  }

  // 构建语言一致性增强的提示词
  String _buildLanguageConsistentPrompt(SupportedLanguage language, String keyword) {
    final languageInstructions = {
      SupportedLanguage.chinese: '请严格使用中文生成名称，不要包含任何英文字符或其他语言',
      SupportedLanguage.english: 'Generate names strictly in English only, no Chinese or other language characters',
      SupportedLanguage.japanese: '日本語のみで名前を生成してください。他の言語の文字は含めないでください',
      SupportedLanguage.korean: '한국어로만 이름을 생성해주세요. 다른 언어 문자는 포함하지 마세요',
      SupportedLanguage.french: 'Générez des noms strictement en français uniquement',
      SupportedLanguage.german: 'Generieren Sie Namen ausschließlich auf Deutsch',
      SupportedLanguage.spanish: 'Genere nombres estrictamente en español únicamente',
      SupportedLanguage.russian: 'Генерируйте имена строго только на русском языке',
    };

    final baseInstruction = languageInstructions[language] ?? languageInstructions[SupportedLanguage.english]!;
    
    return '''
$baseInstruction

${keyword.isNotEmpty ? '关键词/Keywords: $keyword' : ''}

要求/Requirements:
1. 生成5个适合的名称
2. 每行一个名称，不要编号
3. 名称要简洁、有意义
4. 严格遵循语言要求，不要混用其他语言
5. 适合作为项目、产品或服务的名称

语言验证: 请确保所有生成的名称都完全符合${language.displayName}的语言规范。
''';
  }

  // 验证单个名称的语言一致性
  Future<bool> _isValidLanguage(String name, SupportedLanguage language) async {
    // 简单的语言验证逻辑
    switch (language) {
      case SupportedLanguage.chinese:
        // 检查是否包含中文字符
        return RegExp(r'[\u4e00-\u9fff]').hasMatch(name);
      case SupportedLanguage.english:
        // 检查是否只包含英文字符
        return RegExp(r'^[a-zA-Z\s\-_]+$').hasMatch(name);
      case SupportedLanguage.japanese:
        // 检查是否包含日文字符
        return RegExp(r'[\u3040-\u309f\u30a0-\u30ff\u4e00-\u9fff]').hasMatch(name);
      case SupportedLanguage.korean:
        // 检查是否包含韩文字符
        return RegExp(r'[\uac00-\ud7af]').hasMatch(name);
      default:
        // 对于其他语言，暂时返回true
        return true;
    }
  }

  // 语言一致性验证
  Future<void> _validateLanguageConsistency(SupportedLanguage language) async {
    final currentWordPair = ref.read(currentWordPairProvider);
    final currentName = currentWordPair.wordPair.first;
    
    if (!await _isValidLanguage(currentName, language)) {
      // 如果当前名称不符合语言要求，显示警告
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('注意: 生成的名称可能不完全符合${language.displayName}语言规范'),
            backgroundColor: Colors.orange.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWordPair = ref.watch(currentWordPairProvider);
    final languageService = ref.watch(languageServiceProvider);
    final candidates = ref.watch(candidatesProvider);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 引擎选择器 - 美化设计
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.psychology,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '生成引擎',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: constraints.maxWidth > 480 ? (constraints.maxWidth / 2) - 6 : double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: _selectedEngine == 'local' 
                                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _selectedEngine == 'local' 
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: RadioListTile<String>(
                                      title: const Text('本地引擎'),
                                      subtitle: const Text('快速、离线'),
                                      value: 'local',
                                      groupValue: _selectedEngine,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedEngine = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: constraints.maxWidth > 480 ? (constraints.maxWidth / 2) - 6 : double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: _selectedEngine == 'ai' 
                                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _selectedEngine == 'ai' 
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: RadioListTile<String>(
                                      title: const Text('AI引擎'),
                                      subtitle: const Text('智能、多样'),
                                      value: 'ai',
                                      groupValue: _selectedEngine,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedEngine = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 提示词输入框 - 美化设计
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.edit_note,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '自定义提示词',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: '输入关键词或描述，如：科技公司、游戏角色、创意项目...',
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _searchController.clear();
                                            ref.read(searchKeywordProvider.notifier).state = '';
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                ),
                                onChanged: (value) {
                                  ref.read(searchKeywordProvider.notifier).state = value;
                                  setState(() {}); // 更新UI以显示/隐藏清除按钮
                                },
                                onSubmitted: (value) {
                                  _generateName();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // 醒目的快速生成按钮
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isGenerating ? null : _generateName,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                child: _isGenerating
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Theme.of(context).colorScheme.onPrimary,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.auto_awesome,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        size: 24,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 语言选择器 - 显眼位置，可直接点击切换
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showLanguageSelector(context, ref),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8),
                          Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              languageService.currentLanguage.flag,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '生成语言',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  languageService.currentLanguage.displayName,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 主要内容区域
              Column(
                children: [
                  // 当前名称卡片
                  BigCard(pair: currentWordPair.wordPair),
                  
                  const SizedBox(height: 16),
                  
                  // 生成按钮 - 美化设计
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: _isGenerating 
                          ? LinearGradient(
                              colors: [
                                Colors.grey.shade400,
                                Colors.grey.shade500,
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                                Theme.of(context).colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      boxShadow: _isGenerating 
                          ? null
                          : [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generateName,
                      icon: _isGenerating 
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.auto_awesome,
                              size: 24,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      label: Text(
                        _isGenerating ? '生成中...' : '✨ 生成名称',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 候选名称列表 - 修复布局约束问题
                  if (candidates.isNotEmpty) ...[
                    Text(
                      '候选名称',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: CandidateList(
                        onRefresh: _generateName,
                        onSelect: (index) {
                          ref.read(candidatesProvider.notifier).selectCandidate(index);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.language,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '选择生成语言',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: SupportedLanguage.values.length,
                  itemBuilder: (context, index) {
                    final language = SupportedLanguage.values[index];
                    final isSelected = ref.read(languageServiceProvider).currentLanguage == language;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            language.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        title: Text(
                          language.displayName,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Theme.of(context).colorScheme.primary : null,
                          ),
                        ),
                        trailing: isSelected 
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ) 
                            : null,
                        onTap: () {
                          ref.read(languageServiceProvider.notifier).changeLanguage(language);
                          Navigator.of(context).pop();
                          // 语言切换后自动生成新名称以验证语言一致性
                          Future.delayed(const Duration(milliseconds: 300), () {
                            _generateName();
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
