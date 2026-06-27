import SwiftUI

struct ChallengeEditorView: View {
    @State private var viewModel: ChallengeEditorViewModel
    @State private var addContext: AddItemContext?

    init(viewModel: ChallengeEditorViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                header
                ForEach(viewModel.challenge.phases) { phase in
                    PhaseSectionView(
                        phase: phase,
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
            if viewModel.isSaving {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
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
        .errorAlert($viewModel.currentError)
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
