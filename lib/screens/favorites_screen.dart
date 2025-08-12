import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/services/app_state.dart';
import 'package:flutter_application_1/models/word_pair_model.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/widgets/favorite_item.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // 初始化时设置为全部分类
    _selectedCategoryId = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final categories = ref.watch(categoriesProvider);
    // 添加一个"全部"选项，所以总数+1
    _tabController = TabController(length: categories.length + 1, vsync: this);

    // 监听标签变化
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          if (_tabController.index == 0) {
            // "全部"选项
            _selectedCategoryId = null;
          } else {
            // 实际分类
            _selectedCategoryId = categories[_tabController.index - 1].id;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final categories = ref.watch(categoriesProvider);

    // 根据选中的分类过滤收藏列表
    List<WordPairModel> filteredFavorites = favorites;
    if (_selectedCategoryId != null) {
      filteredFavorites = favorites
          .where((item) => item.categories.contains(_selectedCategoryId))
          .toList();
    }

    if (favorites.isEmpty) {
      return const Center(
        child: Text('还没有收藏任何名称。'),
      );
    }

    return Column(
      children: [
        // 分类标签栏
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: '全部'),
            ...categories.map((category) => Tab(text: category.name)),
          ],
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),

        // 收藏列表
        Expanded(
          child: filteredFavorites.isEmpty
              ? Center(
                  child: Text('该分类下没有收藏的名称。'),
                )
              : ListView.builder(
                  itemCount: filteredFavorites.length,
                  itemBuilder: (context, index) {
                    final favorite = filteredFavorites[index];
                    return FavoriteItem(
                      wordPairModel: favorite,
                      onDelete: () {
                        ref
                            .read(favoritesProvider.notifier)
                            .removeFavorite(favorite.id);
                      },
                      onCategoriesChanged: (categories) {
                        final updatedFavorite =
                            favorite.copyWith(categories: categories);
                        ref
                            .read(favoritesProvider.notifier)
                            .updateFavorite(updatedFavorite);
                      },
                    );
                  },
                ),
        ),

        // 统计信息
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '共有 ${favorites.length} 个收藏，当前显示 ${filteredFavorites.length} 个',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
