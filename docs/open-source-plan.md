# Timeflies 开源与 Git 规划

## 1. 仓库目标

这个项目准备在 GitHub 上开源，因此建议从一开始就按公开仓库标准组织：

- 清晰 README
- 明确 LICENSE
- 可复现的构建方式
- 分阶段路线图
- 基础 issue / PR 规范

## 2. Git 管理建议

建议立即启用 git 管理，并采用以下约定：

- 默认分支：`main`
- 功能分支前缀：`feature/`
- 修复分支前缀：`fix/`
- 文档分支前缀：`docs/`

如果希望统一和当前工具习惯，也可以使用：

- `codex/feature/...`

## 3. 首批仓库文件

确认设计后，建议创建：

- `README.md`
- `.gitignore`
- `LICENSE`
- `CONTRIBUTING.md`
- `docs/`

如果走 Swift/Xcode 路线，`.gitignore` 应覆盖：

- `DerivedData`
- `.build`
- 用户本地 Xcode 状态文件

## 4. LICENSE 建议

如果希望：

- 更宽松地允许商业使用，建议 `MIT`
- 希望改进继续回流开源，建议 `GPL-3.0`

对独立开源 iPhone 应用来说，`MIT` 往往是更低阻力的选择。

## 5. GitHub 首批内容建议

仓库首页建议包含：

- 项目简介
- 核心截图或设计图
- 功能范围
- 开发路线图
- 本地运行方式

Issue 模板建议至少有：

- Bug report
- Feature request

## 6. 版本路线图

### v0.1 Design

- 完成产品与技术设计
- 确认 MVP 范围

### v0.2 Core App

- 搭建 iPhone 工程
- 完成目标与事项管理

### v0.3 Reminder

- 本地通知
- Email 通道

### v0.4 Polishing

- UI 优化
- 测试
- 开源文档完善

## 7. 当前建议

在你确认设计后，我建议直接执行下面这组动作：

1. `git init`
2. 创建基础文档和 `.gitignore`
3. 创建 iPhone SwiftUI 工程
4. 首次提交到本地 git
5. 后续再连接 GitHub 远端仓库
