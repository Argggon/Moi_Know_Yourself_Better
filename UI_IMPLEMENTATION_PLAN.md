# Moi App - UI 改进实施计划

> 文档版本：V1.0  
> 创建日期：2026-08-12  
> 实施原则：简单的事情先做，遵循"全局规范 → 局部应用"的顺序

---

## 一、全局设计规范（Design Tokens）

### 1.1 圆角（Corner Radius）

| 用途 | 当前值 | 推荐值 | 变量名 |
|-----|--------|--------|--------|
| 主要卡片 | 20pt/16pt 混用 | **16pt** | `cornerRadiusStandard` |
| 小型卡片（时间标签等） | 8pt | **8pt** | `cornerRadiusSmall` |
| 输入组件 | 无限（Capsule） | **Capsule** | - |
| 按钮 | 22pt/26pt | **22pt** (高度的 50%) | `cornerRadiusButton` |
| Sheet 容器 | 20pt | **20pt** | `cornerRadiusSheet` |

**推荐方案**：
```swift
public enum Metrics {
    // 现有
    public static let inputControlSize: CGFloat = 44
    public static let inputIconSize: CGFloat = 16
    public static let microphoneIconSize: CGFloat = 17
    
    // 新增
    public static let cornerRadiusStandard: CGFloat = 16  // 主要卡片
    public static let cornerRadiusSmall: CGFloat = 8      // 小标签
    public static let cornerRadiusButton: CGFloat = 22    // 按钮
    public static let cornerRadiusSheet: CGFloat = 20     // Sheet 卡片
}
```

---

### 1.2 间距（Spacing）

| 用途 | 当前值 | 推荐值 | 变量名 |
|-----|--------|--------|--------|
| 主内容水平边距 | 16pt (系统默认) | **20pt** | `contentHorizontalPadding` |
| 卡片列表垂直间距 | 12pt | **16pt** | `cardSpacing` |
| 紧凑列表间距 | 12pt | **12pt** | `compactSpacing` |
| Section 标题到内容 | 14-16pt | **20pt** | `sectionTitleSpacing` |
| 段落内间距 | 16pt | **16pt** | `contentInnerPadding` |

**推荐方案**：
```swift
public enum Spacing {
    public static let contentHorizontal: CGFloat = 20     // 主内容边距
    public static let cardList: CGFloat = 16              // 卡片列表
    public static let compact: CGFloat = 12               // 紧凑列表
    public static let sectionTitle: CGFloat = 20          // Section 标题
    public static let contentInner: CGFloat = 16          // 内容内边距
}
```

---

### 1.3 行间距（Line Spacing）

| 用途 | 当前值 | 推荐值 | 变量名 |
|-----|--------|--------|--------|
| Body 文本 | 6pt/4pt/5pt 混用 | **6pt** | `lineSpacingBody` |
| 紧凑文本（列表） | 4pt | **4pt** | `lineSpacingCompact` |
| 标题文本 | 无 | **8pt** | `lineSpacingTitle` |

**推荐方案**：
```swift
public enum Typography {
    public static let lineSpacingBody: CGFloat = 6        // 正文
    public static let lineSpacingCompact: CGFloat = 4     // 紧凑文本
    public static let lineSpacingTitle: CGFloat = 8       // 标题
}
```

---

### 1.4 字体规范（Typography Scale）

| 用途 | 当前使用 | 推荐规范 | 说明 |
|-----|---------|---------|------|
| 页面大标题 | `.title.bold()` | `.title.bold()` | 导航栏大标题（自动） |
| Section 标题 | `.title2.bold()` | `.title2.bold()` | 主要区块标题 |
| 小标题 | `.title3.medium()` | `.title3.medium()` | 问题、卡片标题 |
| 正文 | `.body` | `.body` | 主要内容 |
| 次要文字 | `.subheadline` | `.subheadline` | 描述、说明 |
| **标签文字** | **`.caption2.bold()`** | **`.caption.bold()`** | **Section 标签（改）** |
| 辅助文字 | `.caption` | `.caption` | 时间戳、提示 |
| 按钮主要 | `.headline` | `.headline` | 主按钮 |
| 按钮次要 | `.subheadline` | `.subheadline` | 链接按钮 |

