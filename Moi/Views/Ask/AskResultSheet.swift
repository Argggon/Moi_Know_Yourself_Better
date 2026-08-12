import SwiftUI

public struct AskResultSheet: View {
    @Environment(\.dismiss) private var dismiss
    public let record: AskRecord
    
    public init(record: AskRecord) {
        self.record = record
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Question Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DILEMMA")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                        Text(record.dilemma)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(MoiDesign.Colors.primaryText)
                    }
                    
                    // Stance Headline Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SUGGESTED DIRECTION")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text(record.stanceHeadline)
                            .font(.headline)
                            .lineSpacing(MoiDesign.Metrics.lineSpacingCompact)
                            .foregroundColor(MoiDesign.Colors.primaryText)
                        
                        Divider().padding(.vertical, 4)
                        
                        Text(record.explanation)
                            .font(.body)
                            .lineSpacing(MoiDesign.Metrics.lineSpacingBody)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                    }
                    .padding()
                    .background(MoiDesign.Colors.secondaryBackground)
                    .cornerRadius(MoiDesign.Metrics.cornerRadiusSheet)
                    
                    // Mandatory Reflection Footer
                    VStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.title3)
                            .foregroundColor(MoiDesign.Colors.tertiaryText)
                        
                        Text("If this stance doesn't feel right to you, you may already know your true answer.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(MoiDesign.Colors.secondaryText)
                            .padding(.horizontal, MoiDesign.Metrics.contentHorizontalPadding)
                    }
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .navigationTitle("Guidance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    MoiSheetCloseButton()
                }
            }
        }
    }
}
