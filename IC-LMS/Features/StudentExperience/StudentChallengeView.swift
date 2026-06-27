import SwiftUI

struct StudentChallengeView: View {
    @State private var viewModel: StudentChallengeViewModel
    @State private var submitContext: SubmitContext?

    init(viewModel: StudentChallengeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                header
                nameField
                ForEach(viewModel.visiblePhases) { phase in
                    StudentPhaseSectionView(
                        phase: phase,
                        viewModel: viewModel,
                        onSubmit: { assignment in
                            submitContext = SubmitContext(assignmentID: assignment.id, title: assignment.title)
                        }
                    )
                }
            }
            .padding(AppSpacing.lg)
        }
        .appScreenBackground()
        .navigationTitle("Learning")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $submitContext) { context in
            SubmitWorkSheet(assignmentTitle: context.title) { note, imageData in
                Task { await viewModel.submit(assignmentID: context.assignmentID, note: note, imageData: imageData) }
            }
        }
        .errorAlert($viewModel.currentError)
        .task { await viewModel.load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
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

    private var nameField: some View {
        GlassCard {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "graduationcap")
                    .foregroundStyle(AppColor.accent)
                TextField("Your name", text: $viewModel.studentName)
                    .font(AppFont.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SubmitContext: Identifiable {
    let assignmentID: UUID
    let title: String

    var id: UUID { assignmentID }
}
