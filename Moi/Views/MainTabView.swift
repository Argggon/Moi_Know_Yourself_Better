import SwiftUI

public struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: Int = 0
    @State private var showSettingsSheet: Bool = false
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            // TAB 1: TODAY
            NavigationStack {
                TodayView(onOpenSettings: { showSettingsSheet = true })
            }
            .tabItem {
                Label("Today", systemImage: "sparkle")
            }
            .tag(0)
            
            // TAB 2: ASK
            NavigationStack {
                AskView(onOpenSettings: { showSettingsSheet = true })
            }
            .tabItem {
                Label("Ask", systemImage: "questionmark.bubble")
            }
            .tag(1)
            
            // TAB 3: STORY
            NavigationStack {
                StoryView(onOpenSettings: { showSettingsSheet = true })
            }
            .tabItem {
                Label("Story", systemImage: "book")
            }
            .tag(2)
        }
        .accentColor(MoiDesign.Colors.primary)
        .sheet(isPresented: $showSettingsSheet) {
            SettingsSheet()
        }
    }
}

public struct UserAvatarButton: View {
    public var action: () -> Void
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(MoiDesign.Colors.primaryText)
        }
    }
}
