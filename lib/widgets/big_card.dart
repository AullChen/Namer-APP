import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:english_words/english_words.dart';

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
    this.formattedName,
    this.showCopyButton = true,
  }) : super(key: key);

  final WordPair pair;
  final String? formattedName;
  final bool showCopyButton;

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制到剪贴板: $text'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayText = formattedName ?? pair.asLowerCase;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (formattedName != null && formattedName != pair.asLowerCase) ...[
                Text(
                  '原始名称',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pair.asLowerCase,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '格式化名称',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              
              SelectableText(
                displayText,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontFamily: formattedName != null ? 'monospace' : null,
                ),
                textAlign: TextAlign.center,
              ),
              
              if (showCopyButton) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filled(
                      onPressed: () => _copyToClipboard(context, displayText),
                      icon: const Icon(Icons.copy),
                      tooltip: '复制名称',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                    if (formattedName != null && formattedName != pair.asLowerCase) ...[
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () => _copyToClipboard(context, pair.asLowerCase),
                        icon: const Icon(Icons.content_copy),
                        tooltip: '复制原始名称',
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
