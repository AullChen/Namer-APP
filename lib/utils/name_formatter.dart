import 'package:english_words/english_words.dart';

class NameFormatter {
  static WordPair toWordPair(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) {
      return WordPair('无效', '名称');
    }
    // 优先用分隔符切分
    final parts = trimmed.split(RegExp(r'[\s_\-]+')).where((e) => e.isNotEmpty).toList();
    if (parts.length >= 2) {
      final first = parts.first;
      final second = parts.sublist(1).join('');
      return WordPair(first, second);
    }
    // 中文或单词情况
    if (trimmed.runes.length >= 4) {
      final len = trimmed.runes.length;
      final mid = (len / 2).floor();
      final first = String.fromCharCodes(trimmed.runes.take(mid));
      final second = String.fromCharCodes(trimmed.runes.skip(mid));
      return WordPair(first, second);
    } else {
      return WordPair(trimmed, '项目');
    }
  }
}