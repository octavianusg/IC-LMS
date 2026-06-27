import SwiftUI

struct RootView: View {
    @State private var environment: AppEnvironment

    init(environment: AppEnvironment) {
        _environment = State(initialValue: environment)
    }

    var body: some View {
        ChallengeListView(
            viewModel: environment.makeChallengeListViewModel(),
            environment: environment
        )
        .id(environment.dataMode)
        .safeAreaInset(edge: .top) {
            AccountStatusBanner(status: environment.accountStatus)
        }
        .overlay(alignment: .bottomTrailing) {
            #if DEBUG
            DebugDataModeSwitch(environment: environment)
            #endif
        }
        .task { await environment.refreshAccountStatus() }
    }
}

struct AccountStatusBanner: View {
    let status: AccountStatus

    var body: some View {
        if let message = status.bannerMessage {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "icloud.slash")
                    .foregroundStyle(AppColor.warning)
                Text(message)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.ink)
                Spacer()
            }
            .padding(AppSpacing.sm)
            .frame(maxWidth: .infinity)
            .glassEffect(.regular, in: .rect(cornerRadius: AppRadius.small))
            .padding(.horizontal, AppSpacing.md)
        }
    }
}
