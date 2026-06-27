import SwiftUI

struct CheckpointParticipantsView: View {
    let challengeID: UUID
    let checkpoint: Checkpoint
    let participants: [Participant]

    private var accent: Color { AppColor.accent }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                header
                if participants.isEmpty {
                    emptyState
                } else {
                    ForEach(participants) { participant in
                        NavigationLink(value: route(for: participant)) {
                            participantRow(participant)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(AppSpacing.lg)
        }
        .appScreenBackground()
        .navigationTitle("Assess")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(checkpoint.title)
                .font(AppFont.title)
                .foregroundStyle(AppColor.ink)
            Text("Choose a student to capture evidence and rate.")
                .font(AppFont.subheadline)
                .foregroundStyle(AppColor.inkSecondary)
        }
    }

    private var emptyState: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("No students yet")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.ink)
                Text("Add students to this challenge from the editor to begin assessing.")
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.inkSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func participantRow(_ participant: Participant) -> some View {
        GlassCard {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 28))
                    .foregroundStyle(accent)
                Text(participant.name)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.ink)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppColor.inkSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func route(for participant: Participant) -> ParticipantAssessmentRoute {
        ParticipantAssessmentRoute(challengeID: challengeID, checkpoint: checkpoint, participant: participant)
    }
}
