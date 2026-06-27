import SwiftUI

struct PhaseSectionView: View {
    let phase: ChallengePhase
    let challengeID: UUID
    let onAdd: () -> Void
    let onDelete: (UUID) -> Void

    private var accent: Color { AppColor.phase(phase.kind) }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            header
            GlassCard {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    if phase.items.isEmpty {
                        emptyRow
                    } else {
                        ForEach(phase.items) { item in
                            row(for: item)
                            if item.id != phase.items.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                SectionHeader(title: phase.kind.title, accent: accent)
                Text(phase.kind.subtitle)
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColor.inkSecondary)
            }
            Spacer()
            Button(action: onAdd) {
                Label("Add", systemImage: "plus")
            }
            .buttonStyle(.appSecondary)
        }
    }

    @ViewBuilder
    private func row(for item: PhaseItem) -> some View {
        if let checkpoint = item.checkpoint {
            NavigationLink(value: CheckpointRoute(challengeID: challengeID, checkpoint: checkpoint)) {
                PhaseItemRowView(item: item, accent: accent, showsDisclosure: true) {
                    onDelete(item.id)
                }
            }
            .buttonStyle(.plain)
        } else {
            PhaseItemRowView(item: item, accent: accent) {
                onDelete(item.id)
            }
        }
    }

    private var emptyRow: some View {
        Text("Nothing here yet. Add content, an assignment, or a checkpoint.")
            .font(AppFont.callout)
            .foregroundStyle(AppColor.inkSecondary)
            .padding(.vertical, AppSpacing.xs)
    }
}
