import SwiftUI

public struct RefineComparisonCard: View {
    @Binding public var originalText: String
    @Binding public var refinedText: String
    public var onSelect: (String) -> Void
    
    @State private var currentPage: Int = 1 // 0: Original, 1: Refined
    @FocusState private var isEditing: Bool
    
    public init(
        originalText: Binding<String>,
        refinedText: Binding<String>,
        onSelect: @escaping (String) -> Void
    ) {
        self._originalText = originalText
        self._refinedText = refinedText
        self.onSelect = onSelect
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Header Page Indicators
            HStack {
                Text(currentPage == 0 ? "Your words" : "Refined")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(MoiDesign.Colors.secondaryText)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(currentPage == 0 ? MoiDesign.Colors.primary : Color.gray.opacity(0.3))
                        .frame(width: 7, height: 7)
                    Circle()
                        .fill(currentPage == 1 ? MoiDesign.Colors.primary : Color.gray.opacity(0.3))
                        .frame(width: 7, height: 7)
                }
            }
            .padding(.horizontal, 4)
            
            // Swipeable Card Area
            TabView(selection: $currentPage) {
                // Page 0: Original Text Card
                VStack(alignment: .leading, spacing: 10) {
                    TextEditor(text: $originalText)
                        .font(.body)
                        .focused($isEditing)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                }
                .padding()
                .background(MoiDesign.Colors.cardBackground)
                .tag(0)

                // Page 1: Refined Text Card
                VStack(alignment: .leading, spacing: 10) {
                    TextEditor(text: $refinedText)
                        .font(.body)
                        .focused($isEditing)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                }
                .padding()
                .background(MoiDesign.Colors.cardBackground)
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 160)
            
            Text("Tap text to edit")
                .font(.caption2)
                .foregroundColor(MoiDesign.Colors.tertiaryText)
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {
                    onSelect(originalText)
                }) {
                    Text("Keep Original")
                        .font(.subheadline)
                        .foregroundColor(MoiDesign.Colors.primaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: MoiDesign.Metrics.cornerRadiusButton)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Button(action: {
                    onSelect(refinedText)
                }) {
                    Text("Use Refined")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(MoiDesign.Colors.primary)
                        .cornerRadius(MoiDesign.Metrics.cornerRadiusButton)
                }
            }
        }
        .padding()
        .background(MoiDesign.Colors.secondaryBackground)
        .cornerRadius(MoiDesign.Metrics.cornerRadiusSheet)
    }
}
