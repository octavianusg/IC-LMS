import CloudKit
import Testing
@testable import IC_LMS

@Suite("CloudKit record zones")
struct CloudKitZoneTests {

    @Test func challengeUsesShareableCustomZone() {
        #expect(Challenge.zoneID == CloudKitZone.shareableID)
        #expect(Challenge.zoneID != CloudKitZone.defaultID)

        let challenge = Challenge(title: "X")
        #expect(challenge.recordID.zoneID == CloudKitZone.shareableID)
        #expect(challenge.toRecord().recordID.zoneID == CloudKitZone.shareableID)
    }

    @Test func assessmentAndSubmissionUseDefaultZone() {
        #expect(CheckpointAssessment.zoneID == CloudKitZone.defaultID)
        #expect(Submission.zoneID == CloudKitZone.defaultID)

        let assessment = CheckpointAssessment(
            challengeID: UUID(),
            checkpointID: UUID(),
            participantID: UUID(),
            skillID: "creativity"
        )
        #expect(assessment.recordID.zoneID == CloudKitZone.defaultID)
    }

    @Test func shareableZoneRoundTripsThroughRecord() {
        let challenge = Challenge(title: "Round trip")
        let record = challenge.toRecord()
        let decoded = try? Challenge(record: record)
        #expect(decoded?.id == challenge.id)
    }
}
