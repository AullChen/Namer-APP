import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/services/app_state.dart';
import 'package:flutter_application_1/widgets/category_manager.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const SizedBox(height: 16),
          Text(
            '设置',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // 名称长度偏好
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '名称长度偏好',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '选择您偏好的名称长度',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'short',
                        label: Text('简短'),
                        icon: Icon(Icons.short_text),
                      ),
                      ButtonSegment(
                        value: 'medium',
                        label: Text('中等'),
                        icon: Icon(Icons.text_fields),
                      ),
                      ButtonSegment(
                        value: 'long',
                        label: Text('较长'),
                        icon: Icon(Icons.text_format),
                      ),
                    ],
                    selected: {preferences['nameLength'] ?? 'medium'},
                    onSelectionChanged: (Set<String> selection) {
                      if (selection.isNotEmpty) {
                        ref.read(preferencesProvider.notifier).updatePreference(
                              'nameLength',
                              selection.first,
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 名称风格偏好
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '名称风格偏好',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '选择您偏好的名称风格',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'classic',
                        label: Text('经典'),
                        icon: Icon(Icons.auto_stories),
                      ),
                      ButtonSegment(
                        value: 'modern',
                        label: Text('现代'),
                        icon: Icon(Icons.trending_up),
                      ),
                      ButtonSegment(
                        value: 'futuristic',
                        label: Text('未来'),
                        icon: Icon(Icons.rocket_launch),
                      ),
                    ],
                    selected: {preferences['nameStyle'] ?? 'modern'},
                    onSelectionChanged: (Set<String> selection) {
                      if (selection.isNotEmpty) {
                        ref.read(preferencesProvider.notifier).updatePreference(
                              'nameStyle',
                              selection.first,
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 深色模式
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '深色模式',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '切换应用的深色/浅色主题',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Switch(
                    value: preferences['darkMode'] ?? false,
                    onChanged: (value) {
                      ref.read(preferencesProvider.notifier).updatePreference(
                            'darkMode',
                            value,
                          );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 分类管理
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '分类管理',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '创建和管理您的名称分类',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  const CategoryManager(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 关于应用
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '关于应用',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('版本'),
                    subtitle: const Text('1.0.0'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text('开发者'),
                    subtitle: const Text('Flutter学习项目'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}