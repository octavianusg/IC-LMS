import SwiftUI

struct ChallengeListView: View {
    @State private var viewModel: ChallengeListViewModel
    @State private var isPresentingNew = false
    @State private var newTitle = ""
    @State private var studentRoute: StudentChallengeRoute?
    private let environment: AppEnvironment

    init(viewModel: ChallengeListViewModel, environment: AppEnvironment) {
        _viewModel = State(initialValue: viewModel)
        self.environment = environment
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView().controlSize(.large)
                } else if viewModel.challenges.isEmpty {
                    emptyState
                } else {
                    challengeGrid
                }
            }
            .appScreenBackground()
            .navigationTitle("Challenges")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        newTitle = ""
                        isPresentingNew = true
                    } label: {
                        Label("New Challenge", systemImage: "plus")
                    }
                }
            }
            .navigationDestination(for: Challenge.self) { challenge in
                ChallengeEditorView(
                    viewModel: environment.makeChallengeEditorViewModel(for: challenge),
                    environment: environment,
                    onClose: { Task { await viewModel.load() } }
                )
            }
            .navigationDestination(item: $studentRoute) { route in
                StudentChallengeView(viewModel: environment.makeStudentViewModel(for: route.challenge))
            }
            .sheet(isPresented: $isPresentingNew) { newChallengeSheet }
            .errorAlert($viewModel.currentError)
            .task { await viewModel.load() }
        }
    }

    private var challengeGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 280), spacing: AppSpacing.md)],
                spacing: AppSpacing.md
            ) {
                ForEach(viewModel.challenges) { challenge in
                    NavigationLink(value: challenge) {
                        ChallengeCardView(challenge: challenge)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            studentRoute = StudentChallengeRoute(challenge: challenge)
                        } label: {
                            Label("Open as student", systemImage: "graduationcap")
                        }
                    }
                }
            }
            .padding(AppSpacing.lg)
        }
        .refreshable { await viewModel.load() }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                OrganicBlob()
                    .fill(AppColor.brandGradient)
                    .frame(width: 132, height: 132)
                    .blur(radius: 18)
                    .opacity(0.22)
                Image(systemName: "books.vertical")
                    .font(.system(size: 52))
                    .foregroundStyle(AppColor.accent)
            }
            Text("No challenges yet")
                .font(AppFont.title2)
                .foregroundStyle(AppColor.ink)
            Text("Create your first Challenge-Based Learning sequence.")
                .font(AppFont.callout)
                .foregroundStyle(AppColor.inkSecondary)
                .multilineTextAlignment(.center)
            Button("New Challenge") {
                newTitle = ""
                isPresentingNew = true
            }
            .buttonStyle(.appPrimary)
        }
        .padding(AppSpacing.xl)
    }

    private var newChallengeSheet: some View {
        NavigationStack {
            Form {
                TextField("Challenge title", text: $newTitle)
                    .font(AppFont.body)
            }
            .navigationTitle("New Challenge")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresentingNew = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            if await viewModel.createChallenge(title: newTitle) != nil {
                                isPresentingNew = false
                            }
                        }
                    }
                }
            }
        }
        .presentationDetents([.height(200)])
    }
}

private struct ChallengeCardView: View {
    let challenge: Challenge

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: PhaseKind.allCases.map(AppColor.phase),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 4)
                Text(challenge.title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.ink)
                    .lineLimit(2)
                if !challenge.summary.isEmpty {
                    Text(challenge.summary)
                        .font(AppFont.subheadline)
                        .foregroundStyle(AppColor.inkSecondary)
                        .lineLimit(2)
                }
                Spacer(minLength: AppSpacing.sm)
                HStack(spacing: AppSpacing.sm) {
                    Label("\(challenge.participants.count)", systemImage: "person.2")
                    Spacer()
                    Text("\(challenge.itemCount) items")
                }
                .font(AppFont.caption)
                .foregroundStyle(AppColor.inkSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        }
    }
}
