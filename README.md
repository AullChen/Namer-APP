# Namer APP

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License">
</div>

## 📖 项目简介

**Namer APP** 是一款基于Flutter开发的智能名称生成器，专为创业者、开发者、设计师和创意工作者打造。应用集成了先进的AI算法、语义分析和实时趋势数据，能够为您的项目、产品、品牌和创意提供高质量、个性化的命名建议。

~~其实只是在学`flutter`的时候搓出来的小玩意。感谢各种AI工具。~~

### 🎯 核心功能

- **🤖 AI驱动生成**：采用先进的人工智能模型，理解用户意图并生成创意名称
- **📏 智能长度调整**：根据提示词复杂度自动调整名称长度（短/中/长）
- **🔤 多格式支持**：支持8种命名格式（驼峰、蛇形、短横线等）
- **🌐 趋势感知**：集成网络热词和新兴概念，保持命名的时代感
- **💾 智能收藏**：分类管理收藏的名称，支持标签和搜索
- **⚙️ 个性化设置**：学习用户偏好，提供定制化的命名建议

### 👥 目标用户

- **创业者**：为新公司、产品或服务寻找完美名称
- **开发者**：为项目、变量、函数或API命名
- **设计师**：为品牌、作品集或创意项目命名
- **内容创作者**：为频道、博客或社交媒体账号命名
- **学生**：为学术项目、团队或活动命名

## 🚀 使用方法

### 基本操作

1. **启动应用**
   ```bash
   flutter run
   ```

2. **生成名称**
   - 在主界面输入描述性关键词
   - 选择合适的命名格式和长度
   - 点击"生成"按钮获取建议

3. **自定义选项**
   - **命名格式**：选择适合的格式（如camelCase、kebab-case等）
   - **长度类别**：智能调整或手动选择短/中/长
   - **风格偏好**：现代、经典、创意或专业风格

4. **管理收藏**
   - 点击❤️收藏喜欢的名称
   - 在收藏页面按分类查看
   - 添加自定义标签便于管理

### 高级功能

#### 智能提示词
```
示例输入：
- "科技创业公司，专注AI和机器学习"
- "游戏角色，勇敢的女战士"
- "咖啡店品牌，温馨舒适的氛围"
- "开源项目，数据可视化工具"
```

#### 命名格式示例
```dart
// 原始名称：smart tech
camelCase    → smartTech
PascalCase   → SmartTech
snake_case   → smart_tech
kebab-case   → smart-tech
UPPER_CASE   → SMART_TECH
dot.case     → smart.tech
```

## 🛠️ 开发方法

### 环境要求

- **Flutter SDK**: >= 3.0.0
- **Dart SDK**: >= 3.0.0
- **操作系统**: Windows 10+, macOS 10.14+, Linux (Ubuntu 18.04+)

### 依赖项

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  english_words: ^4.0.0
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/AullChen/Namer-APP.git
   cd namer-app
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **生成代码**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **运行应用**
   ```bash
   # 在模拟器/设备上运行
   flutter run
   
   # 指定平台运行
   flutter run -d windows
   flutter run -d android
   flutter run -d ios
   ```

### 构建发布版本

```bash
# Android APK
flutter build apk --release

# Windows 可执行文件
flutter build windows --release

# iOS (需要 macOS)
flutter build ios --release

# Web 版本
flutter build web --release
```

### 项目结构（未更新）

```
lib/
├── main.dart                    # 应用入口
├── models/                      # 数据模型
│   ├── word_pair_model.dart
│   └── category_model.dart
├── services/                    # 业务逻辑服务
│   ├── name_generator_service.dart      # 核心生成服务
│   ├── advanced_ai_service.dart         # AI模型服务
│   ├── naming_format_service.dart       # 格式化服务
│   ├── dynamic_length_service.dart      # 动态长度服务
│   ├── web_query_service.dart           # 网络查询服务
│   ├── semantic_parser_service.dart     # 语义分析服务
│   ├── storage_service.dart             # 存储服务
│   └── app_state.dart                   # 状态管理
├── screens/                     # 界面页面
│   ├── home_screen.dart
│   ├── generator_screen.dart
│   ├── favorites_screen.dart
│   └── settings_screen.dart
└── widgets/                     # 可复用组件
    ├── big_card.dart
    ├── candidate_list.dart
    ├── category_selector.dart
    ├── favorite_item.dart
    └── category_manager.dart
```

## 📋 TODO列表

### 🔥 高优先级
- [ ] **实时网络API集成**：接入真实的趋势数据API
- [x] **大语言模型优化**：使用LLM优化名称生成，并支持自定义API
- [ ] **多语言支持**：添加英文、日文等多语言界面
- [ ] **云端同步**：用户数据跨设备同步功能
- [ ] **批量生成**：一次生成多个相关名称
- [ ] **导出功能**：支持导出收藏列表为CSV/JSON

### 🚀 功能增强
- [ ] **语音输入**：支持语音描述需求
- [ ] **图像识别**：上传图片生成相关名称
- [ ] **社区分享**：用户分享和评价名称
- [ ] **历史记录**：查看生成历史和统计
- [ ] **主题定制**：更多界面主题选择

### 🎨 用户体验
- [ ] **动画效果**：添加流畅的过渡动画
- [ ] **快捷键支持**：桌面版快捷键操作
- [ ] **拖拽排序**：收藏列表拖拽重排
- [ ] **搜索优化**：模糊搜索和高级筛选
- [ ] **无障碍支持**：屏幕阅读器兼容

### 🔧 技术优化
- [ ] **性能优化**：大数据集处理优化
- [ ] **离线模式**：完全离线使用支持
- [ ] **插件系统**：第三方插件扩展
- [ ] **API开放**：提供开发者API接口
- [ ] **单元测试**：完善测试覆盖率

### 📱 平台扩展
- [ ] **Web版优化**：响应式设计改进
- [ ] **macOS原生**：macOS应用商店版本
- [ ] **Linux支持**：Linux发行版适配
- [ ] **浏览器插件**：Chrome/Firefox扩展
- [ ] **移动端优化**：手机界面适配

## 🤝 贡献指南

我们欢迎所有形式的贡献！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详细信息。

### 如何贡献

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- [CodeBuddy](https://www.codebuddy.ai/) - IDE
- [Claude AI](https://www.anthropic.com/) - 智能助手
- [Flutter](https://flutter.dev/) - 跨平台UI框架
- [Riverpod](https://riverpod.dev/) - 状态管理解决方案
- [English Words](https://pub.dev/packages/english_words) - 英文词汇库
- [Hive](https://pub.dev/packages/hive) - 轻量级数据库

## 📞 联系方式

- **项目主页**: [GitHub Repository](https://github.com/AullChen/Namer-APP)
- **问题反馈**: [Issues](https://github.com/AullChen/Namer-APP/issues)
- **功能建议**: [Discussions](https://github.com/AullChen/Namer-APP/discussions)

---

<div align="center">
  <p>如果这个项目对您有帮助，请给我们一个 ⭐️</p>
  <p>Made with ❤️ by the Namer APP Team</p>
</div>