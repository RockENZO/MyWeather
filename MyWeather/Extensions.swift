import SwiftUI

// MARK: - Liquid Glass Effects (iOS 26)
// These extensions provide Liquid Glass effects that will be available in iOS 26
// For now, we're using a combination of blur and opacity to simulate the effect
// When iOS 26 SDK is available, these can be replaced with native GlassMaterial

extension View {
    /// Applies a Liquid Glass background effect
    /// - Parameters:
    ///   - tint: The tint color for the glass effect
    ///   - opacity: The opacity of the glass (0.0 - 1.0)
    ///   - blur: The blur radius for the glass effect
    /// - Returns: A view with Liquid Glass background
    func glassBackground(
        tint: Color = .primary,
        opacity: Double = 0.2,
        blur: CGFloat = 20
    ) -> some View {
        self.background(
            Color(.systemBackground)
                .opacity(opacity)
                .blur(radius: blur)
                .overlay(
                    tint
                        .opacity(opacity * 0.3)
                )
        )
    }
    
    /// Applies a Liquid Glass card effect with enhanced depth
    func glassCard(
        tint: Color = .primary,
        opacity: Double = 0.15,
        blur: CGFloat = 25,
        cornerRadius: CGFloat = 20
    ) -> some View {
        self.background(
            Color(.systemBackground)
                .opacity(opacity)
                .blur(radius: blur)
                .overlay(
                    tint
                        .opacity(opacity * 0.2)
                )
        )
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    Color(.systemBackground)
                        .opacity(0.1),
                    lineWidth: 0.5
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    /// Applies an elevated Liquid Glass effect for floating elements
    func elevatedGlass(
        tint: Color = .primary,
        opacity: Double = 0.1,
        blur: CGFloat = 30
    ) -> some View {
        self.background(
            Color(.systemBackground)
                .opacity(opacity)
                .blur(radius: blur)
                .overlay(
                    tint
                        .opacity(opacity * 0.2)
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 10)
    }
}

// MARK: - Dynamic Color Extensions
extension Color {
    /// Returns a color that adapts to glass backgrounds
    static var glassText: Color {
        .primary
    }
    
    /// Returns a secondary color for glass backgrounds
    static var glassSecondaryText: Color {
        .secondary
    }
    
    /// Creates a color from hue/saturation/brightness with alpha
    init(hue: Double, saturation: Double, brightness: Double, opacity: Double = 1.0) {
        self.init(
            hue: hue,
            saturation: saturation,
            brightness: brightness,
            opacity: opacity
        )
    }
}