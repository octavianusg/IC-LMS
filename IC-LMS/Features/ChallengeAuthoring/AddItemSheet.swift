import SwiftUI

enum AddItemRequest {
    case content(kind: ContentKind, title: String)
    case assignment(title: String)
    case checkpoint(title: String, skill: Skill)
}

private enum ItemTab: String, CaseIterable, Identifiable {
    case content = "Content"
    case assignment = "Assignment"
    case checkpoint = "Checkpoint"

    var id: String { rawValue }
}

struct AddItemSheet: View {
    let phase: PhaseKind
    let skills: [Skill]
    let onSubmit: (AddItemRequest) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var tab: ItemTab = .content
    @State private var title = ""
    @State private var contentKind: ContentKind = .lesson
    @State private var selectedSkillID: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $tab) {
                    ForEach(ItemTab.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                Section {
                    TextField("Title", text: $title)
                    if tab == .content {
                        Picker("Kind", selection: $contentKind) {
                            ForEach(ContentKind.allCases) { Text($0.label).tag($0) }
                        }
                    }
                    if tab == .checkpoint {
                        skillPicker
                    }
                }

                if tab == .checkpoint {
                    anchorsPreview
                }
            }
            .navigationTitle("Add to \(phase.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { submit() }
                        .disabled(!canSubmit)
                }
            }
            .onAppear {
                if selectedSkillID.isEmpty { selectedSkillID = skills.first?.id ?? "" }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var skillPicker: some View {
        Picker("Skill", selection: $selectedSkillID) {
            ForEach(skills) { Text($0.name).tag($0.id) }
        }
    }

    @ViewBuilder
    private var anchorsPreview: some View {
        if let skill = skills.first(where: { $0.id == selectedSkillID }) {
            Section("Rubric anchors (refine live)") {
                Text(skill.summary)
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColor.inkSecondary)
                ForEach(Array(skill.defaultAnchors.enumerated()), id: \.offset) { index, anchor in
                    Text("\(index + 1). \(anchor)")
                        .font(AppFont.caption)
                }
            }
        }
    }

    private var canSubmit: Bool {
        let hasTitle = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if tab == .checkpoint {
            return hasTitle && skills.contains { $0.id == selectedSkillID }
        }
        return hasTitle
    }

    private func submit() {
        switch tab {
        case .content:
            onSubmit(.content(kind: contentKind, title: title))
        case .assignment:
            onSubmit(.assignment(title: title))
        case .checkpoint:
            guard let skill = skills.first(where: { $0.id == selectedSkillID }) else { return }
            onSubmit(.checkpoint(title: title, skill: skill))
        }
    }
}
