import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/services/app_state.dart';
import 'package:flutter_application_1/widgets/big_card.dart';
import 'package:flutter_application_1/widgets/candidate_list.dart';
import 'package:flutter_application_1/widgets/category_selector.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showCandidates = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPair = ref.watch(currentWordPairProvider);
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.any((item) => item.id == currentPair.id);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            '智能名称生成器',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // 搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '输入关键词生成相关名称',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchKeywordProvider.notifier).state = '';
                    ref.read(candidatesProvider.notifier).generateCandidates();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onSubmitted: (value) {
                ref.read(searchKeywordProvider.notifier).state = value;
                ref.read(currentWordPairProvider.notifier).getNext();
                ref.read(candidatesProvider.notifier).generateCandidates();
              },
            ),
          ),
          const SizedBox(height: 24),

          // 当前单词卡片
          BigCard(pair: currentPair.wordPair),
          const SizedBox(height: 16),

          // 分类选择器
          if (isFavorite)
            CategorySelector(
              selectedCategories: currentPair.categories,
              onCategoriesChanged: (categories) {
                ref
                    .read(currentWordPairProvider.notifier)
                    .updateCategories(categories);
              },
            ),
          const SizedBox(height: 16),

          // 操作按钮
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(currentWordPairProvider.notifier).toggleFavorite();
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                label: Text(isFavorite ? '取消收藏' : '收藏'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  ref.read(currentWordPairProvider.notifier).getNext();
                },
                child: const Text('下一个'),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showCandidates = !_showCandidates;
                  });
                  if (_showCandidates) {
                    ref.read(candidatesProvider.notifier).generateCandidates();
                  }
                },
                icon: Icon(
                    _showCandidates ? Icons.expand_less : Icons.expand_more),
                label: Text(_showCandidates ? '隐藏候选' : '显示候选'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 候选名称列表
          if (_showCandidates)
            Expanded(
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
    );
  }
}
