import SwiftUI

enum AppColor {
    static let ink = Color(red: 0.10, green: 0.14, blue: 0.24)
    static let inkSecondary = Color(red: 0.30, green: 0.34, blue: 0.44)
    static let paper = Color(red: 0.98, green: 0.97, blue: 0.94)
    static let paperRaised = Color(red: 1.0, green: 0.99, blue: 0.97)
    static let accent = Color(red: 0.62, green: 0.28, blue: 0.20)

    static let success = Color(red: 0.18, green: 0.49, blue: 0.36)
    static let warning = Color(red: 0.78, green: 0.55, blue: 0.16)
    static let danger = Color(red: 0.70, green: 0.22, blue: 0.20)

    static func phase(_ phase: PhaseKind) -> Color {
        switch phase {
        case .engage:
            return Color(red: 0.20, green: 0.40, blue: 0.56)
        case .investigate:
            return Color(red: 0.36, green: 0.30, blue: 0.55)
        case .act:
            return Color(red: 0.62, green: 0.28, blue: 0.20)
        }
    }
}
