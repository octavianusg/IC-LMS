import SwiftUI

enum AppShadow {
    static let cardColor = AppColor.ink.opacity(0.12)
    static let cardRadius: CGFloat = 14
    static let cardOffsetY: CGFloat = 6

    static let softColor = AppColor.accentDeep.opacity(0.10)
}

extension View {
    func cardShadow() -> some View {
        shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, x: 0, y: AppShadow.cardOffsetY)
    }
}
