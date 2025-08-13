import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/services/app_state.dart';
import 'package:flutter_application_1/services/naming_format_service.dart';
import 'package:flutter_application_1/services/dynamic_length_service.dart';
import 'package:flutter_application_1/widgets/candidate_list.dart';
import 'package:flutter_application_1/widgets/category_selector.dart';

enum LengthCategory {
  auto('智能调整'),
  short('简短精炼'),
  medium('适中平衡'),
  long('详细描述');

  const LengthCategory(this.displayName);
  final String displayName;
}

class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showCandidates = false;
  String _selectedFormat = 'kebab-case';
  LengthCategory _selectedLengthCategory = LengthCategory.auto;
  String _selectedStyle = 'modern';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _generateName() async {
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      ref.read(searchKeywordProvider.notifier).state = keyword;
    }
    
    // 更新用户偏好设置
    ref.read(preferencesProvider.notifier).updatePreference('preferredFormat', _selectedFormat);
    ref.read(preferencesProvider.notifier).updatePreference('preferredLengthCategory', _selectedLengthCategory.name);
    ref.read(preferencesProvider.notifier).updatePreference('preferredStyle', _selectedStyle);
    
    // 使用基础生成方法
    ref.read(currentWordPairProvider.notifier).getNext();
    ref.read(candidatesProvider.notifier).generateCandidates();
  }

  String _formatNameByStyle(String name) {
    return NamingFormatService.formatName(name, _selectedFormat);
  }

  String _getLengthDescription() {
    if (_selectedLengthCategory == LengthCategory.auto && _searchController.text.isNotEmpty) {
      String autoCategory = DynamicLengthService.determineLengthCategory(_searchController.text);
      return '${_selectedLengthCategory.displayName} (${DynamicLengthService.getLengthDescription(autoCategory)})';
    }
    return _selectedLengthCategory.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final currentPair = ref.watch(currentWordPairProvider);
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.any((item) => item.id == currentPair.id);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  '智能名称生成器',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '为您的项目生成完美的名称',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // 搜索框和生成按钮
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '输入提示词',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: '例如：科技产品、游戏角色、项目代号...',
                            prefixIcon: const Icon(Icons.lightbulb_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          onSubmitted: (_) => _generateName(),
                          onChanged: (_) => setState(() {}), // 触发长度描述更新
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _generateName,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('生成'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 生成选项
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '生成选项',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 命名格式选择
                  Text(
                    '命名格式',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: NamingFormatService.getSupportedFormats().map((format) {
                      final isSelected = _selectedFormat == format;
                      return FilterChip(
                        label: Text(format),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFormat = format;
                          });
                        },
                        backgroundColor: theme.colorScheme.surface,
                        selectedColor: theme.colorScheme.primaryContainer,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 长度和风格选择
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '名称长度',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<LengthCategory>(
                              value: _selectedLengthCategory,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: LengthCategory.values.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(_getLengthDescription()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedLengthCategory = value ?? LengthCategory.auto;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '命名风格',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedStyle,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'modern', child: Text('现代风格')),
                                DropdownMenuItem(value: 'classic', child: Text('经典风格')),
                                DropdownMenuItem(value: 'creative', child: Text('创意风格')),
                                DropdownMenuItem(value: 'professional', child: Text('专业风格')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedStyle = value ?? 'modern';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // 格式说明
                  if (_selectedFormat != 'default') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              NamingFormatService.getFormatDescription(_selectedFormat),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 生成结果
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '生成结果',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 当前名称展示
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '原始名称',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentPair.wordPair.asLowerCase,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '格式化名称',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatNameByStyle(currentPair.wordPair.asLowerCase),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 分类选择器
                  if (isFavorite) ...[
                    CategorySelector(
                      selectedCategories: currentPair.categories,
                      onCategoriesChanged: (categories) {
                        ref.read(currentWordPairProvider.notifier).updateCategories(categories);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref.read(currentWordPairProvider.notifier).toggleFavorite();
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          label: Text(isFavorite ? '取消收藏' : '收藏'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref.read(currentWordPairProvider.notifier).getNext();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('重新生成'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showCandidates = !_showCandidates;
                            });
                            if (_showCandidates) {
                              ref.read(candidatesProvider.notifier).generateCandidates();
                            }
                          },
                          icon: Icon(_showCandidates ? Icons.expand_less : Icons.expand_more),
                          label: Text(_showCandidates ? '隐藏候选' : '更多选项'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 候选名称列表
          if (_showCandidates) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.list_alt,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '候选名称',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: CandidateList(
                        onRefresh: () {
                          ref.read(candidatesProvider.notifier).generateCandidates();
                        },
                        onSelect: (index) {
                          ref.read(candidatesProvider.notifier).selectCandidate(index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}