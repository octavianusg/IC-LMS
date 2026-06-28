import SwiftUI

struct GlassCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppSpacing.md)
            .glassEffect(.regular, in: .rect(cornerRadius: AppRadius.card))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .stroke(
                        LinearGradient(
                            colors: [AppColor.glassStroke, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            }
            .cardShadow()
    }
}
