import CloudKit
import SwiftUI

struct ChallengeShareSheet: View {
    let challenge: Challenge
    let sharing: SharingManaging?

    @Environment(\.dismiss) private var dismiss
    @State private var phase: Phase = .preparing
    @State private var error: AppError?

    private enum Phase {
        case preparing
        case ready(CKShare)
        case unavailable
        case failed
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Share Challenge")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                    }
                }
        }
        .task { await prepare() }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .preparing:
            infoState(
                system: "person.2",
                title: "Preparing invitation…",
                message: "Setting up a private invitation.",
                showsProgress: true
            )
        case .ready(let share):
            if let sharing {
                CloudSharingView(share: share, container: sharing.container, title: challenge.title)
                    .ignoresSafeArea()
            }
        case .unavailable:
            infoState(
                system: "icloud.slash",
                title: "Sharing needs live iCloud",
                message: "Switch off Mock data and sign in to iCloud to invite colleagues and students."
            )
        case .failed:
            infoState(
                system: "exclamationmark.icloud",
                title: "Couldn't start sharing",
                message: error?.errorDescription ?? "Please try again."
            )
        }
    }

    private func infoState(system: String, title: String, message: String, showsProgress: Bool = false) -> some View {
        VStack(spacing: AppSpacing.md) {
            if showsProgress {
                ProgressView()
            } else {
                Image(systemName: system)
                    .font(.system(size: 40))
                    .foregroundStyle(AppColor.warning)
            }
            Text(title)
                .font(AppFont.title2)
                .foregroundStyle(AppColor.ink)
            Text(message)
                .font(AppFont.callout)
                .foregroundStyle(AppColor.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.xl)
    }

    private func prepare() async {
        guard let sharing else {
            phase = .unavailable
            return
        }
        do {
            let share = try await sharing.makeShare(for: challenge)
            phase = .ready(share)
        } catch let appError as AppError {
            error = appError
            phase = .failed
        } catch {
            self.error = .unknown(message: error.localizedDescription)
            phase = .failed
        }
    }
}
