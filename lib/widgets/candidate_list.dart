import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/services/app_state.dart';

class CandidateList extends ConsumerStatefulWidget {
  final VoidCallback onRefresh;
  final Function(int) onSelect;

  const CandidateList({
    Key? key,
    required this.onRefresh,
    required this.onSelect,
  }) : super(key: key);

  @override
  ConsumerState<CandidateList> createState() => _CandidateListState();
}

class _CandidateListState extends ConsumerState<CandidateList> {
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制: $text'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleFavorite(WidgetRef ref, int index) {
    final candidates = ref.read(candidatesProvider);
    if (index < candidates.length) {
      final candidate = candidates[index];
      // 直接切换候选项的收藏状态
      ref.read(favoritesProvider.notifier).toggleFavorite(candidate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidates = ref.watch(candidatesProvider);
    final favorites = ref.watch(favoritesProvider);
    final theme = Theme.of(context);

    if (candidates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '正在生成候选名称...',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请稍候，AI正在为您准备更多选择',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('重新生成'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '智能推荐 (${candidates.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: widget.onRefresh,
                  tooltip: '重新生成候选',
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Expanded(
          child: ListView.separated(
            itemCount: candidates.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final candidate = candidates[index];
              final isFavorite = favorites.any((item) => 
                item.wordPair.first == candidate.wordPair.first && 
                item.wordPair.second == candidate.wordPair.second
              );
              
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => widget.onSelect(index),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // 排名指示器
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: index < 3 
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: index < 3 
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // 名称内容
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  candidate.wordPair.asLowerCase,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (index < 3) ...[
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '推荐',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.amber.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ] else ...[
                                      Icon(
                                        Icons.lightbulb_outline,
                                        size: 16,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '候选',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                    if (isFavorite) ...[
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.favorite,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '已收藏',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // 操作按钮
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                onPressed: () => _copyToClipboard(
                                  context, 
                                  candidate.wordPair.asLowerCase,
                                ),
                                tooltip: '复制名称',
                                style: IconButton.styleFrom(
                                  backgroundColor: theme.colorScheme.secondaryContainer,
                                  foregroundColor: theme.colorScheme.onSecondaryContainer,
                                  minimumSize: const Size(36, 36),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  size: 20,
                                  color: isFavorite ? Colors.red : null,
                                ),
                                onPressed: () => _toggleFavorite(ref, index),
                                tooltip: isFavorite ? '取消收藏' : '添加收藏',
                                style: IconButton.styleFrom(
                                  backgroundColor: isFavorite 
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : theme.colorScheme.primaryContainer,
                                  foregroundColor: isFavorite 
                                    ? Colors.red
                                    : theme.colorScheme.onPrimaryContainer,
                                  minimumSize: const Size(36, 36),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward, size: 20),
                                onPressed: () => widget.onSelect(index),
                                tooltip: '选择此名称',
                                style: IconButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  minimumSize: const Size(36, 36),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
