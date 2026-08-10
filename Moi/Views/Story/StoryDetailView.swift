import SwiftUI

public struct StoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    public let story: MonthlyStoryItem
    
    public init(story: MonthlyStoryItem) {
        self.story = story
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(story.content)
                        .font(.system(.body, design: .serif))
                        .lineSpacing(10)
                        .foregroundColor(MoiDesign.Colors.primaryText)
                        .padding()
                }
            }
            .navigationTitle(story.yearMonth)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
