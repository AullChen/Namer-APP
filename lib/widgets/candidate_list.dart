import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/services/app_state.dart';

class CandidateList extends ConsumerWidget {
  final VoidCallback onRefresh;
  final Function(int) onSelect;

  const CandidateList({
    Key? key,
    required this.onRefresh,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidates = ref.watch(candidatesProvider);
    final favorites = ref.watch(favoritesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '候选名称',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRefresh,
              tooltip: '刷新候选名称',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final candidate = candidates[index];
              final isFavorite = favorites.any((item) => 
                item.wordPair.first == candidate.wordPair.first && 
                item.wordPair.second == candidate.wordPair.second
              );
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                child: ListTile(
                  title: Text(
                    candidate.wordPair.asLowerCase,
                    style: const TextStyle(fontSize: 18),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isFavorite)
                        const Icon(Icons.favorite, color: Colors.red, size: 18),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () => onSelect(index),
                        tooltip: '选择此名称',
                      ),
                    ],
                  ),
                  onTap: () => onSelect(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}