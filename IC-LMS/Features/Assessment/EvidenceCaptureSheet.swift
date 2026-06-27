import PencilKit
import PhotosUI
import SwiftUI
import UIKit

enum EvidenceCaptureResult {
    case photoNote(imageData: Data, caption: String)
    case handwriting(imageData: Data, isAnnotation: Bool, caption: String)
    case studentUpload(imageData: Data, caption: String)
}

private enum CaptureMode: String, CaseIterable, Identifiable {
    case photo = "Photo"
    case handwriting = "Handwriting"
    case upload = "Student work"

    var id: String { rawValue }
}

struct EvidenceCaptureSheet: View {
    let onCapture: (EvidenceCaptureResult) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var mode: CaptureMode = .photo
    @State private var caption = ""
    @State private var pickerItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var drawing = PKDrawing()
    @State private var canvasSize: CGSize = .zero

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $mode) {
                    ForEach(CaptureMode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                switch mode {
                case .photo:
                    photoSection(prompt: "Choose a photo of the work or activity")
                case .handwriting:
                    handwritingSection
                case .upload:
                    photoSection(prompt: "Attach the student's submitted artifact")
                }

                Section("Note") {
                    TextField("Add a short description", text: $caption, axis: .vertical)
                        .lineLimit(2...5)
                }
            }
            .navigationTitle("Capture Evidence")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { submit() }.disabled(!canSubmit)
                }
            }
            .onChange(of: pickerItem) { _, newValue in
                Task { await loadImage(newValue) }
            }
        }
        .presentationDetents([.large])
    }

    @ViewBuilder
    private func photoSection(prompt: String) -> some View {
        Section {
            if let imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 220)
                    .clipShape(.rect(cornerRadius: AppRadius.small))
            }
            PhotosPicker(selection: $pickerItem, matching: .images) {
                Label(imageData == nil ? "Select photo" : "Replace photo", systemImage: "photo")
            }
        } footer: {
            Text(prompt)
        }
    }

    private var handwritingSection: some View {
        Section {
            ZStack {
                if let imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
                HandwritingCanvasView(drawing: $drawing)
            }
            .frame(height: 280)
            .frame(maxWidth: .infinity)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { canvasSize = proxy.size }
                        .onChange(of: proxy.size) { _, newValue in canvasSize = newValue }
                }
            }
            .background(AppColor.paperRaised)
            .clipShape(.rect(cornerRadius: AppRadius.small))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.small)
                    .stroke(AppColor.inkSecondary.opacity(0.2))
            }
            PhotosPicker(selection: $pickerItem, matching: .images) {
                Label(imageData == nil ? "Annotate a photo (optional)" : "Replace photo", systemImage: "photo.badge.plus")
            }
            if imageData != nil {
                Button("Remove photo", role: .destructive) { imageData = nil }
            }
        } footer: {
            Text("Jot freeform notes, or mark up a photo with Apple Pencil.")
        }
    }

    private var canSubmit: Bool {
        switch mode {
        case .photo, .upload:
            return imageData != nil
        case .handwriting:
            return !drawing.bounds.isEmpty
        }
    }

    private func submit() {
        switch mode {
        case .photo:
            guard let imageData else { return }
            onCapture(.photoNote(imageData: imageData, caption: caption))
        case .upload:
            guard let imageData else { return }
            onCapture(.studentUpload(imageData: imageData, caption: caption))
        case .handwriting:
            let photo = imageData.flatMap(UIImage.init)
            let flattened = EvidenceImageComposer.flatten(drawing: drawing, photo: photo, in: canvasSize)
            onCapture(.handwriting(imageData: flattened, isAnnotation: photo != nil, caption: caption))
        }
        dismiss()
    }

    private func loadImage(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            imageData = data
        }
    }
}
