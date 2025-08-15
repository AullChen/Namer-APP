import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 支持的语言枚举
enum SupportedLanguage {
  chinese('zh', '中文', '🇨🇳'),
  english('en', 'English', '🇺🇸'),
  japanese('ja', '日本語', '🇯🇵'),
  korean('ko', '한국어', '🇰🇷'),
  french('fr', 'Français', '🇫🇷'),
  german('de', 'Deutsch', '🇩🇪'),
  spanish('es', 'Español', '🇪🇸'),
  russian('ru', 'Русский', '🇷🇺');

  const SupportedLanguage(this.code, this.displayName, this.flag);
  
  final String code;
  final String displayName;
  final String flag;
}

/// 语言服务状态
class LanguageState {
  final SupportedLanguage currentLanguage;
  final bool isLoading;

  const LanguageState({
    required this.currentLanguage,
    this.isLoading = false,
  });

  LanguageState copyWith({
    SupportedLanguage? currentLanguage,
    bool? isLoading,
  }) {
    return LanguageState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 语言服务提供者
class LanguageService extends StateNotifier<LanguageState> {
  LanguageService() : super(const LanguageState(currentLanguage: SupportedLanguage.chinese)) {
    _loadSavedLanguage();
  }

  static const String _languageKey = 'selected_language';

  /// 加载保存的语言设置
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_languageKey);
      
      if (savedLanguageCode != null) {
        final language = SupportedLanguage.values.firstWhere(
          (lang) => lang.code == savedLanguageCode,
          orElse: () => SupportedLanguage.chinese,
        );
        state = state.copyWith(currentLanguage: language);
      }
    } catch (e) {
      print('Error loading saved language: $e');
    }
  }

  /// 切换语言
  Future<void> changeLanguage(SupportedLanguage language) async {
    if (state.currentLanguage == language) return;

    state = state.copyWith(isLoading: true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.code);
      
      state = state.copyWith(
        currentLanguage: language,
        isLoading: false,
      );
    } catch (e) {
      print('Error saving language preference: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// 获取当前语言的Locale
  Locale get currentLocale => Locale(state.currentLanguage.code);
}

/// 语言服务提供者
final languageServiceProvider = StateNotifierProvider<LanguageService, LanguageState>((ref) {
  return LanguageService();
});

/// 当前语言提供者
final currentLanguageProvider = Provider<SupportedLanguage>((ref) {
  return ref.watch(languageServiceProvider).currentLanguage;
});

/// 当前Locale提供者
final currentLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(languageServiceProvider.notifier).currentLocale;
});