# 更新日志

本文档记录了 Namer APP 项目的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [未发布]

### 新增
- 完整的项目文档包（README.md、LICENSE、CONTRIBUTING.md）
- MIT 许可证
- 贡献指南和开发规范

## [1.0.0] - 2025-08-13

### 新增
- 🤖 **AI 驱动的名称生成引擎**
  - 先进的语义分析算法
  - 多维度评分系统（语义匹配、创意度、记忆度等）
  - 智能意图识别和情感分析

- 📏 **动态长度调整系统**
  - 取消固定 1-3 词限制
  - 根据提示词复杂度智能调整长度
  - 支持短/中/长三档长度类别

- 🔤 **多格式命名支持**
  - 8 种命名格式：camelCase、PascalCase、snake_case 等
  - 智能分词算法
  - 格式验证和说明

- 🌐 **新兴概念理解能力**
  - 实时趋势数据集成
  - 网络流行语支持
  - 新兴技术概念识别（Web3、AI、元宇宙等）

- 💾 **智能收藏系统**
  - 分类管理收藏名称
  - 自定义标签支持
  - 本地数据持久化

- ⚙️ **个性化设置**
  - 用户偏好学习
  - 深色/浅色主题切换
  - 生成参数自定义

- 🎨 **现代化界面设计**
  - Material Design 3 设计语言
  - 响应式布局适配
  - 流畅的交互动画

### 技术特性
- **跨平台支持**: Windows、macOS、Linux、Android、iOS、Web
- **状态管理**: 基于 Riverpod 的响应式状态管理
- **数据存储**: Hive 轻量级本地数据库
- **性能优化**: 异步处理和内存优化

### 核心服务
- `NameGeneratorService`: 核心名称生成服务
- `AdvancedAIService`: AI 模型服务
- `NamingFormatService`: 格式化服务
- `DynamicLengthService`: 动态长度服务
- `WebQueryService`: 网络查询服务
- `SemanticParserService`: 语义解析服务
- `StorageService`: 数据存储服务

### 界面组件
- `GeneratorScreen`: 名称生成主界面
- `FavoritesScreen`: 收藏管理界面
- `SettingsScreen`: 设置配置界面
- `CandidateList`: 候选名称列表
- `CategorySelector`: 分类选择器

## [0.1.0] - 2025-08-11

### 新增
- 项目初始化
- 基础名称生成功能
- 简单的收藏系统
- 基本界面框架

---

## 版本说明

### 版本类型
- **主版本号 (MAJOR)**: 不兼容的 API 修改
- **次版本号 (MINOR)**: 向下兼容的功能性新增
- **修订号 (PATCH)**: 向下兼容的问题修正

### 变更类型
- **新增 (Added)**: 新功能
- **变更 (Changed)**: 对现有功能的变更
- **弃用 (Deprecated)**: 即将移除的功能
- **移除 (Removed)**: 已移除的功能
- **修复 (Fixed)**: 任何 bug 修复
- **安全 (Security)**: 安全相关的修复

### 发布计划

#### v1.1.0 (计划中)
- 多语言支持（英文、日文）
- 云端数据同步
- 批量名称生成
- 语音输入支持

#### v1.2.0 (计划中)
- 社区分享功能
- 名称评分系统
- 历史记录统计
- 主题定制

#### v2.0.0 (远期规划)
- 完整的 API 开放
- 插件系统
- 企业版功能
- 高级 AI 模型集成

---

更多详细信息请查看 [GitHub Releases](https://github.com/AullChen/Namer-APP/releases)。