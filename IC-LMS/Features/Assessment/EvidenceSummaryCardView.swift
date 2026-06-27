import SwiftUI
import UIKit

struct EvidenceSummaryCardView: View {
    let evidence: Evidence
    let accent: Color
    let onDelete: () -> Void

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                thumbnail
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .background(AppColor.paperRaised)
                    .clipShape(.rect(cornerRadius: AppRadius.small))

                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: evidence.kind.systemImage)
                        .foregroundStyle(accent)
                    Text(evidence.kind.label)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.inkSecondary)
                    Spacer()
                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(AppColor.inkSecondary)
                }

                if !evidence.caption.isEmpty {
                    Text(evidence.caption)
                        .font(AppFont.subheadline)
                        .foregroundStyle(AppColor.ink)
                        .lineLimit(3)
                }

                Text(evidence.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.inkSecondary)
            }
        }
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let image = EvidenceRenderer.image(for: evidence) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: evidence.kind.systemImage)
                .font(.system(size: 36))
                .foregroundStyle(accent.opacity(0.6))
        }
    }
}

enum EvidenceRenderer {
    static func image(for evidence: Evidence) -> UIImage? {
        evidence.imageData.flatMap(UIImage.init)
    }
}