**关键改动**：
- Section 标签从 `.caption2.bold()` → `.caption.bold()`（提升可读性）

---

### 1.5 图标规范（Icons）

| 用途 | 当前大小 | 推荐规范 |
|-----|---------|---------|
| 空状态图标 | 48pt `.ultraLight` | **48pt `.thin`** 或 **40pt `.ultraLight`** |
| 工具栏图标 | 16pt `.semibold` | **16pt `.semibold`** |
| 列表图标 | `.title2` | **`.title2`** (约 22pt) |
| 输入控件图标 | 17pt `.medium` | **17pt `.medium`** |

**关键改动**：
- 空状态图标字重从 `.ultraLight` → `.thin`（更清晰）

---

## 二、实施计划（按优先级排序）

### Phase 1：全局设计规范定义（30分钟）

**任务 1.1：扩展 DesignSystem.Metrics**
```swift
public enum Metrics {
    // 尺寸
    public static let inputControlSize: CGFloat = 44
    public static let inputIconSize: CGFloat = 16
    public static let microphoneIconSize: CGFloat = 17
    
    // 圆角
    public static let cornerRadiusStandard: CGFloat = 16
    public static let cornerRadiusSmall: CGFloat = 8
    public static let cornerRadiusButton: CGFloat = 22
    public static let cornerRadiusSheet: CGFloat = 20
    
    // 间距
    public static let contentHorizontalPadding: CGFloat = 20
    public static let cardSpacing: CGFloat = 16
    public static let compactSpacing: CGFloat = 12
    public static let sectionTitleSpacing: CGFloat = 20
    public static let contentInnerPadding: CGFloat = 16
    
    // 行间距
    public static let lineSpacingBody: CGFloat = 6
    public static let lineSpacingCompact: CGFloat = 4
    public static let lineSpacingTitle: CGFloat = 8
}
```

**文件**：`Moi/Utilities/DesignSystem.swift`

---

### Phase 2：简单全局替换（1小时）

#### 任务 2.1：统一卡片圆角 [#3]
**难度**：⭐ 简单  
**影响范围**：所有视图

**操作**：
1. 搜索所有 `.cornerRadius(20)` → 改为 `.cornerRadius(MoiDesign.Metrics.cornerRadiusStandard)`
2. 搜索所有 `.cornerRadius(16)` → 改为 `.cornerRadius(MoiDesign.Metrics.cornerRadiusStandard)`
3. 保留小标签的 `.cornerRadius(8)` → 改为 `.cornerRadius(MoiDesign.Metrics.cornerRadiusSmall)`

**预期文件**：
- TodayView.swift
- AskView.swift
- StoryView.swift
- RefineComparisonCard.swift
- CalendarSheetView.swift
- AskResultSheet.swift
- SettingsSheet.swift (TextField 背景)

---

#### 任务 2.2：统一行间距 [#8]
**难度**：⭐ 简单  
**影响范围**：所有带文本内容的视图

**操作**：
1. 搜索所有 `.lineSpacing(6)` → 改为 `.lineSpacing(MoiDesign.Metrics.lineSpacingBody)`
2. 搜索所有 `.lineSpacing(4)` → 改为 `.lineSpacing(MoiDesign.Metrics.lineSpacingCompact)`
3. 搜索所有 `.lineSpacing(5)` → 根据上下文改为 `lineSpacingBody` 或 `lineSpacingCompact`

**预期文件**：
- TodayView.swift
- AskView.swift
- StoryView.swift
- AskResultSheet.swift

---

#### 任务 2.3：统一 Section 标签字体 [#9]
**难度**：⭐ 简单  
**影响范围**：TodayView, AskView, StoryView

**操作**：
1. 搜索 `.caption2.bold()` → 改为 `.caption.bold()`
2. 具体位置：
   - TodayView: "Daily Reflection", "Sparkles", "YOUR ANSWER"
   - AskView: "PAST GUIDANCE"
   - StoryView: "MONTHLY LETTERS"

---

#### 任务 2.4：统一空状态图标 [#4]
**难度**：⭐ 简单  
**影响范围**：AskView, StoryView

**操作**：
1. 搜索 `.font(.system(size: 48, weight: .ultraLight))`
2. 改为 `.font(.system(size: 48, weight: .thin))`

**预期文件**：
- AskView.swift
- StoryView.swift

