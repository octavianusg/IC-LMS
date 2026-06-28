import SwiftUI

struct OrganicBackdrop: View {
    var body: some View {
        ZStack {
            blob(
                fill: AppColor.brandGradient,
                size: 320,
                blur: 70,
                opacity: 0.16,
                rotation: -18
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .offset(x: -90, y: -120)

            blob(
                fill: LinearGradient(
                    colors: [AppColor.rose, AppColor.accentDeep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                size: 300,
                blur: 80,
                opacity: 0.12,
                rotation: 150
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .offset(x: 100, y: 130)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func blob(
        fill: some ShapeStyle,
        size: CGFloat,
        blur: CGFloat,
        opacity: Double,
        rotation: Double
    ) -> some View {
        OrganicBlob()
            .fill(fill)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .blur(radius: blur)
            .opacity(opacity)
    }
}
