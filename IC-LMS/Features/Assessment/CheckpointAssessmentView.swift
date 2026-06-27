import SwiftUI

struct CheckpointAssessmentView: View {
    @State private var viewModel: AssessmentViewModel
    @State private var isCapturing = false

    init(viewModel: AssessmentViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private var accent: Color { AppColor.accent }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                header
                evidenceSection
                ratingSection
            }
            .padding(AppSpacing.lg)
        }
        .appScreenBackground()
        .navigationTitle(viewModel.participant.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    Button {
                        isCapturing = true
                    } label: {
                        Label("Capture", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isCapturing) {
            EvidenceCaptureSheet { result in
                Task { await handle(result) }
            }
        }
        .errorAlert($viewModel.currentError)
        .task { await viewModel.load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(viewModel.skill.name)
                .font(AppFont.largeTitle)
                .foregroundStyle(AppColor.ink)
            Text(viewModel.skill.summary)
                .font(AppFont.body)
                .foregroundStyle(AppColor.inkSecondary)
        }
    }

    private var evidenceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Evidence", accent: accent)
            if viewModel.orderedEvidence.isEmpty {
                Text("Capture a photo, Apple Pencil note, or student work to build the progression arc.")
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.inkSecondary)
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 220), spacing: AppSpacing.md)],
                    spacing: AppSpacing.md
                ) {
                    ForEach(viewModel.orderedEvidence) { evidence in
                        EvidenceSummaryCardView(evidence: evidence, accent: accent) {
                            Task { await viewModel.removeEvidence(id: evidence.id) }
                        }
                    }
                }
            }
        }
    }

    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Final Rating", accent: accent)
            Text("Weigh the trajectory across the evidence, then choose the rubric level.")
                .font(AppFont.subheadline)
                .foregroundStyle(AppColor.inkSecondary)
            FinalRatingView(
                anchors: viewModel.anchors,
                selectedLevel: viewModel.finalRatingLevel,
                accent: accent
            ) { level in
                Task { await viewModel.setFinalRating(level: level) }
            }
        }
    }

    private func handle(_ result: EvidenceCaptureResult) async {
        switch result {
        case let .photoNote(imageData, caption):
            await viewModel.addPhotoNote(imageData: imageData, caption: caption)
        case let .handwriting(drawingData, annotatedPhoto, caption):
            await viewModel.addHandwriting(drawingData: drawingData, annotatedPhoto: annotatedPhoto, caption: caption)
        case let .studentUpload(imageData, caption):
            await viewModel.addStudentUpload(imageData: imageData, caption: caption)
        }
    }
}
