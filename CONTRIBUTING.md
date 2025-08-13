# 贡献指南

感谢您对 Namer APP 项目的关注！我们欢迎所有形式的贡献，包括但不限于：

- 🐛 Bug 报告
- 💡 功能建议
- 📝 文档改进
- 🔧 代码贡献
- 🎨 UI/UX 设计
- 🌐 翻译工作

## 🚀 快速开始

### 环境准备

1. **安装 Flutter SDK**
   ```bash
   # 下载并安装 Flutter SDK
   # 详见：https://flutter.dev/docs/get-started/install
   ```

2. **验证环境**
   ```bash
   flutter doctor
   ```

3. **Fork 并克隆项目**
   ```bash
   git clone https://github.com/AullChen/Namer-APP.git
   cd namer-app
   flutter pub get
   ```

## 📋 贡献类型

### Bug 报告

如果您发现了 Bug，请：

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

### 功能建议

提出新功能建议时，请：

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

## 💻 代码贡献

### 开发流程

1. **创建分支**
   ```bash
   git checkout -b feature/amazing-feature
   ```

2. **编写代码**
   - 遵循项目的代码规范
   - 添加必要的注释
   - 编写或更新测试

3. **测试代码**
   ```bash
   flutter test
   flutter analyze
   ```

4. **提交更改**
   ```bash
   git add .
   git commit -m "feat: add amazing feature"
   ```

5. **推送分支**
   ```bash
   git push origin feature/amazing-feature
   ```

6. **创建 Pull Request**

### 代码规范

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

## 📝 文档贡献

### 文档类型

- **README.md**: 项目介绍和快速开始
- **API 文档**: 代码注释和 dartdoc
- **用户指南**: 详细使用说明
- **开发文档**: 架构设计和开发指南

### 文档规范

- 使用清晰的标题层级
- 提供代码示例
- 包含必要的截图
- 保持内容更新

## 🎨 设计贡献

### UI/UX 设计

- 遵循 Material Design 3 规范
- 保持设计一致性
- 考虑无障碍访问
- 提供设计稿和原型

### 图标和插图

- 使用 SVG 格式
- 保持风格统一
- 提供多种尺寸
- 遵循版权要求

## 🌐 翻译贡献

### 支持的语言

- 中文（简体）- 主要语言
- English - 计划中
- 日本語 - 计划中

### 翻译流程

1. 检查现有翻译文件
2. 添加或更新翻译内容
3. 测试翻译效果
4. 提交 Pull Request

## 📋 Pull Request 指南

### PR 标题格式

使用 [Conventional Commits](https://conventionalcommits.org/) 格式：

- `feat: 添加新功能`
- `fix: 修复 Bug`
- `docs: 更新文档`
- `style: 代码格式调整`
- `refactor: 代码重构`
- `test: 添加测试`
- `chore: 构建或辅助工具变动`

### PR 描述模板

```markdown
## 变更类型
- [ ] Bug 修复
- [ ] 新功能
- [ ] 文档更新
- [ ] 代码重构
- [ ] 性能优化

## 变更描述
简要描述此次变更的内容和原因

## 测试
- [ ] 已添加单元测试
- [ ] 已添加集成测试
- [ ] 手动测试通过

## 截图
如果涉及 UI 变更，请提供截图

## 检查清单
- [ ] 代码遵循项目规范
- [ ] 已更新相关文档
- [ ] 所有测试通过
- [ ] 已自测功能
```

## 🏷️ 版本发布

### 版本号规则

遵循 [Semantic Versioning](https://semver.org/)：

- `MAJOR.MINOR.PATCH`
- `1.0.0` - 主要版本
- `1.1.0` - 次要版本（新功能）
- `1.1.1` - 补丁版本（Bug 修复）

### 发布流程

1. 更新版本号
2. 更新 CHANGELOG.md
3. 创建 Release Tag
4. 发布到各平台

## 🤝 社区准则

### 行为准则

- 尊重所有贡献者
- 保持友善和专业
- 欢迎新手参与
- 提供建设性反馈

### 沟通渠道

- **GitHub Issues**: Bug 报告和功能建议
- **GitHub Discussions**: 一般讨论和问答
- **Pull Requests**: 代码审查和讨论

## 🎖️ 贡献者认可

我们会在以下地方认可贡献者：

- README.md 贡献者列表
- 发布说明中的致谢
- 项目网站的贡献者页面

## 📞 联系方式

如有任何问题，请通过以下方式联系：

- 创建 [GitHub Issue](https://github.com/AullChen/Namer-APP/issues)
- 参与 [GitHub Discussions](https://github.com/AullChen/Namer-APP/discussions)

---

再次感谢您的贡献！每一个贡献都让 Namer APP 变得更好。🚀