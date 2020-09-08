import SwiftUI

struct AnimatablePulsingCircle: Identifiable {
    let id: UUID
    var progress: CGFloat
    var center: CGPoint
    var alpha: Double
    var foregroundColor: Color
    
    mutating func reset() {
        progress = 0.0
        alpha = 1.0
    }
    
    mutating func animate() {
        progress = 1.0
        alpha = 0.0
    }
    
    static var zero: Self {
        .init(id: .init(), progress: .zero, center: .zero, alpha: .zero, foregroundColor: .white)
    }
}

struct AnimatablePulsingCircleView: View {
    var model: AnimatablePulsingCircle
    
    var body: some View {
        AnimatablePulsingCircleShape(progress: model.progress, center: model.center)
            .opacity(model.alpha)
            .foregroundColor(model.foregroundColor)
    }
}

struct AnimatablePulsingCircleShape: Shape {
    var progress: CGFloat
    var center: CGPoint
    
    func path(in rect: CGRect) -> Path {
        Path {
            $0.addArc(center: center,
                      radius: min(rect.height, rect.width) * 0.1 * progress,
                      startAngle: .degrees(0),
                      endAngle: .degrees(360),
                      clockwise: true)
        }
    }
    
    var animatableData: AnimatablePair<CGFloat, CGPoint.AnimatableData> {
        get { AnimatablePair(progress, center.animatableData) }
        set { (progress, center.animatableData) = (newValue.first, newValue.second) }
    }
}
