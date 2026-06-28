import SwiftUI

struct OrganicBlob: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.50, y: h * 0.02))
        path.addCurve(
            to: CGPoint(x: w * 0.98, y: h * 0.44),
            control1: CGPoint(x: w * 0.82, y: h * 0.00),
            control2: CGPoint(x: w * 1.02, y: h * 0.18)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.60, y: h * 0.98),
            control1: CGPoint(x: w * 0.95, y: h * 0.72),
            control2: CGPoint(x: w * 0.88, y: h * 1.02)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.08, y: h * 0.66),
            control1: CGPoint(x: w * 0.36, y: h * 0.96),
            control2: CGPoint(x: w * 0.12, y: h * 0.90)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.02),
            control1: CGPoint(x: w * 0.04, y: h * 0.42),
            control2: CGPoint(x: w * 0.18, y: h * 0.06)
        )
        path.closeSubpath()
        return path
    }
}
