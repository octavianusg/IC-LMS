import AVFoundation
import PencilKit
import UIKit

enum EvidenceImageComposer {
    static func flatten(drawing: PKDrawing, photo: UIImage?, in size: CGSize) -> Data {
        let canvas = size.width > 0 && size.height > 0 ? size : CGSize(width: 320, height: 280)
        let renderer = UIGraphicsImageRenderer(size: canvas)
        let image = renderer.image { context in
            if let photo {
                let target = AVMakeRect(aspectRatio: photo.size, insideRect: CGRect(origin: .zero, size: canvas))
                photo.draw(in: target)
            } else {
                UIColor.systemBackground.setFill()
                context.fill(CGRect(origin: .zero, size: canvas))
            }
            let drawingImage = drawing.image(from: CGRect(origin: .zero, size: canvas), scale: 0)
            drawingImage.draw(in: CGRect(origin: .zero, size: canvas))
        }
        return image.pngData() ?? Data()
    }
}
