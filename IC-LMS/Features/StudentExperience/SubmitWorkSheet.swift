import PhotosUI
import SwiftUI
import UIKit

struct SubmitWorkSheet: View {
    let assignmentTitle: String
    let onSubmit: (String, Data?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var note = ""
    @State private var pickerItem: PhotosPickerItem?
    @State private var imageData: Data?

    var body: some View {
        NavigationStack {
            Form {
                Section("Assignment") {
                    Text(assignmentTitle)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.ink)
                }
                Section("Your work") {
                    TextField("Add a note about your work", text: $note, axis: .vertical)
                        .lineLimit(2...5)
                    if let imageData, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(.rect(cornerRadius: AppRadius.small))
                    }
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label(imageData == nil ? "Attach a photo" : "Replace photo", systemImage: "photo")
                    }
                }
            }
            .navigationTitle("Submit Work")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        onSubmit(note, imageData)
                        dismiss()
                    }
                    .disabled(!canSubmit)
                }
            }
            .onChange(of: pickerItem) { _, newValue in
                Task { await loadImage(newValue) }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var canSubmit: Bool {
        !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || imageData != nil
    }

    private func loadImage(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            imageData = data
        }
    }
}
