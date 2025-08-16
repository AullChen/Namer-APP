# 名生妙手 —— Namer APP

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License">
</div>

一个功能（并不）强大、基于 Flutter 构建的（不）智能名称生成器应用，旨在帮助用户为他们的项目、产品或创意快速找到~~可以糊弄外行的~~完美名称。应用结合了本地~~智障~~智能算法和 AI 驱动的建议，提供丰富多样的命名灵感。

~~其实只是为了学`flutter`搓出来的小玩意。灵感来源于官方文档中的`build your first flutter app`。感谢各种AI工具。~~

## ✨ 主要特性

- **多种生成引擎**:
  - **智能引擎**: 基于本地词库和规则，根据类别（如科技、创意、商业、自然）生成高质量名称。（并非高质量）
  - **AI 引擎 (可选)**: 集成 AI 服务，提供更具创造力和上下文相关的名称建议。（这个反而靠谱多了）
- **响应式设计**: 界面在不同尺寸的设备（手机、平板、桌面）上都能提供流畅的用户体验。（flutter在这方面确实好用）
- **多语言支持**: 应用架构支持多语言，当前已实现中文和英文的本地化词库。
- **收藏夹功能**: 用户可以保存、管理和分类他们喜欢的名称。
- **高度可定制**: 支持自定义提示词、调整名称长度偏好等。
- **高效的本地算法**: 实现了按需加载词库和优化的生成算法，确保应用运行流畅，资源占用低。（未必）

## 🚀 开始使用

1.  **克隆仓库**:
    ```bash
    git clone https://github.com/your-username/your-repository.git
    cd your-repository
    ```

2.  **安装依赖**:
    ```bash
    flutter pub get
    ```

3.  **运行应用**:
    ```bash
    flutter run
    ```

## 📂 项目结构

```
flutter_application_1/
├── assets/
│   ├── locales/         # 本地化词库 (JSON 格式)
│   └── rules/           # 规则文件
├── lib/
│   ├── main.dart        # 应用入口
│   ├── models/          # 数据模型
│   ├── screens/         # 应用的主要页面
│   ├── services/        # 核心业务逻辑和服务
│   ├── utils/           # 工具类和扩展
│   └── widgets/         # 可重用的 UI 组件
├── pubspec.yaml         # 项目依赖和配置
└── README.md            # 项目介绍
```

## 🛠️ 技术栈

- **框架**: [Flutter](https://flutter.dev/)
- **语言**: [Dart](https://dart.dev/)
- **状态管理**: [Riverpod](https://riverpod.dev/)
- **主要依赖**:
  - `flutter_riverpod`
  - `shared_preferences` (用于本地存储)
  - `english_words`

## 📋 TODO列表

### 🔥 高优先级
- [ ] **实时网络API集成**：接入真实的趋势数据API
- [x] **大语言模型优化**：使用LLM优化名称生成，并支持自定义API
- [x] **多语言支持**：添加英文、日文等多语言界面
- [ ] **云端同步**：用户数据跨设备同步功能
- [ ] **批量生成**：一次生成多个相关名称
- [x] **导出功能**：支持导出收藏列表为CSV/JSON

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

## 🤝 如何贡献

我们欢迎任何形式的贡献！请阅读我们的 [CONTRIBUTING.md](CONTRIBUTING.md) 文件，了解如何参与改进这个项目。

## 📄 开源许可

本项目采用 MIT 许可证。详情请见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- [CodeBuddy](https://www.codebuddy.ai/) - IDE
- [Claude AI](https://www.anthropic.com/)[OpenAI](https://openai.com/)[Gemini](https://gemini.google.com/) - 代码助手
- [Flutter](https://flutter.dev/) - 跨平台UI框架
- [Free-QWQ](https://qwq.aigpu.cn/) - 免费无限制分布式AI算力平台——提供本项目的默认大模型API

## 📞 联系方式

- **项目主页**: [GitHub Repository](https://github.com/AullChen/Namer-APP)
- **问题反馈**: [Issues](https://github.com/AullChen/Namer-APP/issues)
- **功能建议**: [Discussions](https://github.com/AullChen/Namer-APP/discussions)

---

<div align="center">
  <p>如果这个项目对您有帮助、使您感兴趣或者给您带来了欢乐，请给我们一个 ⭐️</p>
  <p>Made with ❤️ by AullChen</p>
</div>