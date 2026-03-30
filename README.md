# Timeflies

Timeflies 是一款面向 iPhone 的倒计时与任务管理应用，帮助用户持续看见一件事还剩多少时间，并把截止日期拆成可执行、可提醒、可追踪的行动。

## 目标问题

很多任务之所以会被拖延，并不是因为没有日历，而是因为：

- 很难持续感受到“还剩多少时间”
- 不能把一个时间目标拆成清晰的待办事项
- 缺少持续、主动的提醒机制
- 完成过程缺少记录和反馈

Timeflies 的目标，是把“截止时间”从一个静态日期，变成一个持续可见、可执行、可提醒、可追踪的系统。

## 核心功能

1. 创建倒计时目标
   - 输入标题
   - 设置截止时间
   - 选择主题颜色
2. 拆解具体任务
   - 支持逐项勾选完成
   - 支持为任务添加备注
3. 设置提醒计划
   - iPhone 本地通知
   - Email 提醒入口
   - SMS 提醒入口（通过第三方服务）
4. 追踪完成进度
   - 显示整体进度
   - 记录任务完成状态与说明
5. 运行平台
   - 原生 iPhone 应用

## 设计文档

- [产品设计](./docs/product-design.md)
- [技术设计](./docs/technical-design.md)
- [开源与 Git 规划](./docs/open-source-plan.md)

## 当前实现状态

仓库当前已经包含一个可运行的 `SwiftUI` 原生 iPhone 版本，覆盖：

- 倒计时列表与详情页
- 通过标题、截止时间和颜色创建目标
- 任务新增、勾选、备注、编辑与删除
- 本地 JSON 持久化
- 本地通知调度雏形
- Email / SMS 提醒配置入口
- 品牌启动页与顶部品牌区
- App Icon 资源与提审准备文档

说明：

- 使用 Xcode 打开 `TimeLeft.xcodeproj`，选择一个 iPhone 模拟器后即可运行。
- 当前仓库已经补齐基础的 App Store 准备材料，但在正式提交前仍需配置生产环境的 Bundle ID、签名团队、隐私政策 URL 和最终截图。

## 当前实现方向

- `SwiftUI` 构建原生 iPhone 应用
- `UserNotifications` 处理本地提醒
- Email 作为第一批外部提醒渠道
- SMS 通过可选第三方服务集成，不作为第一版阻塞项

## App Store 准备

- [App Store Metadata Draft](./docs/app-store-metadata.md)
- [App Privacy Draft](./docs/app-store-privacy.md)
- [Release Checklist](./docs/release-checklist.md)

## 下一阶段

建议继续推进：

1. 完善通知与提醒策略
2. 接入真正的 Email/SMS provider
3. 增加测试覆盖和稳定性检查
4. 打磨 App Store 截图与文案
5. 配置正式 Bundle ID、签名和上架信息
