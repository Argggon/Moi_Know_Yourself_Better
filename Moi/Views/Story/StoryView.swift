import SwiftUI
import SwiftData

public struct MonthlyStoryItem: Identifiable {
    public var id: String { yearMonth }
    public let yearMonth: String
    public let title: String
    public let content: String
    
    public init(yearMonth: String, title: String, content: String) {
        self.yearMonth = yearMonth
        self.title = title
        self.content = content
    }
}

public struct StoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var logs: [DailyLog]
    
    public var onOpenSettings: () -> Void
    
    @State private var availableStories: [MonthlyStoryItem] = []
    @State private var selectedStory: MonthlyStoryItem? = nil
    @State private var showInfoPopover: Bool = false
    @State private var isGeneratingStory: Bool = false
    
    public init(onOpenSettings: @escaping () -> Void = {}) {
        self.onOpenSettings = onOpenSettings
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // GENERATION OVERLAY (FOR TESTING PHASE)
                if isGeneratingStory {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text("Drafting your monthly letter...")
                            .font(.subheadline)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(MoiDesign.Colors.secondaryBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                // STORIES LIST OR CENTERED EMPTY STATE
                if availableStories.isEmpty {
                    VStack(spacing: 18) {
                        Spacer(minLength: 60)
                        
                        Image(systemName: "envelope.open")
                            .font(.system(size: 48, weight: .ultraLight))
                            .foregroundColor(MoiDesign.Colors.tertiaryText)
                        
                        Text("No Stories Yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(MoiDesign.Colors.primaryText)
                        
                        Text("Keep recording your daily reflections and instant feelings to enrich your monthly letter.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                            .lineSpacing(5)
                            .padding(.horizontal, 36)
                        
                        Button(action: { showInfoPopover = true }) {
                            HStack(spacing: 4) {
                                Text("Learn more about Moi Story")
                                Image(systemName: "chevron.right")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(MoiDesign.Colors.primary)
                        }
                        .padding(.top, 6)
                        
                        Spacer(minLength: 80)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MONTHLY LETTERS")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                        
                        ForEach(availableStories) { item in
                            Button(action: {
                                selectedStory = item
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "envelope.fill")
                                        .font(.title2)
                                        .foregroundColor(MoiDesign.Colors.primary)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title)
                                            .font(.headline)
                                            .foregroundColor(MoiDesign.Colors.primaryText)
                                        Text(item.yearMonth)
                                            .font(.caption)
                                            .foregroundColor(MoiDesign.Colors.secondaryText)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline)
                                        .foregroundColor(MoiDesign.Colors.tertiaryText)
                                }
                                .padding()
                                .background(MoiDesign.Colors.secondaryBackground)
                                .cornerRadius(16)
                            }
                        }
                        
                        // Bottom Hyperlink
                        Button(action: { showInfoPopover = true }) {
                            HStack(spacing: 4) {
                                Text("Learn more about Moi Story")
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
        .navigationTitle("Story")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                // Test phase: Sparkles button on left
                Button(action: { triggerManualStoryGeneration() }) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(MoiDesign.Colors.primaryText)
                        .frame(width: 34, height: 34)
                        .background(MoiDesign.Colors.secondaryBackground)
                        .clipShape(Circle())
                }
                
                // Far-Right Settings Avatar
                UserAvatarButton(action: onOpenSettings)
            }
        }
        .sheet(item: $selectedStory) { story in
            StoryDetailView(story: story)
        }
        .sheet(isPresented: $showInfoPopover) {
            StoryInfoSheet()
        }
        .onAppear {
            loadStories()
        }
    }
    
    private func loadStories() {
        let files = ProfileStorageManager.shared.listAllStories()
        self.availableStories = files.map { fileURL in
            let filename = fileURL.lastPathComponent
            let ym = filename.replacingOccurrences(of: "Story_", with: "").replacingOccurrences(of: ".md", with: "")
            let content = ProfileStorageManager.shared.loadStoryLetter(monthYearKey: ym) ?? ""
            let title = content.components(separatedBy: .newlines).first?.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespaces) ?? "Letter of \(ym)"
            return MonthlyStoryItem(yearMonth: ym, title: title, content: content)
        }
    }
    
    private func triggerManualStoryGeneration() {
        isGeneratingStory = true
        Task {
            let currentYM = Date().formattedMonthYear(language: "en")
            let completedLogs = logs.filter { $0.isCompleted }
            let monthSummary = completedLogs.map { "[\($0.date)] Q: \($0.questionEn) A: \($0.refinedAnswer)" }.joined(separator: "\n")
            let profileText = ProfileStorageManager.shared.loadUserProfile()
            
            let (updatedProfile, letterContent) = (try? await LLMService.shared.executeMonthlyStoryChain(
                monthYearKey: currentYM,
                nickname: "you",
                existingProfileMarkdown: profileText,
                monthLogsSummary: monthSummary
            )) ?? (profileText, "# Letter of \(currentYM)\n\nDear self,\n\nLooking back at this past month...")
            
            try? ProfileStorageManager.shared.saveUserProfile(updatedProfile)
            try? ProfileStorageManager.shared.saveStoryLetter(monthYearKey: currentYM, content: letterContent)
            
            await MainActor.run {
                self.isGeneratingStory = false
                self.loadStories()
            }
        }
    }
}

public struct StoryInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Understanding Moi Story")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Your Monthly Introspective Mirror")
                        .font(.headline)
                        .foregroundColor(MoiDesign.Colors.primary)
                    
                    Text("Every month, Moi distills your 30 daily reflections and instant feelings into a poetic, introspective story letter written to your future self.")
                        .font(.body)
                        .lineSpacing(6)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How It Works")
                            .font(.headline)
                        
                        Text("1. Persona Consolidation:\nAt the end of each monthly cycle, a 2-step AI prompt chain analyzes your past logs and updates your fluid Markdown user profile (user_profile.md).")
                            .font(.subheadline)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                            .lineSpacing(4)
                        
                        Text("2. Poetic Generation:\nUsing your updated persona and direct quotes from your answers, Moi crafts a personal story letter reflecting your emotional weather and core values.")
                            .font(.subheadline)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                            .lineSpacing(4)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Privacy & Security Guarantees")
                            .font(.headline)
                        
                        Text("• 100% Local Storage: All your logs, notes, and profile Markdown are stored securely on your device.\n• No Model Training: Your personal data is strictly used for real-time reflection synthesis and is never used to train global AI models.")
                            .font(.subheadline)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                            .lineSpacing(4)
                    }
                }
                .padding()
            }
            .navigationTitle("Moi Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
