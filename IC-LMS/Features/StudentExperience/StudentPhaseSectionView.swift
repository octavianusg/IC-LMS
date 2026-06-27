import SwiftUI

struct StudentPhaseSectionView: View {
    let phase: ChallengePhase
    let viewModel: StudentChallengeViewModel
    let onSubmit: (Assignment) -> Void

    private var accent: Color { AppColor.phase(phase.kind) }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: phase.kind.title, accent: accent)
            if phase.items.isEmpty {
                Text("Nothing here yet.")
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.inkSecondary)
            } else {
                ForEach(phase.items) { item in
                    row(for: item)
                }
            }
        }
    }

    @ViewBuilder
    private func row(for item: PhaseItem) -> some View {
        switch item {
        case .content(let content):
            GlassCard {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Label(content.kind.label, systemImage: "doc.text")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.inkSecondary)
                    Text(content.title)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.ink)
                    if !content.body.isEmpty {
                        Text(content.body)
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.inkSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        case .assignment(let assignment):
            assignmentRow(assignment)
        case .checkpoint:
            EmptyView()
        }
    }

    private func assignmentRow(_ assignment: Assignment) -> some View {
        let submitted = viewModel.hasSubmitted(assignmentID: assignment.id)
        return GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Label("Assignment", systemImage: "checklist")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.inkSecondary)
                Text(assignment.title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.ink)
                if !assignment.instructions.isEmpty {
                    Text(assignment.instructions)
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.inkSecondary)
                }
                HStack {
                    if submitted {
                        Label("Submitted", systemImage: "checkmark.circle.fill")
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.success)
                    }
                    Spacer()
                    Button {
                        onSubmit(assignment)
                    } label: {
                        Label(submitted ? "Submit again" : "Submit work", systemImage: "tray.and.arrow.up")
                    }
                    .buttonStyle(.appSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
