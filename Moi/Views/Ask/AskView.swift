import SwiftUI
import SwiftData

public struct AskView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [AskRecord]
    @Query private var logs: [DailyLog]
    
    public var onOpenSettings: () -> Void
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    @State private var queryText: String = ""
    @State private var isProcessing: Bool = false
    @State private var activeResultItem: AskResultItem? = nil
    @State private var showInfoPopover: Bool = false
    
    public init(onOpenSettings: @escaping () -> Void = {}) {
        self.onOpenSettings = onOpenSettings
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                
                // TOP FLAT BAR INPUT FIELD
                VStack(alignment: .leading, spacing: 12) {
                    MoiInputBar(
                        text: $queryText,
                        placeholder: "Ask Moi Anything...",
                        isRecording: speechRecognizer.isRecording,
                        onVoiceInput: {
                            if speechRecognizer.isRecording {
                                speechRecognizer.stopTranscribing()
                                queryText = speechRecognizer.transcript
                            } else {
                                speechRecognizer.requestPermissions()
                                speechRecognizer.startTranscribing()
                            }
                        },
                        onSubmit: {
                            speechRecognizer.stopTranscribing()
                            isProcessing = true
                            Task {
                                let profileText = ProfileStorageManager.shared.loadUserProfile()
                                let completedLogs = logs.filter { $0.isCompleted }
                                let quotes = completedLogs.map { "\"\($0.isRefinedUsed ? $0.refinedAnswer : $0.rawAnswer)\"" }
                                
                                let (stance, reasoning) = (try? await LLMService.shared.generateAskGuidance(
                                    dilemma: queryText,
                                    userProfileMarkdown: profileText,
                                    relevantQuotes: quotes
                                )) ?? ("Leaning towards taking a thoughtful step forward", "Based on your recent reflections, taking proactive steps aligns closely with your values.")
                                
                                let newRecord = AskRecord(
                                    id: UUID(),
                                    date: Date(),
                                    dilemma: queryText,
                                    stanceHeadline: stance,
                                    explanation: reasoning
                                )
                                
                                await MainActor.run {
                                    modelContext.insert(newRecord)
                                    self.isProcessing = false
                                    self.activeResultItem = AskResultItem(record: newRecord)
                                    self.queryText = ""
                                }
                            }
                        }
                    )
                    
                    if isProcessing {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Consulting your past self...")
                                .font(.caption)
                                .foregroundColor(MoiDesign.Colors.secondaryText)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // PAST GUIDANCE HISTORY OR CENTERED EMPTY STATE
                if records.isEmpty {
                    VStack(spacing: 18) {
                        Spacer(minLength: 40)
                        
                        Image(systemName: "questionmark.bubble")
                            .font(.system(size: 48, weight: .ultraLight))
                            .foregroundColor(MoiDesign.Colors.tertiaryText)
                        
                        Text("No Ask Record Yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(MoiDesign.Colors.primaryText)
                        
                        Text("Ask Moi about your real-life choices and dilemmas to receive guidance grounded in your past reflections.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                            .lineSpacing(MoiDesign.Metrics.lineSpacingBody)
                            .padding(.horizontal, 36)
                        
                        Button(action: { showInfoPopover = true }) {
                            HStack(spacing: 4) {
                                Text("Learn more about Ask Moi")
                                Image(systemName: "chevron.right")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(MoiDesign.Colors.primary)
                        }
                        .padding(.top, 6)
                        
                        Spacer(minLength: 60)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("PAST GUIDANCE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                        
                        VStack(spacing: 12) {
                            ForEach(records.sorted(by: { $0.date > $1.date })) { record in
                                Button(action: {
                                    activeResultItem = AskResultItem(record: record)
                                }) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(record.dilemma)
                                                .font(.headline)
                                                .foregroundColor(MoiDesign.Colors.primaryText)
                                                .lineLimit(1)
                                            Spacer()
                                            Text(record.date, format: .dateTime.month().day())
                                                .font(.caption)
                                                .foregroundColor(MoiDesign.Colors.tertiaryText)
                                        }
                                        
                                        Text(record.stanceHeadline)
                                            .font(.subheadline)
                                            .foregroundColor(MoiDesign.Colors.secondaryText)
                                            .lineLimit(2)
                                    }
                                    .padding()
                                    .background(MoiDesign.Colors.secondaryBackground)
                                    .cornerRadius(MoiDesign.Metrics.cornerRadiusStandard)
                                }
                            }
                        }
                        
                        // Bottom Hyperlink
                        Button(action: { showInfoPopover = true }) {
                            HStack(spacing: 4) {
                                Text("Learn more about Ask Moi")
                                Image(systemName: "chevron.right")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(MoiDesign.Colors.primary)
                        }
                        .padding(.top, 12)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .moiNativeNavigationBehavior()
        .toolbar {
            if #available(iOS 26.0, *) {
                ToolbarItem(placement: .topBarLeading) {
                    navigationTitleLabel("Ask")
                }
                .sharedBackgroundVisibility(.hidden)
            } else {
                ToolbarItem(placement: .topBarLeading) {
                    navigationTitleLabel("Ask")
                }
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                // Far-Right Settings Avatar ONLY
                UserAvatarButton(action: onOpenSettings)
            }
        }
        .sheet(item: $activeResultItem) { item in
            AskResultSheet(record: item.record)
        }
        .sheet(isPresented: $showInfoPopover) {
            AskInfoSheet()
        }
    }

    private func navigationTitleLabel(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.title.bold())
            .fixedSize(horizontal: true, vertical: false)
            .accessibilityAddTraits(.isHeader)
    }
}

public struct AskResultItem: Identifiable {
    public let id = UUID()
    public let record: AskRecord
}

public struct AskInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Understanding Ask Moi")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Your Personal Inner Compass")
                        .font(.headline)
                        .foregroundColor(MoiDesign.Colors.primary)
                    
                    Text("When facing life choices, dilemmas, or hesitation, Ask Moi synthesizes your past reflections and user persona to offer clear decision guidance.")
                        .font(.body)
                        .lineSpacing(MoiDesign.Metrics.lineSpacingBody)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How Guidance Works")
                            .font(.headline)
                        
                        Text("1. Evidence-Based Stance:\nAsk Moi cross-references your current dilemma with your accumulated Q&A history and Markdown persona to recommend a clear, non-judgmental direction.")
                            .font(.subheadline)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                            .lineSpacing(MoiDesign.Metrics.lineSpacingCompact)
                        
                        Text("2. Direct Quotes from Past Self:\nEvery stance is backed by direct quotes from your past answers, reminding you of your core values.")
                            .font(.subheadline)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                            .lineSpacing(MoiDesign.Metrics.lineSpacingCompact)
                        
                        Text("3. Non-Coercive Reflection:\nIf a recommended stance doesn't feel right to you, it serves as a mirror — revealing that you already know your true answer.")
                            .font(.subheadline)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                            .lineSpacing(MoiDesign.Metrics.lineSpacingCompact)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Privacy & Data Protection")
                            .font(.headline)
                        
                        Text("• Private Local History: Your decision queries and synthesized guidance remain strictly on your device.\n• Zero Third-Party Sharing: Your personal dilemmas are never logged or stored on external servers.")
                            .font(.subheadline)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                            .lineSpacing(MoiDesign.Metrics.lineSpacingCompact)
                    }
                }
                .padding()
            }
            .navigationTitle("Ask Moi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    MoiSheetCloseButton()
                }
            }
        }
    }
}
