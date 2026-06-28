import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.button)
            .foregroundStyle(.white)
            .padding(.vertical, AppSpacing.sm)
            .padding(.horizontal, AppSpacing.lg)
            .background(AppColor.brandGradient, in: .capsule)
            .shadow(color: AppColor.accent.opacity(0.35), radius: 10, x: 0, y: 5)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.button)
            .foregroundStyle(AppColor.accent)
            .padding(.vertical, AppSpacing.sm)
            .padding(.horizontal, AppSpacing.lg)
            .glassEffect(.regular.interactive(), in: .capsule)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var appPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var appSecondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}
