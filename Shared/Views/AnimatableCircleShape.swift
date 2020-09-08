import SwiftUI

struct AnimatableCircleShape: Shape {
    // Should be a value between 0 to 1
    var progress: Double
    
    func path(in rect: CGRect) -> Path {
        Path {
            $0.addArc(center: rect.center,
                      radius: min(rect.height, rect.width) * 0.5,
                      startAngle: .degrees(180),
                      endAngle: .degrees(progress * 360 + 180),
                      clockwise: false)
        }
    }
    
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
}
