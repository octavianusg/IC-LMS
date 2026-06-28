import SwiftUI

enum AppFont {
    static let largeTitle = garamond(34, relativeTo: .largeTitle, weight: .semibold)
    static let title = garamond(28, relativeTo: .title, weight: .semibold)
    static let title2 = garamond(22, relativeTo: .title2, weight: .medium)

    static let headline = montserrat(17, relativeTo: .headline, weight: .semibold)
    static let button = montserrat(16, relativeTo: .headline, weight: .bold)
    static let body = montserrat(17, relativeTo: .body, weight: .regular)
    static let callout = montserrat(16, relativeTo: .callout, weight: .regular)
    static let subheadline = montserrat(15, relativeTo: .subheadline, weight: .regular)
    static let caption = montserrat(12, relativeTo: .caption, weight: .medium)

    private enum Weight {
        case regular, medium, semibold, bold
    }

    private static func garamond(_ size: CGFloat, relativeTo style: Font.TextStyle, weight: Weight) -> Font {
        let name: String
        switch weight {
        case .regular: name = "EBGaramond-Regular"
        case .medium: name = "EBGaramond-Medium"
        case .semibold: name = "EBGaramond-SemiBold"
        case .bold: name = "EBGaramond-Bold"
        }
        return .custom(name, size: size, relativeTo: style)
    }

    private static func montserrat(_ size: CGFloat, relativeTo style: Font.TextStyle, weight: Weight) -> Font {
        let name: String
        switch weight {
        case .regular: name = "Montserrat-Regular"
        case .medium: name = "Montserrat-Medium"
        case .semibold: name = "Montserrat-SemiBold"
        case .bold: name = "Montserrat-Bold"
        }
        return .custom(name, size: size, relativeTo: style)
    }
}
