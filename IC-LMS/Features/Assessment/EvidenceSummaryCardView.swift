import PencilKit
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
        let base = evidence.imageData.flatMap(UIImage.init)
        let overlay = drawingImage(from: evidence.drawingData)

        switch (base, overlay) {
        case let (base?, overlay?):
            return composite(base: base, overlay: overlay)
        case let (base?, nil):
            return base
        case let (nil, overlay?):
            return overlay
        default:
            return nil
        }
    }

    private static func drawingImage(from data: Data?) -> UIImage? {
        guard let data, let drawing = try? PKDrawing(data: data), !drawing.bounds.isEmpty else {
            return nil
        }
        return drawing.image(from: drawing.bounds, scale: 2)
    }

    private static func composite(base: UIImage, overlay: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: base.size)
        return renderer.image { _ in
            base.draw(in: CGRect(origin: .zero, size: base.size))
            overlay.draw(in: CGRect(origin: .zero, size: base.size))
        }
    }
}
