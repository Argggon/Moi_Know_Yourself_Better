import SwiftUI
import SwiftData

public struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("user_nickname") private var userNickname: String = "you"
    @AppStorage("has_completed_onboarding") private var hasCompletedOnboarding: Bool = true
    @AppStorage("reminder_time_hour") private var reminderHour: Int = 8
    @AppStorage("reminder_time_minute") private var reminderMinute: Int = 0
    
    @State private var selectedLanguage: String = "English"
    @State private var showClearConfirmation: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                // Account Section
                Section(header: Text("Account")) {
                    HStack {
                        Text("Nickname")
                        Spacer()
                        TextField("Your nickname", text: $userNickname)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                    }
                }
                
                // Preferences Section
                Section(header: Text("Preferences")) {
                    HStack {
                        Text("Language")
                        Spacer()
                        Picker("", selection: $selectedLanguage) {
                            Text("English").tag("English")
                            Text("简体中文").tag("Chinese")
                        }
                        .pickerStyle(.menu)
                        .disabled(true) // Greyed out for English-only current iteration
                    }
                }
                
                // Privacy Section
                Section(header: Text("Privacy & Data")) {
                    Button(role: .destructive, action: {
                        showClearConfirmation = true
                    }) {
                        HStack {
                            Text("Clear All Local Data")
                            Spacer()
                            Image(systemName: "trash")
                        }
                    }
                }
                
                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (V2.1)")
                            .foregroundColor(MoiDesign.Colors.tertiaryText)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog("Clear all data?", isPresented: $showClearConfirmation, titleVisibility: .visible) {
                Button("Delete Everything", role: .destructive) {
                    try? modelContext.delete(model: DailyLog.self)
                    try? modelContext.delete(model: SpontaneousNote.self)
                    try? modelContext.delete(model: AskRecord.self)
                    try? modelContext.delete(model: QuestionFingerprint.self)
                    ProfileStorageManager.shared.clearAllData()
                    hasCompletedOnboarding = false
                    dismiss()
                }
            } message: {
                Text("This action cannot be undone. All your past answers and personal profile will be deleted.")
            }
        }
    }
}
