import SwiftUI
import Combine

enum PatternOneDrawingState: AnimatableState {
    case initial
    case pulse(Stage)
    case draw(Stage)
    case outsideDone
    case starDone
    case pause
    case done
    
    enum Stage {
        case outsideOne
        case outsideTwo
        case outsideThree
        case outsideFour
        case starOne
        case starTwo
        case starThree
        case starFour
    }
    
    static var timeline: [PatternOneDrawingState] = [
        .initial,
        .pulse(.outsideOne),
        .draw(.outsideOne),
        .pulse(.outsideTwo),
        .draw(.outsideTwo),
        .pulse(.outsideThree),
        .draw(.outsideThree),
        .pulse(.outsideFour),
        .draw(.outsideFour),
        .outsideDone,
        .pulse(.starOne),
        .draw(.starOne),
        .pulse(.starTwo),
        .draw(.starTwo),
        .pulse(.starThree),
        .draw(.starThree),
        .pulse(.starFour),
        .draw(.starFour),
        .starDone,
        .pause,
        .pause,
        .done,
    ]
}

class PatternOneDrawingStore: AnimatableStore<PatternOneDrawingState>, ObservableObject {
    private var pointsOnCircle: [CGPoint] = []
    private var outsideIntersectionPoints: [CGPoint] = []
    private var starIntersectionPoints: [CGPoint] = []
    private var outsideBoundingPoints: [Geometry.PointPair] = []
    private var animationEndPairs: [Geometry.PointPair] = []
    let constructionStore: PatternOneConstructionStore
    var subDelay: Double {
        constructionStore.subDelay + (Double(PatternOneConstructionState.timeline.count) * pulse)
    }
    
    @Published var pulsingCircles: [AnimatablePulsingCircle] = []
    @Published var drawnLines: [AnimatableLine] = []
    
    override init(timer: Publishers.Autoconnect<Timer.TimerPublisher>, pulse: TimeInterval) {
        self.constructionStore = PatternOneConstructionStore(timer: timer, pulse: pulse)
        super.init(timer: timer, pulse: pulse)
    }
    
    override func start(_ rect: CGRect, delay: Double = 0) {
        pointsOnCircle = Geometry.Circle.allPoints(
            radius: min(rect.width, rect.height) * 0.5,
            center: rect.center,
            divisons: 8)
        
        func intersection(_ a: Int, _ b: Int, _ c: Int, _ d: Int) -> CGPoint {
            Geometry.intersection(
                between: Geometry.boundedPointsForLine(between: pointsOnCircle[a], and: pointsOnCircle[b], in: rect),
                and: Geometry.boundedPointsForLine(between: pointsOnCircle[c], and: pointsOnCircle[d], in: rect))
        }
        
        outsideIntersectionPoints = [
            intersection(4, 7, 5, 0),
            intersection(3, 0, 1, 4),
            intersection(5, 2, 3, 6),
            intersection(7, 2, 1, 6),
        ]
        
        starIntersectionPoints = [
            intersection(6, 3, 4, 7),
            intersection(6, 1, 0, 5),
            intersection(2, 5, 4, 1),
            intersection(2, 7, 0, 3)
        ]
        
        func boundedPair(_ a: Int, _ b: Int, _ division: Geometry.RectDivision) -> Geometry.PointPair {
            Geometry.boundedPointsForLine(
                between: pointsOnCircle[a],
                and: pointsOnCircle[b],
                in: rect.divided(by: division))
        }
        
        outsideBoundingPoints = [
            boundedPair(5, 0, .leftHalf).flipped,
            boundedPair(7, 4, .rightHalf),
            boundedPair(3, 0, .leftHalf).flipped,
            boundedPair(1, 4, .rightHalf),
            boundedPair(5, 2, .topHalf).flipped,
            boundedPair(3, 6, .bottomHalf).flipped,
            boundedPair(7, 2, .topHalf),
            boundedPair(1, 6, .bottomHalf),
        ]
        
        animationEndPairs = [
            boundedPair(5, 6, .leftHalf).flipped,
            boundedPair(7, 6, .rightHalf),
            boundedPair(3, 2, .leftHalf).flipped,
            boundedPair(1, 2, .rightHalf),
            boundedPair(5, 4, .topHalf),
            boundedPair(3, 4, .bottomHalf),
            boundedPair(7, 0, .topHalf).flipped,
            boundedPair(1, 0, .bottomHalf).flipped,
            
            boundedPair(5, 6, .topHalf).flipped,
            boundedPair(7, 6, .topHalf),
            boundedPair(4, 5, .topHalf),
            boundedPair(4, 3, .bottomHalf),
            boundedPair(0, 7, .topHalf).flipped,
            boundedPair(0, 1, .bottomHalf).flipped,
            boundedPair(2, 3, .bottomHalf).flipped,
            boundedPair(2, 1, .bottomHalf),
        ]
        
        constructionStore.start(rect, delay: delay)
        super.start(rect, delay: subDelay)
    }
    
    override func stop() {
        constructionStore.stop()
        super.stop()
    }
    
