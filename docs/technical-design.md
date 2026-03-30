# Timeflies 技术设计

## 1. 技术路线结论

推荐采用原生 iPhone 技术栈：

- `Swift`
- `SwiftUI`
- `SwiftData`
- `UserNotifications`

原因：

- 与 iPhone 集成自然
- UI 与系统体验一致
- 本地通知能力成熟
- 对开源项目友好，依赖少，维护成本低

## 2. 应用形态

建议产品形态为：

- 一个标准 iPhone 应用
- 后续可扩展 Lock Screen / Widget 体验

第一版不建议做 Electron，原因：

- 体积更大
- 通知与系统集成不如原生直接
- 对“长期运行、轻量提醒”的场景不够理想

## 3. 模块划分

### 3.1 Core Domain

核心实体：

- `CountdownGoal`
- `TaskItem`
- `ReminderRule`
- `DeliveryChannel`
- `DeliveryConfig`

### 3.2 Data Layer

负责：

- 本地数据持久化
- 查询与排序
- 目标和事项关系管理

推荐：

- 使用 `SwiftData` 做本地持久化
- 后续如需更强兼容性，可迁移到 `Core Data`

### 3.3 Reminder Engine

负责：

- 计算下次提醒时间
- 注册本地通知
- 触发 Email/SMS 发送任务
- 处理临近截止时的频率变化

### 3.4 Integration Layer

外部通道：

- Email Provider
- SMS Provider

推荐设计成协议抽象，避免绑定单一服务商。

示例协议：

- `ReminderSender`
- `EmailSender`
- `SMSSender`

### 3.5 Presentation Layer

负责：

- 目标列表
- 详情视图
- 事项交互
- 设置页面

## 4. 数据模型草案

## 4.1 CountdownGoal

字段建议：

- `id`
- `title`
- `note`
- `startDate`
- `endDate`
- `durationPreset`（可选）
- `colorHex`
- `createdAt`
- `updatedAt`
- `isArchived`

计算属性：

- `remainingTime`
- `elapsedTime`
- `progress`
- `isOverdue`

## 4.2 TaskItem

字段建议：

- `id`
- `goalID`
- `title`
- `note`
- `isCompleted`
- `completedAt`
- `sortOrder`
- `createdAt`
- `updatedAt`

## 4.3 ReminderRule

字段建议：

- `id`
- `goalID`
- `isEnabled`
- `frequencyType`
- `intervalValue`
- `preferredHour`
- `preferredWeekdays`
- `smartEscalationEnabled`
- `lastSentAt`
- `nextTriggerAt`

## 4.4 DeliveryConfig

字段建议：

- `id`
- `channelType`
- `isEnabled`
- `emailAddress`
- `phoneNumber`
- `providerName`
- `providerCredentialReference`

说明：

敏感凭据不建议直接保存在普通数据库字段中，建议存放在 iOS Keychain。

## 5. 关键技术方案

## 5.1 倒计时计算

系统应使用统一时间源计算：

- 当前时间
- 开始时间
- 结束时间

界面层按秒或按分钟刷新展示，但数据层不需要高频写入。

## 5.2 本地提醒

使用 `UNUserNotificationCenter`：

- 首次启动申请通知权限
- 根据提醒规则生成通知请求
- 对目标修改后重新调度

注意：

- 系统本地通知适合应用内提醒
- 若需要应用未打开也能持续执行复杂发送逻辑，需要额外后台策略

## 5.3 Email 提醒

推荐两种实现方式：

### 方案 A：调用事务型邮件 API

例如：

- Resend
- Postmark
- SendGrid

优点：

- 易于集成
- 模板能力好

缺点：

- 依赖外部网络
- 需要 API Key

### 方案 B：用户提供 SMTP 配置

优点：

- 更通用

缺点：

- 配置复杂
- 兼容性与排障成本更高

建议第一版优先采用 API Provider 方式。

## 5.4 SMS 提醒

建议设计为可插拔外部服务：

- Twilio
- Vonage

风险点：

- 成本
- 国家和地区支持差异
- 号码验证
- 发送合规

因此第一版建议：

- 在数据模型和设置页预留 SMS 能力
- 实际发送放到第二版

## 5.5 安全与隐私

应遵循：

- 默认本地存储
- 敏感密钥存 Keychain
- 不上传用户事项内容，除非用户主动启用云发送
- 明确告知 Email/SMS 数据会经过第三方服务

## 6. 后台与提醒可靠性

这是本项目最关键的技术点之一。

iPhone 上如果要可靠发送 Email/SMS，不应完全依赖“应用当前正在前台运行”。

建议分阶段处理：

### 第一阶段

- 本地通知完全可用
- Email 仅在应用运行时调度发送

### 第二阶段

- 研究 `LaunchAgent` 或登录后常驻轻量后台组件
- 提升提醒可靠性

这样可以先交付核心价值，再逐步提高外部提醒的稳定性。

## 7. 工程结构建议

推荐仓库结构：

```text
TimeLeft/
  README.md
  LICENSE
  .gitignore
  docs/
    product-design.md
    technical-design.md
    open-source-plan.md
  TimeLeftApp/
    App/
    Features/
    Core/
    Services/
    Resources/
  TimeLeftTests/
  TimeLeftUITests/
```

## 8. 架构建议

建议使用简洁 MVVM：

- `Model`：SwiftData 模型
- `ViewModel`：页面状态、交互动作、提醒调度调用
- `View`：SwiftUI 视图

不建议第一版引入过重框架，保持开源项目易读性。

## 9. MVP 开发顺序

1. 基础工程与数据模型
2. 目标 CRUD
3. 事项列表 CRUD 与完成状态
4. 倒计时和进度可视化
5. 本地通知调度
6. 设置页与提醒配置
7. Email 通道
8. SMS 通道预留

## 10. 测试策略

至少包含：

- 倒计时计算单元测试
- 提醒时间计算单元测试
- 数据持久化测试
- 关键页面 UI 测试

特别要覆盖：

- 已过期目标
- 只有时间间隔、没有明确开始时间的目标
- 夏令时与时区变化
- 事项完成后提醒内容变化

## 11. 推荐实现边界

为了让第一版更稳，建议把范围控制为：

- iOS 17+
- 单用户、本地优先
- 本地通知完整支持
- Email 可选启用
- SMS 先做接口和设置占位，不做完整交付
