import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/services/app_state.dart';
import 'package:flutter_application_1/models/category_model.dart';

class CategorySelector extends ConsumerWidget {
  final List<String> selectedCategories;
  final Function(List<String>) onCategoriesChanged;

  const CategorySelector({
    Key? key,
    required this.selectedCategories,
    required this.onCategoriesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分类',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = selectedCategories.contains(category.id);
            
            return FilterChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (selected) {
                List<String> newCategories = List.from(selectedCategories);
                
                if (selected) {
                  if (!newCategories.contains(category.id)) {
                    newCategories.add(category.id);
                  }
                } else {
                  newCategories.remove(category.id);
                  // 确保至少有一个分类
                  if (newCategories.isEmpty) {
                    // 添加"未分类"
                    final uncategorized = categories.firstWhere(
                      (c) => c.name == '未分类',
                      orElse: () => categories.first,
                    );
                    newCategories.add(uncategorized.id);
                  }
                }
                
                onCategoriesChanged(newCategories);
              },
              backgroundColor: Colors.transparent,
              selectedColor: _getCategoryColor(categories, category.id),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getCategoryColor(List<CategoryModel> categories, String categoryId) {
    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryModel(name: '未分类', color: 'orange'),
    );
    
    // 将颜色字符串转换为Color对象
    switch (category.color) {
      case 'red':
        return Colors.red.withValues(alpha: 0.2);
      case 'green':
        return Colors.green.withValues(alpha: 0.2);
      case 'blue':
        return Colors.blue.withValues(alpha: 0.2);
      case 'purple':
        return Colors.purple.withValues(alpha: 0.2);
      case 'orange':
      default:
        return Colors.orange.withValues(alpha: 0.2);
    }
  }
}