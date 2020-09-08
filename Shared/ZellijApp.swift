import SwiftUI
import Combine

@main
struct ZellijApp: App {
    var body: some Scene {
        WindowGroup {
            let store = PatternOneConstructionStore(
                timer: ZellijApp.animationTimer,
                pulse: ZellijApp.animationPulse)
            
            PatternOneConstructionLinesView(store: store)
                .frame(width: 400, height: 400)
                .background(Color.blueprint)
                .padding()
        }
    }
}

extension ZellijApp {
    static var animationTimer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer
            .publish(every: animationPulse, on: .main, in: .common)
            .autoconnect()
    }
    
    static var animationPulse: TimeInterval { 0.5 }
}
