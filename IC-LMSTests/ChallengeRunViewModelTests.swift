import Testing
import Foundation
@testable import IC_LMS

@MainActor
@Suite("ChallengeRunViewModel")
struct ChallengeRunViewModelTests {

    private func challenge(withItems: Bool) -> Challenge {
        guard withItems else {
            return Challenge(title: "Empty")
        }
        let skill = PredefinedSkillLibrary.all[0]
        return Challenge(
            title: "Run Me",
            phases: [
                ChallengePhase(kind: .engage, items: [
                    .content(ContentItem(kind: .lesson, title: "Intro"))
                ]),
                ChallengePhase(kind: .investigate, items: [
                    .assignment(Assignment(title: "Research")),
                    .checkpoint(Checkpoint(title: "Assess", skill: skill)!)
                ]),
                ChallengePhase(kind: .act, items: [])
            ]
        )
    }

    private func makeViewModel(withItems: Bool = true) -> ChallengeRunViewModel {
        ChallengeRunViewModel(challenge: challenge(withItems: withItems), log: SpyLogManager())
    }

    @Test func flattensItemsAcrossPhasesInOrder() {
        let viewModel = makeViewModel()

        #expect(viewModel.steps.count == 3)
        #expect(viewModel.steps.map(\.phase) == [.engage, .investigate, .investigate])
        #expect(viewModel.currentStep?.item.title == "Intro")
    }

    @Test func advanceAndGoBackMoveThroughSteps() {
        let viewModel = makeViewModel()

        #expect(viewModel.canGoBack == false)
        viewModel.advance()
        #expect(viewModel.currentStep?.item.title == "Research")
        viewModel.advance()
        #expect(viewModel.currentStep?.typeLabelIsCheckpoint == true)
        #expect(viewModel.canAdvance == false)
        viewModel.advance()
        #expect(viewModel.index == 2)
        viewModel.goBack()
        #expect(viewModel.currentStep?.item.title == "Research")
    }

    @Test func progressReflectsPosition() {
        let viewModel = makeViewModel()

        #expect(viewModel.progress == 1.0 / 3.0)
        viewModel.advance()
        viewModel.advance()
        #expect(viewModel.progress == 1.0)
        #expect(viewModel.positionLabel == "3 of 3")
    }

    @Test func jumpClampsToValidRange() {
        let viewModel = makeViewModel()

        viewModel.jump(to: 99)
        #expect(viewModel.index == 0)
        viewModel.jump(to: 2)
        #expect(viewModel.index == 2)
    }

    @Test func emptyChallengeHasNoSteps() {
        let viewModel = makeViewModel(withItems: false)

        #expect(viewModel.isEmpty)
        #expect(viewModel.currentStep == nil)
        #expect(viewModel.progress == 0)
    }
}

private extension RunStep {
    var typeLabelIsCheckpoint: Bool { item.checkpoint != nil }
}
