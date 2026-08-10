import SwiftUI
import SwiftData

@main
struct MoiApp: App {
    @AppStorage("has_completed_onboarding") private var hasCompletedOnboarding: Bool = false
    
    // SwiftData Persistence Container
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                DailyLog.self,
                SpontaneousNote.self,
                AskRecord.self,
                QuestionFingerprint.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to initialize SwiftData Container: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .modelContainer(container)
            } else {
                OnboardingView(isCompleted: $hasCompletedOnboarding)
                    .modelContainer(container)
            }
        }
    }
}
