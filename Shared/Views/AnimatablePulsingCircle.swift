import SwiftUI

struct AnimatablePulsingCircle: Shape {
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
