import Foundation

struct CheckpointRoute: Hashable {
    let challengeID: UUID
    let checkpoint: Checkpoint
}

struct ParticipantAssessmentRoute: Hashable {
    let challengeID: UUID
    let checkpoint: Checkpoint
    let participant: Participant
}
