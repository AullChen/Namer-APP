import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/services/app_state.dart';

void main() async {
  // 初始化Hive
  await Hive.initFlutter();
  
  runApp(
    // 使用ProviderScope包装整个应用，启用Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取用户偏好设置
    final preferences = ref.watch(preferencesProvider);
    final isDarkMode = preferences['darkMode'] ?? false;
    
    return MaterialApp(
      title: '智能名称生成器',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
