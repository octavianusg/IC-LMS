import SwiftUI

struct RosterSectionView: View {
    let participants: [Participant]
    let onAdd: () -> Void
    let onDelete: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                SectionHeader(title: "Students", accent: AppColor.ink)
                Button(action: onAdd) {
                    Label("Add", systemImage: "person.badge.plus")
                }
                .buttonStyle(.appSecondary)
            }
            GlassCard {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    if participants.isEmpty {
                        Text("Add students to capture and rate their skill evidence.")
                            .font(AppFont.callout)
                            .foregroundStyle(AppColor.inkSecondary)
                    } else {
                        ForEach(participants) { participant in
                            HStack {
                                Image(systemName: "person.crop.circle")
                                    .foregroundStyle(AppColor.accent)
                                Text(participant.name)
                                    .font(AppFont.body)
                                    .foregroundStyle(AppColor.ink)
                                Spacer()
                                Button(role: .destructive) {
                                    onDelete(participant.id)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(AppColor.inkSecondary)
                            }
                            if participant.id != participants.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
