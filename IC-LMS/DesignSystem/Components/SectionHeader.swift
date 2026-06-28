import SwiftUI

struct SectionHeader: View {
    let title: String
    var accent: Color = AppColor.accent

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [accent, accent.opacity(0.55)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 5, height: 22)
            Text(title)
                .font(AppFont.title2)
                .foregroundStyle(AppColor.ink)
            Spacer()
        }
    }
}
