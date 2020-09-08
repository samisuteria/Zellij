import Combine
import SwiftUI

protocol AnimatableState {
    static var initial: Self { get }
    static var timeline: [Self] { get }
}

class AnimatableStore<State: AnimatableState> {
    private(set) var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    private(set) var pulse: TimeInterval
    private(set) var subscriptions = Set<AnyCancellable>()
    private(set) var state: State = .initial { didSet { update(state) }}
    private(set) var rect: CGRect = .zero
    
    init(timer: Publishers.Autoconnect<Timer.TimerPublisher>, pulse: TimeInterval) {
        self.timer = timer
        self.pulse = pulse
    }
    
    func start(_ rect: CGRect, delay: Double = 0) {
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
    
    func update(_ state: State) {
        assert(false, "Needs to be implemented by subclass")
    }
}
