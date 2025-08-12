import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/models/word_pair_model.dart';
import 'package:flutter_application_1/services/app_state.dart';
import 'package:flutter_application_1/widgets/category_selector.dart';

class FavoriteItem extends ConsumerStatefulWidget {
  final WordPairModel wordPairModel;
  final VoidCallback onDelete;
  final Function(List<String>) onCategoriesChanged;

  const FavoriteItem({
    Key? key,
    required this.wordPairModel,
    required this.onDelete,
    required this.onCategoriesChanged,
  }) : super(key: key);

  @override
  ConsumerState<FavoriteItem> createState() => _FavoriteItemState();
}

class _FavoriteItemState extends ConsumerState<FavoriteItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    // 获取分类名称
    List<String> categoryNames =
        widget.wordPairModel.categories.map((categoryId) {
      final category = categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => CategoryModel(name: '未分类'),
      );
      return category.name;
    }).toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.wordPairModel.wordPair.asLowerCase,
              style: const TextStyle(fontSize: 18),
            ),
            subtitle: Text(
              '分类: ${categoryNames.join(", ")}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: const Icon(Icons.favorite, color: Colors.red),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  tooltip: _expanded ? '收起' : '展开',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onDelete,
                  tooltip: '删除',
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '创建时间: ${_formatDate(widget.wordPairModel.createdAt)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  CategorySelector(
                    selectedCategories: widget.wordPairModel.categories,
                    onCategoriesChanged: widget.onCategoriesChanged,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