    private func updatePulsingCircles(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) {
        pulsingCircles[0].center = a
        pulsingCircles[1].center = b
        pulsingCircles[2].center = c
        (0..<3).forEach { pulsingCircles[$0].reset() }
        
        withAnimation(.linear(duration: pulse)) {
            (0..<3).forEach { pulsingCircles[$0].animate() }
        }
    }
    
    private func updateDrawnLine(_ l1: Int, _ l2: Int, _ start: CGPoint, _ end1: CGPoint, _ end2: CGPoint) {
        drawnLines[l1].reset(start)
        drawnLines[l2].reset(start)
        
        withAnimation(.linear(duration: pulse)) {
            drawnLines[l1].animate(start, end1)
            drawnLines[l2].animate(start, end2)
        }
    }
    
    override func update(_ state: PatternOneDrawingState) {
        switch state {
        case .initial:
            pulsingCircles = [.zero, .zero, .zero]
            drawnLines = [.zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, // outside 0-7
                          .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero] // star 8-15
        case .pulse(let pulseState):
            switch pulseState {
            case .outsideOne:
                updatePulsingCircles(
                    pointsOnCircle[5],
                    pointsOnCircle[7],
                    outsideIntersectionPoints[0])
            case .outsideTwo:
                updatePulsingCircles(
                    pointsOnCircle[3],
                    pointsOnCircle[1],
                    outsideIntersectionPoints[1])
            case .outsideThree:
                updatePulsingCircles(
                    pointsOnCircle[5],
                    pointsOnCircle[3],
                    outsideIntersectionPoints[2])
            case .outsideFour:
                updatePulsingCircles(
                    pointsOnCircle[1],
                    pointsOnCircle[7],
                    outsideIntersectionPoints[3])
            case .starOne:
                updatePulsingCircles(pointsOnCircle[6],
                                     starIntersectionPoints[0],
                                     starIntersectionPoints[1])
            case .starTwo:
                updatePulsingCircles(pointsOnCircle[4],
                                     starIntersectionPoints[0],
                                     starIntersectionPoints[2])
            case .starThree:
                updatePulsingCircles(pointsOnCircle[0],
                                     starIntersectionPoints[1],
                                     starIntersectionPoints[3])
            case .starFour:
                updatePulsingCircles(pointsOnCircle[2],
                                     starIntersectionPoints[2],
                                     starIntersectionPoints[3])
            }
            break
        case .draw(let drawState):
            switch drawState {
            case .outsideOne:
                updateDrawnLine(0, 1,
                                outsideIntersectionPoints[0],
                                pointsOnCircle[5],
                                pointsOnCircle[7])
            case .outsideTwo:
                updateDrawnLine(2, 3,
                                outsideIntersectionPoints[1],
                                pointsOnCircle[3],
                                pointsOnCircle[1])
            case .outsideThree:
                updateDrawnLine(4, 5,
                                outsideIntersectionPoints[2],
                                pointsOnCircle[5],
                                pointsOnCircle[3])
            case .outsideFour:
                updateDrawnLine(6, 7,
                                outsideIntersectionPoints[3],
                                pointsOnCircle[7],
                                pointsOnCircle[1])
            case .starOne:
                updateDrawnLine(8, 9,
                                pointsOnCircle[6],
                                starIntersectionPoints[0],
                                starIntersectionPoints[1])
            case .starTwo:
                updateDrawnLine(10, 11,
                                pointsOnCircle[4],
                                starIntersectionPoints[0],
                                starIntersectionPoints[2])
            case .starThree:
                updateDrawnLine(12, 13,
                                pointsOnCircle[0],
                                starIntersectionPoints[1],
                                starIntersectionPoints[3])
            case .starFour:
                updateDrawnLine(14, 15,
                                pointsOnCircle[2],
                                starIntersectionPoints[2],
                                starIntersectionPoints[3])
            }
        case .outsideDone:
            withAnimation(.linear(duration: pulse)) {
                (0..<8).forEach {
                    drawnLines[$0].animate(outsideBoundingPoints[$0])
                }
            }
        case .starDone:
            break
        case .pause:
            break
        case .done:
            withAnimation(Animation.linear(duration: pulse * 1.5).repeatCount(20, autoreverses: true)) {
                (0..<8).forEach {
                    drawnLines[$0].animate(animationEndPairs[$0])
                }
            }
        }
    }
}

struct PatternOneDrawingView: View {
    @StateObject var store: PatternOneDrawingStore
    
    var body: some View {
        ZStack {
            PatternOneConstructionLinesView(store: store.constructionStore)
            
            ForEach(store.pulsingCircles) {
                AnimatablePulsingCircleView(model: $0)
            }
            
            ForEach(store.drawnLines) {
                AnimatableLineView(model: $0)
            }
        }
    }
}

struct PatternOneDrawingView_Previews: PreviewProvider {
    static var previews: some View {
        let store = PatternOneDrawingStore(timer: ZellijApp.animationTimer, pulse: ZellijApp.animationPulse)
        
        GeometryReader { geometry in
            PatternOneDrawingView(store: store)
                .onAppear { store.start(geometry.frame(in: .local)) }
        }
        .frame(width: 400, height: 400)
        .background(Color.blueprint)
    }
}
