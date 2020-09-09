import SwiftUI

struct PatternOne {
    let rect: CGRect
    let pointsOnCircle: [CGPoint]
    
    init(rect: CGRect) {
        self.rect = rect
        self.pointsOnCircle = Geometry.Circle.allPoints(
            radius: min(rect.width, rect.height) * 0.5,
            center: rect.center,
            divisons: 8)
    }
    
    func update
}
