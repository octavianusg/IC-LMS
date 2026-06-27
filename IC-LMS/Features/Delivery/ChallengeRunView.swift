import SwiftUI

struct ChallengeRunView: View {
    @State private var viewModel: ChallengeRunViewModel

    init(viewModel: ChallengeRunViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            if viewModel.isEmpty {
                emptyState
            } else {
                progressHeader
                if let step = viewModel.currentStep {
                    ScrollView {
                        RunStepView(step: step, challengeID: viewModel.challenge.id)
                            .padding(AppSpacing.lg)
                    }
                }
                controls
            }
        }
        .appScreenBackground()
        .navigationTitle("Facilitate")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(viewModel.challenge.title)
                .font(AppFont.title2)
                .foregroundStyle(AppColor.ink)
            ProgressView(value: viewModel.progress)
                .tint(AppColor.accent)
            Text(viewModel.positionLabel)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.inkSecondary)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
    }

    private var controls: some View {
        HStack {
            Button {
                viewModel.goBack()
            } label: {
                Label("Back", systemImage: "chevron.left")
            }
            .buttonStyle(.appSecondary)
            .disabled(!viewModel.canGoBack)

            Spacer()

            Button {
                viewModel.advance()
            } label: {
                Label("Next", systemImage: "chevron.right")
            }
            .buttonStyle(.appPrimary)
            .disabled(!viewModel.canAdvance)
        }
        .padding(AppSpacing.lg)
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "play.slash")
                .font(.system(size: 44))
                .foregroundStyle(AppColor.inkSecondary)
            Text("Nothing to run yet")
                .font(AppFont.title2)
                .foregroundStyle(AppColor.ink)
            Text("Add content, assignments, or checkpoints to facilitate this challenge.")
                .font(AppFont.callout)
                .foregroundStyle(AppColor.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.xl)
    }
}
