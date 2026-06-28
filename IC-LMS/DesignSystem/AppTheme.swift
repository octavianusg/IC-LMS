import SwiftUI

enum AppTheme {
    typealias Color = AppColor
    typealias Font = AppFont
    typealias Spacing = AppSpacing
    typealias Radius = AppRadius
}

extension View {
    func appScreenBackground() -> some View {
        background {
            ZStack {
                AppColor.canvasGradient
                OrganicBackdrop()
            }
            .ignoresSafeArea()
        }
    }
}
