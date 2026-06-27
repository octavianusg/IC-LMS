import Foundation
import Observation

struct RunStep: Identifiable, Equatable {
    let phase: PhaseKind
    let item: PhaseItem

    var id: UUID { item.id }
}

@MainActor
@Observable
final class ChallengeRunViewModel {
    let challenge: Challenge
    private(set) var steps: [RunStep]
    private(set) var index: Int = 0

    private let log: LogManaging

    init(challenge: Challenge, log: LogManaging) {
        self.challenge = challenge
        self.steps = challenge.phases.flatMap { phase in
            phase.items.map { RunStep(phase: phase.kind, item: $0) }
        }
        self.log = log
        log.info("Started run for challenge \(challenge.id) with \(steps.count) steps", category: .authoring)
    }

    var isEmpty: Bool { steps.isEmpty }

    var currentStep: RunStep? {
        steps.indices.contains(index) ? steps[index] : nil
    }

    var positionLabel: String {
        guard !steps.isEmpty else { return "" }
        return "\(index + 1) of \(steps.count)"
    }

    var progress: Double {
        steps.isEmpty ? 0 : Double(index + 1) / Double(steps.count)
    }

    var canAdvance: Bool { index < steps.count - 1 }
    var canGoBack: Bool { index > 0 }

    func advance() {
        guard canAdvance else { return }
        index += 1
    }

    func goBack() {
        guard canGoBack else { return }
        index -= 1
    }

    func jump(to target: Int) {
        guard steps.indices.contains(target) else { return }
        index = target
    }
}