---

### Phase 3：间距调整（1小时）

#### 任务 3.1：统一水平内边距 [#6]
**难度**：⭐⭐ 中等  
**影响范围**：所有主视图

**操作**：
1. 将 `.padding(.horizontal)` 改为 `.padding(.horizontal, MoiDesign.Metrics.contentHorizontalPadding)`
2. 特别注意空状态文本的 `36pt` 过宽边距 → 改为标准 `20pt`

**测试重点**：确保内容不贴边，视觉平衡

---

#### 任务 3.2：增加卡片列表间距 [#5]
**难度**：⭐⭐ 中等  
**影响范围**：AskView, StoryView

**操作**：
1. AskView 历史记录：`VStack(spacing: 12)` → `VStack(spacing: MoiDesign.Metrics.cardSpacing)`
2. StoryView 信件列表：同上
3. TodayView Sparkles 保持紧凑：`VStack(spacing: MoiDesign.Metrics.compactSpacing)`

---

#### 任务 3.3：增加 Section 标题间距 [#7]
**难度**：⭐⭐ 中等  
**影响范围**：TodayView, AskView, StoryView

**操作**：
1. 在 Section 标题 VStack 后添加：`.padding(.bottom, 4)`
2. 或调整 VStack spacing 从 16 → 20

**示例**：
```swift
VStack(alignment: .leading, spacing: MoiDesign.Metrics.sectionTitleSpacing) {
    Text("PAST GUIDANCE")
        .font(.caption.bold())
    // 内容...
}
```

---

### Phase 4：iOS 26/27 新特性应用（2小时）

#### 任务 4.1：Ask 结果卡片使用 Liquid Glass [#14]
**难度**：⭐⭐⭐ 复杂  
**影响范围**：AskResultSheet.swift

**改动前**：
```swift
VStack {
    // 内容
}
.padding(20)
.background(MoiDesign.Colors.secondaryBackground)
.cornerRadius(20)
```

**改动后**（iOS 26+）：
```swift
VStack {
    // 内容
}
.padding(20)
.background {
    if #available(iOS 26.0, *) {
        RoundedRectangle(cornerRadius: MoiDesign.Metrics.cornerRadiusStandard)
            .fill(.regularMaterial)  // 或 .glassEffect(.regular)
    } else {
        RoundedRectangle(cornerRadius: MoiDesign.Metrics.cornerRadiusStandard)
            .fill(MoiDesign.Colors.secondaryBackground)
    }
}
```

**测试重点**：
- 深色/浅色模式下的可读性
- 与背景的层次对比
- 不要与输入栏的玻璃效果冲突

---

#### 任务 4.2：Story 卡片使用 Liquid Glass [#14]
**难度**：⭐⭐⭐ 复杂  
**影响范围**：StoryView.swift

**改动位置**：Story 列表项的卡片背景

**方案选择**：
- **方案 A**：使用 `.glassEffect(.thin)` - 轻薄玻璃，适合列表
- **方案 B**：使用 `.regularMaterial` - iOS 18 兼容的材质
- **方案 C**：保持当前但增强阴影

**推荐**：方案 A（iOS 26+）+ 方案 B（iOS 18 降级）

---

#### 任务 4.3：SF Symbols 动画 [#22]
**难度**：⭐⭐ 中等  
**影响范围**：MoiInputBar (麦克风), TodayView (完成对勾)

**改动 1：麦克风录音动画**
```swift
Image(systemName: isRecording ? "waveform" : "mic.fill")
    .symbolEffect(.pulse, isActive: isRecording)  // iOS 26+
```

**改动 2：完成对勾动画**（TodayView）
```swift
Image(systemName: "checkmark.circle.fill")
    .symbolEffect(.bounce, value: showCheckmarkAnimation)  // iOS 26+
```

---

### Phase 5：交互反馈增强（1小时）

#### 任务 5.1：输入框焦点状态 [#11]
**难度**：⭐⭐ 中等  
**影响范围**：MoiInputBar

**改动**：
```swift
TextField(placeholder, text: $text)
    .focused($isFocused)
// ...
.glassEffect(isFocused ? .regular.highlighted() : .regular, in: Capsule())
```

**测试**：点击输入框时是否有微妙的高亮变化

---

### Phase 6：内容优化（1.5小时）

