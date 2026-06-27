import SwiftUI

struct FinalRatingView: View {
    let anchors: [String]
    let selectedLevel: Int?
    let accent: Color
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ForEach(Array(anchors.enumerated()), id: \.offset) { level, anchor in
                Button {
                    onSelect(level)
                } label: {
                    anchorRow(level: level, anchor: anchor)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func anchorRow(level: Int, anchor: String) -> some View {
        let isSelected = selectedLevel == level
        return HStack(alignment: .top, spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .stroke(isSelected ? accent : AppColor.inkSecondary.opacity(0.4), lineWidth: 2)
                    .frame(width: 26, height: 26)
                if isSelected {
                    Circle().fill(accent).frame(width: 16, height: 16)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Level \(level + 1)")
                    .font(AppFont.caption)
                    .foregroundStyle(accent)
                Text(anchor)
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.ink)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(isSelected ? accent.opacity(0.08) : Color.clear, in: .rect(cornerRadius: AppRadius.small))
    }
}
