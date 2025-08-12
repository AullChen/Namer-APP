import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/services/app_state.dart';
import 'package:flutter_application_1/models/category_model.dart';

class CategoryManager extends ConsumerStatefulWidget {
  const CategoryManager({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoryManager> createState() => _CategoryManagerState();
}

class _CategoryManagerState extends ConsumerState<CategoryManager> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedColor = 'orange';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    // 重置表单
    _nameController.clear();
    _descriptionController.clear();
    _selectedColor = 'orange';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加新分类'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '分类名称',
                  hintText: '输入分类名称',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入分类名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述（可选）',
                  hintText: '输入分类描述',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedColor,
                decoration: const InputDecoration(
                  labelText: '颜色',
                ),
                items: const [
                  DropdownMenuItem(value: 'orange', child: Text('橙色')),
                  DropdownMenuItem(value: 'red', child: Text('红色')),
                  DropdownMenuItem(value: 'green', child: Text('绿色')),
                  DropdownMenuItem(value: 'blue', child: Text('蓝色')),
                  DropdownMenuItem(value: 'purple', child: Text('紫色')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedColor = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newCategory = CategoryModel(
                  name: _nameController.text,
                  description: _descriptionController.text,
                  color: _selectedColor,
                );
                
                ref.read(categoriesProvider.notifier).addCategory(newCategory);
                Navigator.of(context).pop();
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(CategoryModel category) {
    // 设置初始值
    _nameController.text = category.name;
    _descriptionController.text = category.description;
    _selectedColor = category.color;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑分类'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '分类名称',
                  hintText: '输入分类名称',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入分类名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述（可选）',
                  hintText: '输入分类描述',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedColor,
                decoration: const InputDecoration(
                  labelText: '颜色',
                ),
                items: const [
                  DropdownMenuItem(value: 'orange', child: Text('橙色')),
                  DropdownMenuItem(value: 'red', child: Text('红色')),
                  DropdownMenuItem(value: 'green', child: Text('绿色')),
                  DropdownMenuItem(value: 'blue', child: Text('蓝色')),
                  DropdownMenuItem(value: 'purple', child: Text('紫色')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedColor = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final updatedCategory = category.copyWith(
                  name: _nameController.text,
                  description: _descriptionController.text,
                  color: _selectedColor,
                );
                
                ref.read(categoriesProvider.notifier).updateCategory(updatedCategory);
                Navigator.of(context).pop();
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '我的分类',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddCategoryDialog,
              tooltip: '添加新分类',
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isDefault = category.name == '未分类';
            
            return ListTile(
              title: Text(category.name),
              subtitle: category.description.isNotEmpty
                  ? Text(category.description)
                  : null,
              leading: CircleAvatar(
                backgroundColor: _getColorFromString(category.color),
                child: Text(
                  category.name.isNotEmpty ? category.name[0] : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              trailing: isDefault
                  ? null // 不允许编辑或删除默认分类
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditCategoryDialog(category),
                          tooltip: '编辑',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('删除分类'),
                                content: Text('确定要删除"${category.name}"分类吗？'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('取消'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      ref.read(categoriesProvider.notifier).removeCategory(category.id);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('删除'),
                                  ),
                                ],
                              ),
                            );
                          },
                          tooltip: '删除',
                        ),
                      ],
                    ),
            );
          },
        ),
      ],
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'orange':
      default:
        return Colors.orange;
    }
  }
}