import SwiftUI

enum AppColor {
    static let ink = Color(red: 0.16, green: 0.09, blue: 0.21)
    static let inkSecondary = Color(red: 0.40, green: 0.34, blue: 0.46)
    static let paper = Color(red: 0.975, green: 0.965, blue: 0.99)
    static let paperRaised = Color(red: 1.0, green: 1.0, blue: 1.0)

    static let accent = Color(red: 0.600, green: 0.059, blue: 0.980)
    static let accentDeep = Color(red: 0.369, green: 0.0, blue: 0.702)
    static let rose = Color(red: 0.902, green: 0.0, blue: 0.463)
    static let lavender = Color(red: 0.93, green: 0.90, blue: 0.99)
    static let glassStroke = Color.white.opacity(0.45)

    static let success = Color(red: 0.18, green: 0.49, blue: 0.36)
    static let warning = Color(red: 0.78, green: 0.55, blue: 0.16)
    static let danger = Color(red: 0.84, green: 0.13, blue: 0.35)

    static let brandGradient = LinearGradient(
        colors: [accent, rose],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let canvasGradient = LinearGradient(
        colors: [paper, lavender],
        startPoint: .top,
        endPoint: .bottom
    )

    static func phase(_ phase: PhaseKind) -> Color {
        switch phase {
        case .engage:
            return Color(red: 0.49, green: 0.33, blue: 0.83)
        case .investigate:
            return Color(red: 0.369, green: 0.0, blue: 0.702)
        case .act:
            return Color(red: 0.902, green: 0.0, blue: 0.463)
        }
    }
}
