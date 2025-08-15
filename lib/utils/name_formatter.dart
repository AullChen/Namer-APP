/// 简化的名称格式化工具类
class NameFormatter {
  /// 格式化名称为指定格式
  static String formatName(String name, String format) {
    // 预处理：清理输入并标准化
    String cleanName = _cleanInput(name);
    
    switch (format) {
      case 'camelCase':
        return _toCamelCase(cleanName);
      case 'PascalCase':
        return _toPascalCase(cleanName);
      case 'snake_case':
        return _toSnakeCase(cleanName);
      case 'kebab-case':
        return _toKebabCase(cleanName);
      case 'UPPER_CASE':
        return _toUpperCase(cleanName);
      case 'lower case':
        return _toLowerCase(cleanName);
      case 'Title Case':
        return _toTitleCase(cleanName);
      case 'dot.case':
        return _toDotCase(cleanName);
      default:
        return cleanName;
    }
  }

  /// 清理和标准化输入
  static String _cleanInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// 驼峰命名法 (camelCase)
  static String _toCamelCase(String input) {
    List<String> words = _splitWords(input);
    if (words.isEmpty) return input;
    
    String result = words.first.toLowerCase();
    for (int i = 1; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        result += _capitalizeFirst(words[i].toLowerCase());
      }
    }
    return result;
  }

  /// 帕斯卡命名法 (PascalCase)
  static String _toPascalCase(String input) {
    List<String> words = _splitWords(input);
    return words.map((word) => 
      word.isNotEmpty ? _capitalizeFirst(word.toLowerCase()) : ''
    ).join('');
  }

  /// 蛇形命名法 (snake_case)
  static String _toSnakeCase(String input) {
    List<String> words = _splitWords(input);
    return words.map((word) => word.toLowerCase()).join('_');
  }

  /// 短横线命名法 (kebab-case)
  static String _toKebabCase(String input) {
    List<String> words = _splitWords(input);
    return words.map((word) => word.toLowerCase()).join('-');
  }

  /// 大写下划线命名法 (UPPER_CASE)
  static String _toUpperCase(String input) {
    List<String> words = _splitWords(input);
    return words.map((word) => word.toUpperCase()).join('_');
  }

  /// 小写空格分隔 (lower case)
  static String _toLowerCase(String input) {
    List<String> words = _splitWords(input);
    return words.map((word) => word.toLowerCase()).join(' ');
  }

  /// 标题格式 (Title Case)
  static String _toTitleCase(String input) {
    List<String> words = _splitWords(input);
    return words.map((word) => _capitalizeFirst(word.toLowerCase())).join(' ');
  }

  /// 点分命名法 (dot.case)
  static String _toDotCase(String input) {
    List<String> words = _splitWords(input);
    return words.map((word) => word.toLowerCase()).join('.');
  }

  /// 智能分词
  static List<String> _splitWords(String input) {
    // 处理多种分隔符和驼峰命名
    String processed = input
        .replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2') // 驼峰分割
        .replaceAll(RegExp(r'[\s_\-\.]+'), ' '); // 统一分隔符
    
    return processed.split(' ').where((word) => word.isNotEmpty).toList();
  }

  /// 首字母大写
  static String _capitalizeFirst(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }

  /// 获取所有支持的格式
  static List<String> getSupportedFormats() {
    return [
      'camelCase',
      'PascalCase', 
      'snake_case',
      'kebab-case',
      'UPPER_CASE',
      'lower case',
      'Title Case',
      'dot.case',
    ];
  }

  /// 格式说明
  static String getFormatDescription(String format) {
    switch (format) {
      case 'camelCase':
        return '驼峰命名法：myVariableName';
      case 'PascalCase':
        return '帕斯卡命名法：MyClassName';
      case 'snake_case':
        return '蛇形命名法：my_variable_name';
      case 'kebab-case':
        return '短横线命名法：my-variable-name';
      case 'UPPER_CASE':
        return '大写下划线：MY_CONSTANT_NAME';
      case 'lower case':
        return '小写空格：my variable name';
      case 'Title Case':
        return '标题格式：My Variable Name';
      case 'dot.case':
        return '点分命名法：my.variable.name';
      default:
        return '原始格式';
    }
  }
}