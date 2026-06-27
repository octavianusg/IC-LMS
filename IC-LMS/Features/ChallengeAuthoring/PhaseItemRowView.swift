import SwiftUI

struct PhaseItemRowView: View {
    let item: PhaseItem
    let accent: Color
    var showsDisclosure: Bool = false
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: item.systemImage)
                .font(.system(size: 18))
                .foregroundStyle(accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.ink)
                Text(item.typeLabel)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.inkSecondary)
            }
            Spacer()
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppColor.inkSecondary)
            if showsDisclosure {
                Image(systemName: "chevron.right")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.inkSecondary)
            }
        }
        .padding(.vertical, AppSpacing.xs)
        .contentShape(.rect)
    }
}
