import SwiftUI

struct ChallengeEditorView: View {
    @State private var viewModel: ChallengeEditorViewModel
    @State private var addContext: AddItemContext?
    @State private var isAddingParticipant = false
    @State private var newParticipantName = ""
    @State private var isSharing = false
    private let environment: AppEnvironment
    private let onClose: () -> Void

    init(viewModel: ChallengeEditorViewModel, environment: AppEnvironment, onClose: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: viewModel)
        self.environment = environment
        self.onClose = onClose
    }

    private var challengeID: UUID { viewModel.challenge.id }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                header
                RosterSectionView(
                    participants: viewModel.challenge.participants,
                    onAdd: {
                        newParticipantName = ""
                        isAddingParticipant = true
                    },
                    onDelete: { id in
                        Task { await viewModel.removeParticipant(id: id) }
                    }
                )
                ForEach(viewModel.challenge.phases) { phase in
                    PhaseSectionView(
                        phase: phase,
                        challengeID: challengeID,
                        onAdd: { addContext = AddItemContext(phase: phase.kind) },
                        onDelete: { itemID in
                            Task { await viewModel.removeItem(id: itemID, from: phase.kind) }
                        }
                    )
                }
            }
            .padding(AppSpacing.lg)
        }
        .appScreenBackground()
        .navigationTitle(viewModel.challenge.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.isSaving {
                    ProgressView()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: ChallengeRunRoute(challenge: viewModel.challenge)) {
                    Label("Run", systemImage: "play.fill")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isSharing = true
                } label: {
                    Label("Share", systemImage: "person.crop.circle.badge.plus")
                }
            }
        }
        .sheet(item: $addContext) { context in
            AddItemSheet(
                phase: context.phase,
                skills: viewModel.availableSkills,
                onSubmit: { request in
                    Task { await handle(request, in: context.phase) }
                }
            )
        }
        .alert("Add Student", isPresented: $isAddingParticipant) {
            TextField("Student name", text: $newParticipantName)
            Button("Cancel", role: .cancel) {}
            Button("Add") {
                Task { await viewModel.addParticipant(name: newParticipantName) }
            }
        }
        .navigationDestination(for: CheckpointRoute.self) { route in
            CheckpointParticipantsView(
                challengeID: route.challengeID,
                checkpoint: route.checkpoint,
                participants: viewModel.challenge.participants
            )
        }
        .navigationDestination(for: ParticipantAssessmentRoute.self) { route in
            CheckpointAssessmentView(
                viewModel: environment.makeAssessmentViewModel(
                    challengeID: route.challengeID,
                    checkpoint: route.checkpoint,
                    participant: route.participant
                )
            )
        }
        .navigationDestination(for: ChallengeRunRoute.self) { route in
            ChallengeRunView(viewModel: environment.makeRunViewModel(for: route.challenge))
        }
        .sheet(isPresented: $isSharing) {
            ChallengeShareSheet(challenge: viewModel.challenge, sharing: environment.sharing)
        }
        .errorAlert($viewModel.currentError)
        .onDisappear { onClose() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(viewModel.challenge.title)
                .font(AppFont.largeTitle)
                .foregroundStyle(AppColor.ink)
            if !viewModel.challenge.summary.isEmpty {
                Text(viewModel.challenge.summary)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.inkSecondary)
            }
            Text("Engage → Investigate → Act")
                .font(AppFont.caption)
                .foregroundStyle(AppColor.inkSecondary)
        }
    }

    private func handle(_ request: AddItemRequest, in phase: PhaseKind) async {
        switch request {
        case let .content(kind, title):
            await viewModel.addContent(kind, title: title, to: phase)
        case let .assignment(title):
            await viewModel.addAssignment(title: title, to: phase)
        case let .checkpoint(title, skill):
            await viewModel.addCheckpoint(title: title, skill: skill, to: phase)
        }
        addContext = nil
    }
}

private struct AddItemContext: Identifiable {
    let phase: PhaseKind
    var id: PhaseKind { phase }
}
