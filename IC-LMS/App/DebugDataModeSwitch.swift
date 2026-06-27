import SwiftUI

struct DebugDataModeSwitch: View {
    @Bindable var environment: AppEnvironment
    @State private var dragOffset: CGSize = .zero
    @State private var isExpanded = false

    private var isMock: Bool { environment.dataMode == .mock }

    var body: some View {
        content
            .padding(AppSpacing.sm)
            .glassEffect(.regular.interactive(), in: .capsule)
            .padding(AppSpacing.lg)
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { dragOffset = $0.translation }
            )
    }

    @ViewBuilder
    private var content: some View {
        if isExpanded {
            HStack(spacing: AppSpacing.sm) {
                Circle()
                    .fill(isMock ? AppColor.warning : AppColor.success)
                    .frame(width: 10, height: 10)
                Text(isMock ? "Mock data" : "Live CloudKit")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.ink)
                Toggle("", isOn: Binding(
                    get: { isMock },
                    set: { environment.dataMode = $0 ? .mock : .live }
                ))
                .labelsHidden()
                Button {
                    isExpanded = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColor.inkSecondary)
                }
                .buttonStyle(.plain)
            }
        } else {
            Button {
                isExpanded = true
            } label: {
                Image(systemName: "ladybug.fill")
                    .foregroundStyle(isMock ? AppColor.warning : AppColor.success)
            }
            .buttonStyle(.plain)
        }
    }
}
