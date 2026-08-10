import SwiftUI
import UIKit

// MARK: - Moi Design System & Color Palette (iOS Native V2.1)
public enum MoiDesign {
    
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
}

public extension View {
    func minimalCardStyle() -> some View {
        self.modifier(MoiDesign.MinimalCardModifier())
    }
}
