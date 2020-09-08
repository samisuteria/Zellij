import Combine
import SwiftUI

class ConstructionCircleStore: ObservableObject {
    enum State {
        case initial
        case drawCircle
        case drawAxis
        case drawCross
        case pause
        case done
        
        static var timeline: [State] = [
            .initial,
            .drawCircle,
            .pause,
            .drawAxis,
            .drawCross,
            .pause,
            .done,
        ]
    }
    
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    private var pulse: TimeInterval
    private var subscriptions = Set<AnyCancellable>()
    private var state: State = .initial { didSet { update(state) }}
    private var rect: CGRect = .zero
    
    @Published var circleProgress: Double = 0.0
    @Published var linePoints: [Geometry.PointPair] = [.zero, .zero, .zero, .zero]
    @Published var strokeColor: Color = .drawing
    
    init(timer: Publishers.Autoconnect<Timer.TimerPublisher>, pulse: TimeInterval) {
        self.timer = timer
        self.pulse = pulse
    }
    
    func start(_ rect: CGRect, delay: Int = 0) {
        self.rect = rect
        
        timer
            .zip(State.timeline.publisher)
            .map { $0.1 }
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
            .sink { self.state = $0 }
            .store(in: &subscriptions)
    }
    
    func stop() {
        subscriptions.forEach { $0.cancel() }
    }
    
    private func update(_ state: State) {
        switch state {
        case .initial:
            strokeColor = .drawing
            circleProgress = 0.0
            linePoints = [
                .init(CGPoint(x: rect.midX, y: rect.minY), CGPoint(x: rect.midX, y: rect.minY)),
                .init(CGPoint(x: rect.minX, y: rect.midY), CGPoint(x: rect.minX, y: rect.midY)),
                .init(CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.minX, y: rect.minY)),
                .init(CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.minY))
            ]
        case .drawCircle:
            withAnimation(.linear(duration: pulse * 2)) {
                self.circleProgress = 1.0
            }
        case .drawAxis:
            withAnimation(.linear(duration: pulse)) {
                self.linePoints[0] = .init(CGPoint(x: rect.midX, y: rect.minY),
                                           CGPoint(x: rect.midX, y: rect.maxY))
                self.linePoints[1] = .init(CGPoint(x: rect.minX, y: rect.midY),
                                           CGPoint(x: rect.maxX, y: rect.midY))
            }
        case .drawCross:
            withAnimation(.linear(duration: pulse)) {
                self.linePoints[2] = .init(CGPoint(x: rect.minX, y: rect.minY),
                                           CGPoint(x: rect.maxX, y: rect.maxY))
                self.linePoints[3] = .init(CGPoint(x: rect.maxX, y: rect.minY),
                                           CGPoint(x: rect.minX, y: rect.maxY))
            }
        case .pause:
            break
        case .done:
            withAnimation(.linear(duration: pulse)) {
                self.strokeColor = .construction
            }
        }
    }
}

struct ConstructionCircleView: View {
    @StateObject var store: ConstructionCircleStore
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AnimatableCircle(progress: store.circleProgress)
                    .stroke(store.strokeColor, lineWidth: 1.0)
                ForEach(0..<store.linePoints.count) { index in
                    AnimatableLine(start: store.linePoints[index].start,
                                   end: store.linePoints[index].end)
                        .stroke(store.strokeColor, lineWidth: 1.0)
                }
            }
            .onAppear { self.store.start(geometry.frame(in: .local)) }
        }
    }
}

struct ConstructionCircle_Previews: PreviewProvider {
    static var previews: some View {
        ConstructionCircleView(store: ConstructionCircleStore(timer: ZellijApp.animationTimer, pulse: ZellijApp.animationPulse))
            .frame(width: 400, height: 400)
            .background(Color.blueprint)
            .padding()
    }
}
