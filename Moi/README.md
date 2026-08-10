# Moi – Daily Self-Discovery iOS App (MVP v2.0)

> **一句话理念**：Ask yourself one question a day, and discover who you truly are.  
> **核心隐喻**：一面镜子——不评判，只映照。

---

## 📁 项目目录结构 (App File Architecture)

```
Moi/
├── App/
│   ├── MoiApp.swift                  # iOS @main 入口，配置 SwiftData ModelContainer
│   └── AppState.swift                # 全局应用状态控制
├── Models/
│   ├── DailyLog.swift                # 每日问答 SwiftData 持久化模型
│   ├── SpontaneousNote.swift         # 即时感受 SwiftData 持久化模型
│   ├── AskRecord.swift               # Ask 决策历史 SwiftData 模型
│   └── QuestionFingerprint.swift     # 提问去重指纹 SwiftData 模型
├── Services/
│   ├── LLMService.swift              # 大模型接口管理 (支持 DeepSeek/Gemini/OpenAI)
│   ├── ProfileStorageManager.swift   # user_profile.md 自然语言画像与 Story 信件本地读写
│   ├── SpeechRecognizer.swift        # iOS 端侧 Speech 听写引擎
│   └── LocalNotificationManager.swift# 本地定时推送 (每日 8:00 AM 与月度故事日)
├── Utilities/
│   ├── DesignSystem.swift            # 苹果极简主义设计系统 (配色、阴影、卡片样式)
│   └── DateExtensions.swift          # 中英双语日期格式化扩展
├── Views/
│   ├── MainTabView.swift             # 3 Tab 导航 (Today, Ask, Story) + 右上角头像入口
│   ├── Onboarding/
│   │   └── OnboardingView.swift      # 3 步极简新用户引导流程
│   ├── Today/
│   │   ├── TodayView.swift           # 今日问答主视图 (卡片、弹性展开输入、润色卡片)
│   │   ├── SpontaneousNoteEntryView.swift # 【即时感受】随时记录入口组件
│   │   ├── RefineComparisonCard.swift# 【左右滑动对比卡片】(Your words vs Refined)
│   │   └── CalendarSheetView.swift   # Health 风格全屏月度 7 列圆形日历
│   ├── Ask/
│   │   ├── AskView.swift             # 决策指引提问主视图
│   │   └── AskResultSheet.swift      # 特大号立场 + 原话引用 + 强制反思提示条
│   ├── Story/
│   │   ├── StoryView.swift           # 月度书信列表与手动触发生成
│   │   └── StoryDetailView.swift     # 全屏沉浸衬线体 (New York / 宋体) 书信阅读页
│   └── Settings/
│       └── SettingsSheet.swift       # 设置弹窗 (昵称、提醒时间、故事日、语言切换)
└── Package.swift                     # Swift Package 模块编译配置
```

---

## 🛠️ 打包、编译与发版指南 (Building & Archiving for App Store)

### 1. 用 Xcode 打开与运行
1. 打开 **Xcode** (建议 Xcode 15.0+ / Swift 5.10+)。
2. 选择 **File -> Open...**，打开 `Moi/` 目录或直接将 `Moi/` 文件夹拖入 Xcode 中。
3. 如果需要生成标准的 `.xcodeproj` 文件：
   - 打开 Xcode 菜单：**File -> New -> Project...** 选择 **iOS -> App**，Product Name 填 `Moi`。
   - Bundle Identifier 填你的开发者账号标识（例如 `com.yourcompany.moi`）。
   - 将 `Moi/` 目录下的所有子文件夹（`App`, `Models`, `Services`, `Utilities`, `Views`）直接拖入 Xcode 项目工程树即可。

### 2. 真机调试与运行
- 在 Target 设置中将 **Deployment Target** 设为 **iOS 17.0** 以上。
- 选定你的 iPhone 真机或 iOS 模拟器（如 iPhone 15 Pro），点击 **⌘ + R** 编译运行。

### 3. App Store 归档与打包 (Archiving & Distribution)
1. 在 Xcode 顶部 Scheme 列表中将目标选择为 **Any iOS Device (arm64)**。
2. 菜单栏选择 **Product -> Archive**。
3. 编译完成后，Organizer 窗口将自动弹起：
   - 点击 **Distribute App**。
   - 选择 **TestFlight & App Store** 或 **Ad Hoc / Development**（用于内部测试）。
   - 按照提示完成 Signing 与二进制文件上传。

---

## 🔑 LLM API 配置

在 `Services/LLMService.swift` 中：
- `baseURLString`: 默认配置为 `https://api.deepseek.com/v1`（也可更换为 OpenAI / Gemini 代理端点）。
- `apiKey`: 在 App 设置界面或环境变量中填入你的 API Key。**如果 API Key 为空，App 会自动进入平滑 Mock 模式**，方便界面交互测试。
