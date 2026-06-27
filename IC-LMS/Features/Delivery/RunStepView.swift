import SwiftUI

struct RunStepView: View {
    let step: RunStep
    let challengeID: UUID

    private var accent: Color { AppColor.phase(step.phase) }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            phaseBadge
            GlassCard {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: step.item.systemImage)
                            .foregroundStyle(accent)
                        Text(step.item.typeLabel)
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.inkSecondary)
                    }
                    Text(step.item.title)
                        .font(AppFont.title2)
                        .foregroundStyle(AppColor.ink)
                    detail
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var phaseBadge: some View {
        Text(step.phase.title.uppercased())
            .font(AppFont.caption)
            .foregroundStyle(AppColor.paperRaised)
            .padding(.vertical, AppSpacing.xs)
            .padding(.horizontal, AppSpacing.sm)
            .background(accent, in: .capsule)
    }

    @ViewBuilder
    private var detail: some View {
        switch step.item {
        case .content(let content):
            if !content.body.isEmpty {
                Text(content.body)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.inkSecondary)
            }
        case .assignment(let assignment):
            if !assignment.instructions.isEmpty {
                Text(assignment.instructions)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.inkSecondary)
            }
        case .checkpoint(let checkpoint):
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Assess one student against this checkpoint's skill.")
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.inkSecondary)
                NavigationLink(value: CheckpointRoute(challengeID: challengeID, checkpoint: checkpoint)) {
                    Label("Open assessment", systemImage: "target")
                }
                .buttonStyle(.appPrimary)
            }
        }
    }
}
