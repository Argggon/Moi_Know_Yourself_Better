import SwiftUI
import SwiftData

public struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var logs: [DailyLog]
    @Query private var notes: [SpontaneousNote]
    @Query private var fingerprints: [QuestionFingerprint]
    
    public var onOpenSettings: () -> Void
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    @State private var answerInput: String = ""
    @State private var refinedAnswerText: String = ""
    @State private var isProcessingRefine: Bool = false
    @State private var showRefineComparison: Bool = false
    @State private var showCalendarSheet: Bool = false
    @State private var showCheckmarkAnimation: Bool = false
    
    public init(onOpenSettings: @escaping () -> Void = {}) {
        self.onOpenSettings = onOpenSettings
    }
    
    private var todayLog: DailyLog {
        if let existing = logs.first(where: { Calendar.current.isDateInToday($0.date) }) {
            return existing
        } else {
            let newLog = DailyLog(
                date: Date(),
                questionEn: "How is today's atmosphere subtly influencing your energy?",
                questionZh: "今天周围的氛围，此刻正如何微弱地影响着你的状态与心情？",
                depthLevel: "light"
            )
            modelContext.insert(newLog)
            return newLog
        }
    }
    
    private var todayNotes: [SpontaneousNote] {
        notes.filter { Calendar.current.isDateInToday($0.date) }
            .sorted { $0.date > $1.date }
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                
                // SECTION 1: DAILY REFLECTION
                VStack(alignment: .leading, spacing: 16) {
                    Text("Daily Reflection")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(MoiDesign.Colors.primaryText)
                    
                    // Emphasized Date
                    Text(todayLog.date.formattedHeaderString(language: "en"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(MoiDesign.Colors.secondaryText)
                    
                    // Question Text
                    Text(todayLog.questionEn.isEmpty ? todayLog.questionZh : todayLog.questionEn)
                        .font(.title3)
                        .fontWeight(.medium)
                        .lineSpacing(MoiDesign.Metrics.lineSpacingBody)
                        .foregroundColor(MoiDesign.Colors.primaryText)
                    
                    // Display Answer OR Flat Input Bar
                    if todayLog.isCompleted {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("YOUR ANSWER")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(MoiDesign.Colors.secondaryText)
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            
                            Text(todayLog.isRefinedUsed ? todayLog.refinedAnswer : todayLog.rawAnswer)
                                .font(.body)
                                .lineSpacing(MoiDesign.Metrics.lineSpacingBody)
                                .foregroundColor(MoiDesign.Colors.primaryText)
                        }
                        .padding(.top, 4)
                    } else if !showRefineComparison {
                        MoiInputBar(
                            text: $answerInput,
                            placeholder: "Write your answer...",
                            isRecording: speechRecognizer.isRecording,
                            onVoiceInput: {
                                if speechRecognizer.isRecording {
                                    speechRecognizer.stopTranscribing()
                                    answerInput = speechRecognizer.transcript
                                } else {
                                    speechRecognizer.requestPermissions()
                                    speechRecognizer.startTranscribing()
                                }
                            },
                            onSubmit: {
                                speechRecognizer.stopTranscribing()
                                isProcessingRefine = true
                                Task {
                                    let refined = (try? await LLMService.shared.refineAnswer(question: todayLog.questionEn, rawAnswer: answerInput)) ?? answerInput
                                    await MainActor.run {
                                        self.refinedAnswerText = refined
                                        self.isProcessingRefine = false
                                        self.showRefineComparison = true
                                    }
                                }
                            }
                        )
                        
                        if isProcessingRefine {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Refining your words...")
                                    .font(.caption)
                                    .foregroundColor(MoiDesign.Colors.secondaryText)
                            }
                            .padding(.top, 4)
                        }
                    }
                    
                    // Refine Comparison Card
                    if showRefineComparison {
                        RefineComparisonCard(
                            originalText: $answerInput,
                            refinedText: $refinedAnswerText
                        ) { selectedText in
                            todayLog.rawAnswer = answerInput
                            todayLog.refinedAnswer = selectedText
                            todayLog.isRefinedUsed = (selectedText == refinedAnswerText)
                            todayLog.isCompleted = true
                            
                            withAnimation(.spring()) {
                                showRefineComparison = false
                                showCheckmarkAnimation = true
                            }
                        }
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // SECTION 2: SPARKLES
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sparkles")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(MoiDesign.Colors.primaryText)
                        
                        Text("Your spontaneous thoughts & raw moments.")
                            .font(.subheadline)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                    }
                    
                    // Spontaneous Notes Timeline List
                    if !todayNotes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(todayNotes) { note in
                                HStack(alignment: .top, spacing: 12) {
                                    Text(note.date, format: .dateTime.hour().minute())
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(MoiDesign.Colors.secondaryText)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(MoiDesign.Colors.secondaryBackground)
                                        .cornerRadius(MoiDesign.Metrics.cornerRadiusSmall)
                                    
                                    Text(note.content)
                                        .font(.body)
                                        .lineSpacing(MoiDesign.Metrics.lineSpacingCompact)
                                        .foregroundColor(MoiDesign.Colors.primaryText)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    // Spontaneous Note Entry Bar
                    SpontaneousNoteEntryView()
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .moiNativeNavigationBehavior()
        .toolbar {
            if #available(iOS 26.0, *) {
                ToolbarItem(placement: .topBarLeading) {
                    navigationTitleLabel("Today")
                }
                .sharedBackgroundVisibility(.hidden)
            } else {
                ToolbarItem(placement: .topBarLeading) {
                    navigationTitleLabel("Today")
                }
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: { showCalendarSheet = true }) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .semibold))
                }
                .accessibilityLabel("Calendar")
                
                UserAvatarButton(action: onOpenSettings)
            }
        }
        .sheet(isPresented: $showCalendarSheet) {
            CalendarSheetView()
        }
        .onAppear {
            if todayLog.questionZh.isEmpty && todayLog.questionEn.isEmpty {
                Task {
                    let (qZh, qEn, depth, _) = (try? await LLMService.shared.generateDailyQuestion(
                        recentTags: fingerprints.prefix(7).flatMap { $0.tags },
                        depthWindow: ["light"],
                        weatherInfo: "Sunny 22°C"
                    )) ?? ("今天的微风让你想起了什么？", "What does today's breeze remind you of?", "light", ["sensory"])
                    
                    await MainActor.run {
                        todayLog.questionZh = qZh
                        todayLog.questionEn = qEn
                        todayLog.depthLevel = depth
                    }
                }
            }
        }
    }

    private func navigationTitleLabel(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.title.bold())
            .fixedSize(horizontal: true, vertical: false)
            .accessibilityAddTraits(.isHeader)
    }
}
