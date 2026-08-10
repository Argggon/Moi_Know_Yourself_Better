import Foundation

/// Service layer interfacing with backend LLM API endpoints
public final class LLMService {
    public static let shared = LLMService()
    
    // Configurable API base URL & API Key (stored in settings or app state)
    public var baseURLString: String = "https://api.deepseek.com/v1"
    public var apiKey: String = ""
    
    private init() {}
    
    // MARK: - 1. Refine User Answer
    public func refineAnswer(question: String, rawAnswer: String) async throws -> String {
        // Fallback mock if API key is empty for local trial
        if apiKey.isEmpty {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return rawAnswer + "（经过微光整理：保留了内省感与文字质地）"
        }
        
        let systemPrompt = """
        你是一个极其柔和、敏感的文字编辑。请对用户的回答进行轻微润色，使其语言更加自然流畅，但严格保留原有的全部事实、情绪与语气风格。不要添加说教或客套话。
        """
        
        let userContent = "问题：\(question)\n原始回答：\(rawAnswer)"
        return try await makeChatCompletion(systemPrompt: systemPrompt, userContent: userContent)
    }
    
    // MARK: - 2. Daily Question Generation
    public func generateDailyQuestion(
        recentTags: [String],
        depthWindow: [String],
        weatherInfo: String?,
        lang: String = "zh"
    ) async throws -> (questionZh: String, questionEn: String, depthLevel: String, tags: [String]) {
        if apiKey.isEmpty {
            try await Task.sleep(nanoseconds: 800_000_000)
            if let weather = weatherInfo, weather.contains("雨") {
                return (
                    "今天的下雨天，让你的精力更集中，还是更想蜷缩起来休息？",
                    "Does today's rain make you more focused, or make you want to curl up and rest?",
                    "light",
                    ["weather", "sensory"]
                )
            } else {
                return (
                    "如果今天有一小时完全属于你自己，不受任何人打扰，你会做些什么？",
                    "If you had one completely undisturbed hour to yourself today, what would you do?",
                    "medium",
                    ["time", "autonomy"]
                )
            }
        }
        
        let systemPrompt = """
        你是 Moi 应用的问题生成引擎。请为用户生成【一个】今天的问答题目。
        要求：
        1. 绝不重复历史 Tag：\(recentTags.joined(separator: ", "))。
        2. 参考天气：\(weatherInfo ?? "无天气数据")。
        3. 语言温柔、生动、具有映照感，1-2句话即可。
        4. 必须输出 JSON 格式：{"question_zh": "...", "question_en": "...", "depth_level": "light/medium/deep", "tags": ["..."]}
        """
        
        let jsonResponse = try await makeChatCompletion(systemPrompt: systemPrompt, userContent: "请生成今日问题。")
        
        // Parse JSON
        if let data = jsonResponse.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let qZh = json["question_zh"] as? String,
           let qEn = json["question_en"] as? String,
           let depth = json["depth_level"] as? String,
           let tags = json["tags"] as? [String] {
            return (qZh, qEn, depth, tags)
        }
        
        return ("今天外面的气温与天气，此刻正如何微弱地影响着你的心情？", "How is today's weather subtly influencing your mood right now?", "light", ["weather"])
    }
    
