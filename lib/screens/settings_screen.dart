import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/services/app_state.dart';
import 'package:flutter_application_1/services/language_service.dart';
import 'package:flutter_application_1/services/ai_api_service.dart';
import 'package:flutter_application_1/screens/ai_config_screen.dart';
import 'package:flutter_application_1/widgets/category_manager.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final preferences = ref.watch(preferencesProvider);
    final languageState = ref.watch(languageServiceProvider);
    final aiState = ref.watch(aiApiServiceProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(
                    Icons.settings,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '设置',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    '个性化您的应用体验',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // 语言和AI设置
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '语言和AI设置',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 语言选择
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('生成语言'),
                      subtitle: Text('${languageState.currentLanguage.flag} ${languageState.currentLanguage.displayName}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showLanguageSelector(context, ref),
                    ),
                    
                    const Divider(),
                    
                    // 引擎模式切换
                    SwitchListTile(
                      secondary: const Icon(Icons.psychology),
                      title: const Text('使用AI引擎'),
                      subtitle: Text(aiState.useLocalEngine ? '当前使用本地引擎' : '当前使用AI引擎'),
                      value: !aiState.useLocalEngine,
                      onChanged: (value) {
                        ref.read(aiApiServiceProvider.notifier).toggleEngineMode();
                      },
                    ),
                    
                    const Divider(),
                    
                    // AI模型配置
                    ListTile(
                      leading: const Icon(Icons.settings_applications),
                      title: const Text('AI模型配置'),
                      subtitle: Text(aiState.currentConfig?.name ?? '未配置'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AIConfigScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 用户偏好设置
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '用户偏好',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 深色模式
                    SwitchListTile(
                      secondary: const Icon(Icons.dark_mode),
                      title: const Text('深色模式'),
                      subtitle: const Text('切换应用的深色/浅色主题'),
                      value: preferences['darkMode'] ?? false,
                      onChanged: (value) {
                        ref.read(preferencesProvider.notifier).updatePreference(
                              'darkMode',
                              value,
                            );
                      },
                    ),
                    
                    const Divider(),
                    
                    // 默认格式
                    ListTile(
                      leading: const Icon(Icons.format_shapes),
                      title: const Text('默认命名格式'),
                      subtitle: Text(preferences['preferredFormat'] ?? 'kebab-case'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showFormatSelector(context, ref),
                    ),
                    
                    const Divider(),
                    
                    // 默认长度
                    ListTile(
                      leading: const Icon(Icons.straighten),
                      title: const Text('默认名称长度'),
                      subtitle: Text(preferences['preferredLengthCategory'] ?? 'auto'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showLengthSelector(context, ref),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 分类管理
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '分类管理',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const CategoryManager(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 数据管理
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '数据管理',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('导出收藏'),
                      subtitle: const Text('将收藏的名称导出为文件'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('导出功能开发中...')),
                        );
                      },
                    ),
                    
                    const Divider(),
                    
                    ListTile(
                      leading: const Icon(Icons.upload),
                      title: const Text('导入收藏'),
                      subtitle: const Text('从文件导入收藏的名称'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('导入功能开发中...')),
                        );
                      },
                    ),
                    
                    const Divider(),
                    
                    ListTile(
                      leading: Icon(Icons.delete_forever, color: Colors.red[400]),
                      title: Text('清空所有数据', style: TextStyle(color: Colors.red[400])),
                      subtitle: const Text('删除所有收藏和设置（不可恢复）'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('确认清空'),
                            content: const Text('此操作将删除所有收藏的名称和用户设置，且无法恢复。确定要继续吗？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('确认清空'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirmed == true) {
                          ref.read(favoritesProvider.notifier).clear();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('所有数据已清空')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 关于信息
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '关于',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('应用版本'),
                      subtitle: const Text('2.0.0'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: '智能名称生成器',
                          applicationVersion: '2.0.0',
                          applicationIcon: const Icon(Icons.auto_awesome, size: 48),
                          children: const [
                            Text('一个智能的名称生成工具，支持多语言和AI生成，帮助您为项目、产品或创意找到完美的名称。'),
                          ],
                        );
                      },
                    ),
                    
                    const Divider(),
                    
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('使用帮助'),
                      subtitle: const Text('了解如何使用应用功能'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('帮助页面开发中...')),
                        );
                      },
                    ),
                    
                    const Divider(),
                    
                    ListTile(
                      leading: const Icon(Icons.feedback_outlined),
                      title: const Text('反馈建议'),
                      subtitle: const Text('告诉我们您的想法和建议'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('反馈功能开发中...')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32), // 底部留白
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择生成语言',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...SupportedLanguage.values.map((language) {
              final isSelected = ref.read(languageServiceProvider).currentLanguage == language;
              return ListTile(
                leading: Text(
                  language.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(language.displayName),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  ref.read(languageServiceProvider.notifier).changeLanguage(language);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showFormatSelector(BuildContext context, WidgetRef ref) {
    final formats = ['kebab-case', 'camelCase', 'PascalCase', 'snake_case', 'UPPER_CASE'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择命名格式',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...formats.map((format) {
              final preferences = ref.read(preferencesProvider);
              final isSelected = preferences['preferredFormat'] == format;
              return ListTile(
                title: Text(format),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  ref.read(preferencesProvider.notifier).updatePreference('preferredFormat', format);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showLengthSelector(BuildContext context, WidgetRef ref) {
    final lengths = ['auto', 'short', 'medium', 'long'];
    final lengthDescriptions = {
      'auto': '自动选择',
      'short': '短名称 (3-6字符)',
      'medium': '中等长度 (7-12字符)',
      'long': '长名称 (13+字符)',
    };
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择名称长度',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...lengths.map((length) {
              final preferences = ref.read(preferencesProvider);
              final isSelected = preferences['preferredLengthCategory'] == length;
              return ListTile(
                title: Text(lengthDescriptions[length]!),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  ref.read(preferencesProvider.notifier).updatePreference('preferredLengthCategory', length);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}