import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/services/ai_api_service.dart';

class AIConfigScreen extends ConsumerStatefulWidget {
  const AIConfigScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AIConfigScreen> createState() => _AIConfigScreenState();
}

class _AIConfigScreenState extends ConsumerState<AIConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _apiUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  
  bool _isTestingConnection = false;
  String? _testResult;

  @override
  void dispose() {
    _nameController.dispose();
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _apiUrlController.clear();
    _apiKeyController.clear();
    _modelController.clear();
    setState(() {
      _testResult = null;
    });
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTestingConnection = true;
      _testResult = null;
    });

    final config = AIModelConfig(
      name: _nameController.text.trim(),
      apiUrl: _apiUrlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      model: _modelController.text.trim(),
    );

    final success = await ref.read(aiApiServiceProvider.notifier).testConnection(config);
    
    setState(() {
      _isTestingConnection = false;
      _testResult = success ? '连接成功！' : '连接失败，请检查配置';
    });
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    final config = AIModelConfig(
      name: _nameController.text.trim(),
      apiUrl: _apiUrlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      model: _modelController.text.trim(),
    );

    await ref.read(aiApiServiceProvider.notifier).addConfig(config);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('配置已保存')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiState = ref.watch(aiApiServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI模型配置'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 说明卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '配置说明',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• 支持OpenAI兼容的API接口\n'
                      '• API密钥将安全存储在本地\n'
                      '• 建议先测试连接再保存配置\n'
                      '• 可以添加多个模型配置并切换使用',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 配置表单
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '新增AI模型',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 配置名称
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '配置名称',
                          hintText: '例如：GPT-4o',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.label_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入配置名称';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // API地址
                      TextFormField(
                        controller: _apiUrlController,
                        decoration: const InputDecoration(
                          labelText: 'API地址',
                          hintText: 'https://api.openai.com/v1',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入API地址';
                          }
                          final uri = Uri.tryParse(value.trim());
                          if (uri == null || !uri.hasAbsolutePath) {
                            return '请输入有效的URL';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // API密钥
                      TextFormField(
                        controller: _apiKeyController,
                        decoration: const InputDecoration(
                          labelText: 'API密钥',
                          hintText: 'sk-...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.key),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入API密钥';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 模型名称
                      TextFormField(
                        controller: _modelController,
                        decoration: const InputDecoration(
                          labelText: '模型名称',
                          hintText: 'gpt-4o',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.psychology),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入模型名称';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 测试结果
                      if (_testResult != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _testResult!.contains('成功')
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _testResult!.contains('成功')
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _testResult!.contains('成功')
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: _testResult!.contains('成功')
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _testResult!,
                                style: TextStyle(
                                  color: _testResult!.contains('成功')
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // 操作按钮
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isTestingConnection ? null : _testConnection,
                              icon: _isTestingConnection
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.wifi_protected_setup),
                              label: Text(_isTestingConnection ? '测试中...' : '测试连接'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saveConfig,
                              icon: const Icon(Icons.save),
                              label: const Text('保存配置'),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // 清空按钮
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _clearForm,
                          icon: const Icon(Icons.clear),
                          label: const Text('清空表单'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 现有配置列表
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '已配置的模型',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (aiState.configs.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('暂无配置'),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: aiState.configs.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final config = aiState.configs[index];
                          final isCurrent = aiState.currentConfig?.name == config.name;
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isCurrent
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                config.isDefault ? Icons.star : Icons.psychology,
                                color: isCurrent
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            title: Text(
                              config.name,
                              style: TextStyle(
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              '${config.model} • ${Uri.parse(config.apiUrl).host}',
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '当前',
                                      style: TextStyle(
                                        color: theme.colorScheme.onPrimary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                if (!config.isDefault) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('确认删除'),
                                          content: Text('确定要删除配置"${config.name}"吗？'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('取消'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: const Text('删除'),
                                            ),
                                          ],
                                        ),
                                      );
                                      
                                      if (confirmed == true) {
                                        await ref.read(aiApiServiceProvider.notifier)
                                            .removeConfig(config.name);
                                      }
                                    },
                                  ),
                                ],
                              ],
                            ),
                            onTap: isCurrent ? null : () async {
                              await ref.read(aiApiServiceProvider.notifier)
                                  .setCurrentConfig(config);
                              if (mounted) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('已切换到 ${config.name}')),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}