    // MARK: - 3. Two-Step Monthly Story Chain
    public func executeMonthlyStoryChain(
        monthYearKey: String,
        nickname: String,
        existingProfileMarkdown: String,
        monthLogsSummary: String
    ) async throws -> (updatedProfileMarkdown: String, storyLetterMarkdown: String) {
        
        // Step 1: Profile Consolidation (Analysis)
        let step1SystemPrompt = """
        你是一个心理洞察专家。请读取用户过去的 Markdown 动态性格画像（old_profile）以及当月的所有问答与即时感受记录（raw_logs）。
        请更新并输出全新的 Markdown 格式【用户性格画像 (`user_profile.md`)】。
        要求：使用自然流畅、富有温度的自然语言文本（Vibe 风格），归纳用户本月展现的新特质、情绪触发点与价值观，不要使用死板的键值对。
        """
        let step1UserContent = "旧画像：\n\(existingProfileMarkdown)\n\n当月日志：\n\(monthLogsSummary)"
        
        let updatedProfileMarkdown: String
        if apiKey.isEmpty {
            try await Task.sleep(nanoseconds: 1_200_000_000)
            updatedProfileMarkdown = """
            # Moi 用户性格画像 (User Persona) - Updated \(monthYearKey)
            
            ## 核心特质与感官倾向
            - 具有极高的内省倾向与情绪敏感度。在雨天与安静环境下能够展现出极高的专注力。
            - 倾向于独处充电，对无意义的社交消耗感到疲惫。
            
            ## 价值取向与边界
            - 珍视自主权与精神宁静，胜过外部名利与管人权限。
            - 追求创作与深度的成就感。
            """
        } else {
            updatedProfileMarkdown = try await makeChatCompletion(systemPrompt: step1SystemPrompt, userContent: step1UserContent)
        }
        
        // Step 2: Poetic Story Letter Generation (Writing)
        let step2SystemPrompt = """
        你是一个温柔的文字映照者。请根据更新后的用户性格画像以及当月关键记录，为用户撰写一封月度回顾信件。
        结构：
        1. 情绪天气
        2. 关键模式与引用（斜体引用用户原话）
        3. 结尾寄语
        落款：Your Moi, \(monthYearKey)
        """
        let step2UserContent = "最新画像：\n\(updatedProfileMarkdown)\n\n当月记录：\n\(monthLogsSummary)"
        
        let storyLetterMarkdown: String
        if apiKey.isEmpty {
            try await Task.sleep(nanoseconds: 1_200_000_000)
            storyLetterMarkdown = """
            # 亲爱的 \(nickname)：
            
            在这个月里，你的情绪像是一场安静的蓄雨。
            
            你曾写下：*“避开无意义的社交”*。在雨天的咖啡馆与黑胶唱片的音乐里，你找到了属于自己的庇护所。比起顺从别人的期待，你正在学会守护属于自己的节奏。
            
            愿你在接下来的日子里，继续安然守护这片属于你的安静。
            
            Your Moi, \(monthYearKey)
            """
        } else {
            storyLetterMarkdown = try await makeChatCompletion(systemPrompt: step2SystemPrompt, userContent: step2UserContent)
        }
        
        return (updatedProfileMarkdown, storyLetterMarkdown)
    }
    
    // MARK: - 4. Ask Decision Synthesizer
    public func generateAskGuidance(
        dilemma: String,
        userProfileMarkdown: String,
        relevantQuotes: [String]
    ) async throws -> (stanceHeadline: String, explanation: String) {
        
        if apiKey.isEmpty {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return (
                "建议暂缓，这或许并非你真正渴望的路径 →",
                "从你过往的选择来看，你极度珍视自主权与精神宁静。你曾在过去的记录中坦言 *“比起管人，更想专注在创造性的工作本身”*。牺牲个人时间换取的收益，大概率会背离你的核心价值感。"
            )
        }
        
        let systemPrompt = """
        你是 Moi 的决策指引引擎。用户正处于纠结中。
        要求：
        1. 必须给出明确立场（如“建议暂缓”、“果断尝试”），绝对禁止模棱两可！
        2. 结合用户的 Markdown 动态画像与过往原话引用作为论据，解释 3-5 句。
        3. 必须输出 JSON 格式：{"stance_headline": "...", "explanation": "..."}
        """
        
        let userContent = "纠结的事：\(dilemma)\n用户画像：\n\(userProfileMarkdown)\n过往原话：\n\(relevantQuotes.joined(separator: "\n"))"
        let jsonResponse = try await makeChatCompletion(systemPrompt: systemPrompt, userContent: userContent)
        
        if let data = jsonResponse.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let stance = json["stance_headline"] as? String,
           let exp = json["explanation"] as? String {
            return (stance, exp)
        }
        
        return ("建议暂缓，跟随你内心的平静 →", "根据你过往的记录，保持自主权与内心秩序是你最重要的底线。")
    }
    
    // MARK: - Helper API Caller
    private func makeChatCompletion(systemPrompt: String, userContent: String) async throws -> String {
        guard let url = URL(string: "\(baseURLString)/chat/completions") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userContent]
            ],
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        throw URLError(.cannotParseResponse)
    }
}
