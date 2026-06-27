import SwiftUI

struct SectionHeader: View {
    let title: String
    var accent: Color = AppColor.ink

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            RoundedRectangle(cornerRadius: 2)
                .fill(accent)
                .frame(width: 4, height: 20)
            Text(title)
                .font(AppFont.title2)
                .foregroundStyle(AppColor.ink)
            Spacer()
        }
    }
}
