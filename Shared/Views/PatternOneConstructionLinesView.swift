import SwiftUI
import Combine

class PatternOneConstructionLinesStore: ObservableObject {
    enum State {
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
        
        static var timeline: [State] = [
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
    
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    private var pulse: TimeInterval
    private var subscriptions = Set<AnyCancellable>()
    private var state: State = .initial { didSet { update(state) }}
    private var rect: CGRect = .zero
    private var pointsOnCircle: [CGPoint] = []
    var subStoreDelay: TimeInterval {
        Double(ConstructionCircleStore.State.timeline.count) * pulse
    }
    let constructionCircleStore: ConstructionCircleStore
    
    init(timer: Publishers.Autoconnect<Timer.TimerPublisher>, pulse: TimeInterval) {
        self.timer = timer
        self.pulse = pulse
        self.constructionCircleStore = ConstructionCircleStore(timer: timer, pulse: pulse)
    }
    
    func start(_ rect: CGRect, delay: Double = 0) {
        self.rect = rect
        self.pointsOnCircle = Geometry.Circle.allPoints(
            radius: min(rect.width, rect.height) * 0.5,
            center: rect.center,
            divisons: 8)
        
        timer
            .zip(State.timeline.publisher)
            .map { $0.1 }
            .delay(for: .seconds(delay + subStoreDelay), scheduler: DispatchQueue.main)
            .sink { self.state = $0 }
            .store(in: &subscriptions)
    }
    
    func stop() {
        subscriptions.forEach { $0.cancel() }
    }
    
    struct PulsingCircle: Identifiable {
        let id: UUID
        var progress: CGFloat
        var center: CGPoint
        var alpha: Double
        
        mutating func reset() {
            progress = 0.0
            alpha = 1.0
        }
        
        mutating func animate() {
            progress = 1.0
            alpha = 0.0
        }
        
        static var zero: Self {
            .init(id: .init(), progress: .zero, center: .zero, alpha: .zero)
        }
    }
    
    struct DrawnLine: Identifiable {
        let id: UUID
        var start: CGPoint
        var end: CGPoint
        
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
        
        static var zero: Self {
            .init(id: .init(), start: .zero, end: .zero)
        }
    }
    
    @Published var pulsingCircles: [PulsingCircle] = []
    @Published var drawnLines: [DrawnLine] = []
    @Published var strokeColor: Color = .drawing
    
    private func update(_ state: State) {
        switch state {
        case .initial:
            pulsingCircles = [.zero, .zero, .zero]
            drawnLines = [.zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero]
            strokeColor = .drawing
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
                strokeColor = .construction
            }
        }
    }
}

struct PatternOneConstructionLinesView: View {
    @StateObject var store: PatternOneConstructionLinesStore
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ConstructionCircleView(store: store.constructionCircleStore)
                
                ForEach(store.pulsingCircles) {
                    AnimatablePulsingCircle(progress: $0.progress, center: $0.center)
                        .opacity($0.alpha)
                        .foregroundColor(store.strokeColor)
                }
                
                ForEach(store.drawnLines) {
                    AnimatableLine(start: $0.start, end: $0.end)
                        .stroke(store.strokeColor, lineWidth: 1.0)
                }
                
            }.onAppear { self.store.start(geometry.frame(in: .local))}
        }
    }
}

struct PatternOneConstructionLinesView_Previews: PreviewProvider {
    static var previews: some View {
        let store = PatternOneConstructionLinesStore(
            timer: ZellijApp.animationTimer,
            pulse: ZellijApp.animationPulse)
        
        PatternOneConstructionLinesView(store: store)
            .frame(width: 400, height: 400)
            .background(Color.blueprint)
            .padding()
    }
}
