import SwiftUI
import UIKit

// MARK: - Moi Design System & Color Palette (iOS Native V2.1)
public enum MoiDesign {
    public enum Metrics {
        public static let inputControlSize: CGFloat = 44
        public static let inputIconSize: CGFloat = 16
        public static let microphoneIconSize: CGFloat = 17
    }
    
    // MARK: - Colors
    public enum Colors {
        /// Primary accent blue
        public static let primary = Color.blue
        
        /// Background for light/dark mode
        public static let background = Color(uiColor: .systemBackground)
        public static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
        public static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
        
        /// Card Backgrounds
        public static var cardBackground: Color {
            Color(uiColor: UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0)
                    : UIColor.white
            })
        }
        
        /// Text Colors
        public static let primaryText = Color.primary
        public static let secondaryText = Color.secondary
        public static let tertiaryText = Color(uiColor: .tertiaryLabel)
        
        /// Accent Halo Glow
        public static let haloGlow = Color.blue.opacity(0.35)
    }
    
    // MARK: - Shadows
    public struct CardShadow: ViewModifier {
        @Environment(\.colorScheme) var colorScheme
        
        public func body(content: Content) -> some View {
            content
                .shadow(
                    color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.06),
                    radius: 12,
                    x: 0,
                    y: 4
                )
        }
    }
    
    // MARK: - Card Container Style
    public struct MinimalCardModifier: ViewModifier {
        public func body(content: Content) -> some View {
            content
                .background(Colors.cardBackground)
                .cornerRadius(20)
                .modifier(CardShadow())
        }
    }

    public struct NativeNavigationBehavior: ViewModifier {
        @ViewBuilder
        public func body(content: Content) -> some View {
            if #available(iOS 27.0, *) {
                content
                    .scrollEdgeEffectStyle(.automatic, for: .top)
                    // FIXME: toolbarMinimizeBehavior was removed in Xcode 27 beta 5 (27A5237l)
                    // Re-enable when Apple restores this API in future beta
                    // See: https://developer.apple.com/forums/thread/796455
                    // .toolbarMinimizeBehavior(.onScrollDown, for: .navigationBar)
            } else if #available(iOS 26.0, *) {
                content
                    .scrollEdgeEffectStyle(.automatic, for: .top)
            } else {
                content
            }
        }
    }
}

public struct MoiSheetCloseButton: View {
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        if #available(iOS 26.0, *) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        } else {
            Button(action: dismiss.callAsFunction) {
                closeIcon
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
    }

    private var closeIcon: some View {
        Image(systemName: "xmark")
            .font(.system(size: 14, weight: .semibold))
            .frame(width: 36, height: 36)
            .contentShape(Circle())
    }
}

public struct MoiInputBar: View {
    @Binding private var text: String
    private let placeholder: LocalizedStringKey
    private let isRecording: Bool
    private let onVoiceInput: () -> Void
    private let onSubmit: () -> Void

    @FocusState private var isFocused: Bool

    public init(
        text: Binding<String>,
        placeholder: LocalizedStringKey,
        isRecording: Bool,
        onVoiceInput: @escaping () -> Void,
        onSubmit: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isRecording = isRecording
        self.onVoiceInput = onVoiceInput
        self.onSubmit = onSubmit
    }

    private var canSubmit: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var body: some View {
        HStack(spacing: 8) {
            inputCapsule
                .frame(maxWidth: .infinity)

            if #available(iOS 26.0, *) {
                submitButton
                    .glassEffect(.regular.interactive(), in: Circle())
            } else {
                submitButton
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
    }

    @ViewBuilder
    private var inputCapsule: some View {
        let content = HStack(spacing: 4) {
            Button(action: onVoiceInput) {
                Image(systemName: isRecording ? "waveform" : "mic.fill")
                    .font(.system(size: MoiDesign.Metrics.microphoneIconSize, weight: .medium))
                    .foregroundStyle(isRecording ? Color.red : Color.primary)
                    .frame(
                        width: MoiDesign.Metrics.inputControlSize,
                        height: MoiDesign.Metrics.inputControlSize
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isRecording ? "Stop recording" : "Start recording")

            TextField(placeholder, text: $text)
                .font(.body)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit(submit)
                .padding(.trailing, 16)
        }
        .frame(minHeight: MoiDesign.Metrics.inputControlSize)

        if #available(iOS 26.0, *) {
            content.glassEffect(.regular, in: Capsule())
        } else {
            content.background(.ultraThinMaterial, in: Capsule())
        }
    }

    private var submitButton: some View {
        Button(action: submit) {
            Image(systemName: "checkmark")
                .font(.system(size: MoiDesign.Metrics.inputIconSize, weight: .semibold))
                .frame(
                    width: MoiDesign.Metrics.inputControlSize,
                    height: MoiDesign.Metrics.inputControlSize
                )
                .contentShape(Circle())
        }
        .foregroundStyle(canSubmit ? MoiDesign.Colors.primary : Color.secondary)
        .buttonStyle(.plain)
        .disabled(!canSubmit)
        .opacity(canSubmit ? 1 : 0.5)
        .accessibilityLabel("Submit")
    }

    private func submit() {
        guard canSubmit else { return }
        isFocused = false
        onSubmit()
    }
}

public extension View {
    func minimalCardStyle() -> some View {
        self.modifier(MoiDesign.MinimalCardModifier())
    }

    func moiNativeNavigationBehavior() -> some View {
        modifier(MoiDesign.NativeNavigationBehavior())
    }
}
