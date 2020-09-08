import Combine
import SwiftUI

enum ConstructionCircleState: AnimatableState {
    case initial
    case drawCircle
    case drawAxis
    case drawCross
    case pause
    case done
    
    static var timeline: [ConstructionCircleState] = [
        .initial,
        .drawCircle,
        .pause,
        .drawAxis,
        .drawCross,
        .pause,
        .done,
    ]
}

class ConstructionCircleStore: AnimatableStore<ConstructionCircleState>, ObservableObject {
    @Published var circle: AnimatableCircle = .zero
    @Published var lines: [AnimatableLine] = [.zero, .zero, .zero, .zero]
    
    override func update(_ state: ConstructionCircleState) {
        switch state {
        case .initial:
            circle.strokeColor = .drawing
            circle.progress = 0.0
            lines[0].animate(CGPoint(x: rect.midX, y: rect.minY), CGPoint(x: rect.midX, y: rect.minY))
            lines[1].animate(CGPoint(x: rect.minX, y: rect.midY), CGPoint(x: rect.minX, y: rect.midY))
            lines[2].animate(CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.minX, y: rect.minY))
            lines[3].animate(CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.minY))
        case .drawCircle:
            withAnimation(.linear(duration: pulse * 2)) {
                self.circle.progress = 1.0
            }
        case .drawAxis:
            withAnimation(.linear(duration: pulse)) {
                self.lines[0].animate(CGPoint(x: rect.midX, y: rect.minY), CGPoint(x: rect.midX, y: rect.maxY))
                self.lines[1].animate(CGPoint(x: rect.minX, y: rect.midY), CGPoint(x: rect.maxX, y: rect.midY))
            }
        case .drawCross:
            withAnimation(.linear(duration: pulse)) {
                self.lines[2].animate(CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.maxY))
                self.lines[3].animate(CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.minX, y: rect.maxY))
            }
        case .pause:
            break
        case .done:
            withAnimation(.linear(duration: pulse)) {
                self.circle.strokeColor = .construction
                (0..<self.lines.count).forEach {
                    self.lines[$0].strokeColor = .construction
                }
            }
        }
    }
}

struct ConstructionCircleView: View {
    @StateObject var store: ConstructionCircleStore
    
    var body: some View {
        ZStack {
            AnimatableCircleView(model: store.circle)
            ForEach(store.lines) {
                AnimatableLineView(model: $0)
            }
        }
    }
}

struct ConstructionCircle_Previews: PreviewProvider {
    static var previews: some View {
        let store = ConstructionCircleStore(timer: ZellijApp.animationTimer, pulse: ZellijApp.animationPulse)
        
        GeometryReader { geometry in
            ConstructionCircleView(store: store)
                .onAppear { store.start(geometry.frame(in: .local)) }
        }
        .frame(width: 400, height: 400)
        .background(Color.blueprint)
    }
}