#### 任务 6.1：日期格式统一 [#23]
**难度**：⭐⭐ 中等  
**影响范围**：DateExtensions.swift + 所有显示日期的地方

**操作**：
1. 在 `DateExtensions.swift` 中定义统一格式化方法
2. 统一列表项日期格式：`"MMM d"` (Aug 12)
3. 统一详情页日期格式：`"MMMM d, yyyy"` (August 12, 2026)
4. 时间戳格式：`"MMM d, h:mm a"` (Aug 12, 2:30 PM)

---

#### 任务 6.2：空状态文案优化 [#24]
**难度**：⭐ 简单  
**影响范围**：AskView, StoryView

**改动**：
- AskView: "No Ask Record Yet" → "Ask your first question"
- StoryView: "No Stories Yet" → "Your story begins with today"

---

#### 任务 6.3：Ask 结果添加时间戳 [#30]
**难度**：⭐⭐ 中等  
**影响范围**：AskView 列表项

**改动**：
```swift
HStack {
    Text(record.dilemma)
    Spacer()
    Text(record.date, format: .dateTime.month().day().hour().minute())  // "Aug 12, 2:30 PM"
        .font(.caption)
}
```

---

### Phase 7：特定页面增强（2小时）

#### 任务 7.1：Onboarding 进度指示器 [#26]
**难度**：⭐⭐ 中等  
**影响范围**：OnboardingView.swift

**添加组件**：
```swift
HStack(spacing: 8) {
    ForEach(1...3, id: \.self) { index in
        Circle()
            .fill(index == step ? MoiDesign.Colors.primary : Color.gray.opacity(0.3))
            .frame(width: 8, height: 8)
    }
}
.padding(.top, 40)
```

---

#### 任务 7.2：Story 年份分组 [#29]
**难度**：⭐⭐⭐ 复杂  
**影响范围**：StoryView.swift

**改动**：
1. 将 `availableStories` 按年份分组
2. 使用 `ForEach` + `Section` 渲染
3. Section header 显示年份

**伪代码**：
```swift
let groupedStories = Dictionary(grouping: availableStories) { story in
    // 从 yearMonth 提取年份
}

ForEach(groupedStories.keys.sorted(by: >), id: \.self) { year in
    Section(header: Text(String(year)).font(.title3.bold())) {
        ForEach(groupedStories[year]!) { story in
            // 卡片
        }
    }
}
```

---

#### 任务 7.3：ScrollView 嵌套优化 [#20]
**难度**：⭐⭐⭐ 复杂  
**影响范围**：TodayView, AskView, StoryView

**评估**：
- 当前嵌套层级是否真的影响性能？
- 使用 `List` 会破坏现有的自定义布局
- **建议**：先用 Instruments 测试，再决定是否优化

**方案**：
- 保持 `ScrollView` 但减少 VStack 嵌套
- 或使用 `LazyVStack` 替代 VStack

---

## 三、实施顺序建议

### 第一天（3-4小时）
1. ✅ Phase 1：定义全局设计规范（30分钟）
2. ✅ Phase 2：简单全局替换（1小时）
3. ✅ Phase 3：间距调整（1小时）
4. ✅ Phase 6.1-6.2：内容优化（简单部分）（1小时）

**预期成果**：视觉统一性明显提升，代码可维护性增强

---

### 第二天（3-4小时）
1. ✅ Phase 4：iOS 26/27 新特性应用（2小时）
2. ✅ Phase 5：交互反馈增强（1小时）
3. ✅ Phase 6.3：Ask 时间戳（30分钟）

**预期成果**：iOS 26/27 特性充分利用，交互体验提升

---

### 第三天（2-3小时）
1. ✅ Phase 7.1：Onboarding 进度指示（1小时）
2. ✅ Phase 7.2：Story 年份分组（1-2小时）

**预期成果**：特定页面体验优化

---

### 第四天（可选，性能优化）
1. ⚠️ Phase 7.3：ScrollView 嵌套优化（需先评估必要性）

---

## 四、测试检查清单

### 每个 Phase 完成后必须测试：

#### 视觉检查
- [ ] 浅色模式显示正常
- [ ] 深色模式显示正常
- [ ] 高对比度模式可用
- [ ] 动态字体（最大辅助级别）不截断内容

