import SwiftUI
import Combine

enum PatternOneConstructionState: AnimatableState {
    case initial
    case pulseOne
    case pulseTwo
    case pulseThree
    case pulseFour
    case drawLinesOne
    case drawLinesTwo
    case drawLinesThree
    case drawLinesFour
    case extendLines
    case pause
    case done
    
    static let timeline: [PatternOneConstructionState] = [
        .initial,
        .pulseOne,
        .drawLinesOne,
        .pulseTwo,
        .drawLinesTwo,
        .pulseThree,
        .drawLinesThree,
        .pulseFour,
        .drawLinesFour,
        .pause,
        .extendLines,
        .pause,
        .done,
    ]
}

class PatternOneConstructionStore: AnimatableStore<PatternOneConstructionState>, ObservableObject {
    private(set) var pointsOnCircle: [CGPoint] = []
    let constructionCircleStore: ConstructionCircleStore
    
    @Published var pulsingCircles: [AnimatablePulsingCircle] = []
    @Published var drawnLines: [AnimatableLine] = []
    
    override init(timer: Publishers.Autoconnect<Timer.TimerPublisher>, pulse: TimeInterval) {
        self.constructionCircleStore = ConstructionCircleStore(timer: timer, pulse: pulse)
        super.init(timer: timer, pulse: pulse)
    }
    
    override func start(_ rect: CGRect, delay: Double = 0) {
        pointsOnCircle = Geometry.Circle.allPoints(
            radius: min(rect.width, rect.height) * 0.5,
            center: rect.center,
            divisons: 8)
         
        constructionCircleStore.start(rect, delay: delay)
        super.start(rect, delay: Double(ConstructionCircleState.timeline.count) * pulse)
    }
    
    override func update(_ state: PatternOneConstructionState) {
        switch state {
        case .initial:
            pulsingCircles = [.zero, .zero, .zero]
            drawnLines = [.zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero]
            (0..<drawnLines.count).forEach { drawnLines[$0].animate(.drawing) }
        case .pulseOne:
            pulsingCircles[0].center = pointsOnCircle[0]
            pulsingCircles[1].center = pointsOnCircle[3]
            pulsingCircles[2].center = pointsOnCircle[5]
            (0..<3).forEach { pulsingCircles[$0].reset() }
            
            withAnimation(.linear(duration: pulse)) {
                (0..<3).forEach { pulsingCircles[$0].animate() }
            }
        case .pulseTwo:
            pulsingCircles[0].center = pointsOnCircle[4]
            pulsingCircles[1].center = pointsOnCircle[7]
            pulsingCircles[2].center = pointsOnCircle[1]
            (0..<3).forEach { pulsingCircles[$0].reset() }
            
            withAnimation(.linear(duration: pulse)) {
                (0..<3).forEach { pulsingCircles[$0].animate() }
            }
        case .pulseThree:
            pulsingCircles[0].center = pointsOnCircle[2]
            pulsingCircles[1].center = pointsOnCircle[5]
            pulsingCircles[2].center = pointsOnCircle[7]
            (0..<3).forEach { pulsingCircles[$0].reset() }
            
            withAnimation(.linear(duration: pulse)) {
                (0..<3).forEach { pulsingCircles[$0].animate() }
            }
        case .pulseFour:
            pulsingCircles[0].center = pointsOnCircle[6]
            pulsingCircles[1].center = pointsOnCircle[1]
            pulsingCircles[2].center = pointsOnCircle[3]
            (0..<3).forEach { pulsingCircles[$0].reset() }
            
            withAnimation(.linear(duration: pulse)) {
                (0..<3).forEach { pulsingCircles[$0].animate() }
            }
        case .drawLinesOne:
            drawnLines[0].reset(pointsOnCircle[0])
            drawnLines[1].reset(pointsOnCircle[0])

            withAnimation(.linear(duration: pulse)) {
                drawnLines[0].animate(pointsOnCircle[0], pointsOnCircle[3])
                drawnLines[1].animate(pointsOnCircle[0], pointsOnCircle[5])
            }
        case .drawLinesTwo:
            drawnLines[2].reset(pointsOnCircle[4])
            drawnLines[3].reset(pointsOnCircle[4])

            withAnimation(.linear(duration: pulse)) {
                drawnLines[2].animate(pointsOnCircle[4], pointsOnCircle[1])
                drawnLines[3].animate(pointsOnCircle[4], pointsOnCircle[7])
            }
        case .drawLinesThree:
            drawnLines[4].reset(pointsOnCircle[2])
            drawnLines[5].reset(pointsOnCircle[2])

            withAnimation(.linear(duration: pulse)) {
                drawnLines[4].animate(pointsOnCircle[2], pointsOnCircle[5])
                drawnLines[5].animate(pointsOnCircle[2], pointsOnCircle[7])
            }
        case .drawLinesFour:
            drawnLines[6].reset(pointsOnCircle[6])
            drawnLines[7].reset(pointsOnCircle[6])

            withAnimation(.linear(duration: pulse)) {
                drawnLines[6].animate(pointsOnCircle[6], pointsOnCircle[1])
                drawnLines[7].animate(pointsOnCircle[6], pointsOnCircle[3])
            }
        case .extendLines:
            let extendedPoints = drawnLines.map {
                Geometry.boundedPointsForLine(between: $0.start, and: $0.end, in: rect)
            }
            
            withAnimation(.linear(duration: pulse)) {
                drawnLines[0].animate(extendedPoints[0].flipped)
                drawnLines[1].animate(extendedPoints[1].flipped)
                drawnLines[2].animate(extendedPoints[2])
                drawnLines[3].animate(extendedPoints[3])
                drawnLines[4].animate(extendedPoints[4].flipped)
                drawnLines[5].animate(extendedPoints[5])
                drawnLines[6].animate(extendedPoints[6])
                drawnLines[7].animate(extendedPoints[7].flipped)
            }
        case .pause:
            break
        case .done:
            withAnimation(.linear(duration: pulse)) {
                (0..<drawnLines.count).forEach { drawnLines[$0].animate(.construction) }
            }
        }
    }
}

struct PatternOneConstructionLinesView: View {
    @StateObject var store: PatternOneConstructionStore
    
    var body: some View {
        ZStack {
            ConstructionCircleView(store: store.constructionCircleStore)
                
            ForEach(store.pulsingCircles) {
                AnimatablePulsingCircleView(model: $0)
            }
            
            ForEach(store.drawnLines) {
                AnimatableLineView(model: $0)
            }
        }
    }
}

struct PatternOneConstructionLinesView_Previews: PreviewProvider {
    static var previews: some View {
        let store = PatternOneConstructionStore(timer: ZellijApp.animationTimer, pulse: ZellijApp.animationPulse)
        
        GeometryReader { geometry in
            PatternOneConstructionLinesView(store: store)
                .onAppear { store.start(geometry.frame(in: .local)) }
        }
        .frame(width: 400, height: 400)
        .background(Color.blueprint)
    }
}
