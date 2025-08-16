# 贡献指北

非常感谢您对我们的项目感兴趣！我们欢迎任何形式的贡献，无论是报告错误、提出功能建议，还是提交代码，或者**单纯只是想整活、加点自己喜欢的东西**。

## 📝 行为准则

为了营造一个开放和友好的环境，我们采用了贡献者行为准则。请花时间阅读并遵守 [Code of Conduct](CODE_OF_CONDUCT.md)（如你所见，这像滚木一样并不存在。所以其实你可以为所欲为，前提是不要破坏我们开放而友好的环境）。

## 💡 如何贡献

### 报告错误 (Bug Reports)

如果您发现了一个错误，请：
1. 检查 [Issues](https://github.com/AullChen/Namer-APP/issues) 确认问题未被报告
2. 使用 Bug 报告模板创建新 Issue
3. 提供详细的复现步骤和环境信息

**Bug 报告模板：**
```markdown
**描述**
简要描述遇到的问题

**复现步骤**
1. 打开应用
2. 点击 '...'
3. 滚动到 '...'
4. 看到错误

**预期行为**
描述您期望发生的情况

**实际行为**
描述实际发生的情况

**环境信息**
- 操作系统: [例如 Windows 11]
- Flutter 版本: [例如 3.16.0]
- 应用版本: [例如 1.0.0]

**截图**
如果适用，请添加截图帮助解释问题
```

### 功能建议 (Feature Requests)

如果您有新的功能想法，也请：
1. 检查现有 Issues 避免重复
2. 详细描述功能需求和使用场景
3. 考虑功能的可行性和必要性

**功能建议模板：**
```markdown
**功能描述**
简要描述建议的功能

**问题背景**
这个功能解决什么问题？

**解决方案**
详细描述您希望的实现方式

**替代方案**
描述您考虑过的其他解决方案

**附加信息**
添加任何其他相关信息或截图
```

### 提交代码 (Pull Requests)

我们非常欢迎您通过 Pull Request (PR) 来贡献代码。请遵循以下步骤：

1.  **Fork 仓库**：将项目 Fork 到您自己的 GitHub 账户下。
2.  **创建分支**：从 `main` 分支创建一个新的特性分支（例如 `feature/amazing-new-feature`）或修复分支（例如 `fix/bug-in-widget`）。
3.  **进行修改**：在您的分支上进行代码修改。
    - 遵循项目现有的编码风格和结构。（不遵循也行）
    - 确保您的代码通过了 `flutter analyze` 的检查。
    - 如果您添加了新功能，请考虑为其编写测试。
4.  **提交更改**：使用清晰的、描述性的提交信息来提交您的更改。
5.  **创建 Pull Request**：将您的分支推送到您 Fork 的仓库，并创建一个指向原始仓库 `main` 分支的 Pull Request。
    - 在 PR 的描述中，清晰地说明您做了什么以及为什么这么做。
    - 如果您的 PR 解决了某个 Issue，请在描述中链接它（例如 `Closes #123`）。

### 或者任何你喜欢的方式 (Anything U Like)

在这里为所欲为——违法的东西除外。

## 💻 开发设置

1.  确保您已安装并配置好 [Flutter](httpss://flutter.dev/docs/get-started/install)。
2.  克隆您 Fork 的仓库并进入项目目录。
3.  运行 `flutter pub get` 安装依赖。
4.  运行 `flutter run` 启动应用。

## 📋 代码规范（凑字数的）

#### Dart 代码风格

- 使用 `flutter_lints` 规则
- 类名使用 PascalCase
- 变量和方法名使用 camelCase
- 常量使用 UPPER_SNAKE_CASE
- 私有成员以下划线开头

```dart
// ✅ 好的示例
class NameGenerator {
  static const int MAX_ATTEMPTS = 10;
  final String _apiKey;
  
  String generateName() {
    return _processName();
  }
  
  String _processName() {
    // 实现细节
  }
}

// ❌ 不好的示例
class name_generator {
  static const int maxAttempts = 10;
  final String apiKey;
  
  String generate_name() {
    return processName();
  }
}
```

#### 文件组织

```
lib/
├── models/          # 数据模型
├── services/        # 业务逻辑
├── screens/         # 页面组件
├── widgets/         # 可复用组件
└── utils/           # 工具函数
```

#### 注释规范

```dart
/// 生成智能名称的核心服务类
/// 
/// 该类集成了多种生成算法，包括：
/// - AI 驱动的语义分析
/// - 基于用户偏好的个性化生成
/// - 实时趋势数据集成
class NameGeneratorService {
  /// 根据关键词生成名称
  /// 
  /// [keyword] 用户输入的描述性关键词
  /// [count] 需要生成的名称数量，默认为 5
  /// 
  /// 返回生成的名称列表
  Future<List<String>> generateNames(String keyword, {int count = 5}) async {
    // 实现细节
  }
}
```

### 测试要求

- 为新功能编写单元测试
- 确保测试覆盖率不低于 80%
- 运行所有测试确保通过

```dart
// 测试示例
import 'package:flutter_test/flutter_test.dart';
import 'package:namer_app/services/name_generator_service.dart';

void main() {
  group('NameGeneratorService', () {
    late NameGeneratorService service;
    
    setUp(() {
      service = NameGeneratorService();
    });
    
    test('should generate names based on keyword', () async {
      final names = await service.generateNames('tech startup');
      
      expect(names, isNotEmpty);
      expect(names.length, equals(5));
    });
  });
}
```

## 🎖️ 贡献者认可

我们会在以下地方认可贡献者：

- README.md 贡献者列表（请在PR时顺便加上去，或者为此单独提一个PR——你的贡献可以只是为README增加了一个contributor）
- 发布说明中的致谢（如果有的话）
- 项目网站的贡献者页面（如果存在的话）

## 📞 联系方式

如有任何问题，请通过以下方式联系：

- 创建 [GitHub Issue](https://github.com/AullChen/Namer-APP/issues)
- 参与 [GitHub Discussions](https://github.com/AullChen/Namer-APP/discussions)

---

再次感谢您的贡献！每一个贡献都让 Namer APP 变得更好（或者坏？）。🚀