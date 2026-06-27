import SwiftUI

struct PhaseSectionView: View {
    let phase: ChallengePhase
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
                            PhaseItemRowView(item: item, accent: accent) {
                                onDelete(item.id)
                            }
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

    private var emptyRow: some View {
        Text("Nothing here yet. Add content, an assignment, or a checkpoint.")
            .font(AppFont.callout)
            .foregroundStyle(AppColor.inkSecondary)
            .padding(.vertical, AppSpacing.xs)
    }
}