#### 交互检查
- [ ] 按钮点击区域 ≥ 44×44pt
- [ ] 焦点状态明显可见
- [ ] 动画流畅不卡顿

#### 兼容性检查
- [ ] iOS 27 模拟器运行正常
- [ ] iOS 18.6 实机测试通过（iPhoneXs）
- [ ] iOS 27 beta 实机测试通过（iPhone 15 Pro）

#### 无障碍检查
- [ ] VoiceOver 读取顺序正确
- [ ] 所有交互元素有标签
- [ ] 对比度符合 WCAG AA 标准

---

## 五、风险评估

### 高风险改动（需谨慎）

1. **ScrollView 嵌套优化 [#20]**
   - 可能破坏现有布局
   - 建议：先性能测试，后决策

2. **Story 年份分组 [#29]**
   - 数据结构变化
   - 需要迁移逻辑
   - 建议：做好备份

3. **Liquid Glass 效果应用 [#14]**
   - 可能影响可读性
   - 需要多场景测试
   - 建议：保留降级方案

### 低风险改动（可快速执行）

1. 圆角统一 [#3]
2. 行间距统一 [#8]
3. 字体大小调整 [#9]
4. 空状态图标 [#4]
5. 间距调整 [#5, #6, #7]
6. 文案优化 [#24]

---

## 六、关于 Settings Language 行高问题

**结论**：这是 **iOS 原生 List 中 Picker 的正常行为**。

**原因**：
- Picker 使用 `.menu` 样式会自动增加行高
- 系统为下拉菜单图标预留空间
- TextField 行不包含 Picker，因此行高正常

**是否需要修复**：❌ 不需要

**如果一定要统一高度**（不推荐）：
- 方案 A：将 Picker 改为导航链接 → 新页面选择
- 方案 B：使用 `.segmented` Picker（但不适合此场景）
- 方案 C：接受原生行为（推荐）

---

## 七、设计层级变动对比

### 改动 1：卡片背景从纯色 → Liquid Glass

**改动前**：
```
视觉层级：背景 → 卡片（纯色） → 内容
对比度：明确的边界
```

**改动后**：
```
视觉层级：背景 → 卡片（半透明玻璃） → 内容
对比度：柔和的边界，更强的层次感
```

**优势**：
- ✅ 更符合 iOS 26/27 设计趋势
- ✅ 视觉更轻盈、现代
- ✅ 背景内容若有变化，玻璃会产生动态效果

**劣势**：
- ⚠️ 深色模式下可能降低对比度
- ⚠️ 需要仔细调整玻璃透明度

**测试重点**：
- 深色模式下文字可读性
- 与背景的层次区分
- 不要过度使用（只在关键卡片使用）

---

### 改动 2：间距增大

**改动前**：
```
内容紧凑，信息密度高
适合快速扫视
```

**改动后**：
```
内容舒展，视觉呼吸感强
适合专注阅读
```

**优势**：
- ✅ 更易于点击（不容易误触）
- ✅ 视觉更放松
- ✅ 符合 iOS 27 设计趋势

**劣势**：
- ⚠️ 可能需要更多滚动
- ⚠️ 小屏设备可见内容减少

**缓解措施**：
- 主要列表增大间距（16pt）
- 紧凑列表保持小间距（12pt）
- 平衡信息密度与舒适度

---

## 八、总结

### 核心原则
1. **全局优先**：先定义设计规范，再局部应用
2. **简单先行**：从全局替换开始，复杂改动放后
3. **充分测试**：每个阶段完成后立即测试
4. **保留降级**：iOS 26/27 新特性必须有 iOS 18 降级方案
5. **可逆改动**：所有改动都应该易于回滚

### 预期收益
- **视觉统一性**：提升 30%（圆角、间距、字体统一）
- **iOS 26/27 现代感**：提升 40%（Liquid Glass、动画）
- **代码可维护性**：提升 50%（设计 token 化）
- **用户体验**：提升 20%（交互反馈、内容优化）

### 时间投入
- **最小可行版本**（Phase 1-3 + 6.1-6.2）：3-4 小时
- **完整版本**（全部 Phase）：8-10 小时
- **性能优化**（可选）：2-3 小时

---

**文档状态**：✅ 准备就绪，可开始实施
