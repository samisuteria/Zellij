import SwiftUI

struct AnimatableLine: Identifiable {
    let id: UUID
    var start: CGPoint
    var end: CGPoint
    var strokeColor: Color
    var lineWidth: CGFloat
    
    mutating func reset(_ point: CGPoint) {
        start = point
        end = point
    }
    
    mutating func animate(_ start: CGPoint, _ end: CGPoint) {
        self.start = start
        self.end = end
    }
    
    mutating func animate(_ pair: Geometry.PointPair) {
        self.start = pair.start
        self.end = pair.end
    }
    
    mutating func animate(_ strokeColor: Color) {
        self.strokeColor = strokeColor
    }
    
    static var zero: Self {
        .init(id: .init(), start: .zero, end: .zero, strokeColor: .white, lineWidth: 1.0)
    }
}

struct AnimatableLineView: View {
    var model: AnimatableLine
    
    var body: some View {
        AnimatableLineShape(start: model.start, end: model.end)
            .stroke(model.strokeColor, lineWidth: model.lineWidth)
    }
}

struct AnimatableLineShape: Shape {
    var start: CGPoint
    var end: CGPoint
    
    func path(in rect: CGRect) -> Path {
        Path {
            $0.move(to: start)
            $0.addLine(to: end)
        }
    }
    
    var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
        get { AnimatablePair(start.animatableData, end.animatableData) }
        set { (start.animatableData, end.animatableData) = (newValue.first, newValue.second) }
    }
}
