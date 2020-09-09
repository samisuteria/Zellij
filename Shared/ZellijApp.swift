import SwiftUI
import Combine

@main
struct ZellijApp: App {
    var body: some Scene {
        WindowGroup {
            let store = PatternOneDrawingStore(
                timer: ZellijApp.animationTimer,
                pulse: ZellijApp.animationPulse)
            
            HStack(spacing: 0) {
                ForEach(0..<4) { _ in
                    VStack(spacing: 0) {
                        ForEach(0..<4) { _ in
                            PatternOneDrawingView(store: store)
                                .frame(width: 200, height: 200)
                        }
                    }
                }
            }
            .drawingGroup()
            .background(Color.blueprint)
            .onTapGesture {
                store.start(CGRect(origin: .zero,
                                   size: CGSize(
                                    width: 200,
                                    height: 200)),
                            delay: 1.0)
            }
            .frame(width: 800, height: 800)
        }
    }
}

extension ZellijApp {
    static var animationTimer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer
            .publish(every: animationPulse, on: .main, in: .common)
            .autoconnect()
    }
    
    static var animationPulse: TimeInterval { 0.75 }
}
